# Combined ESP32-CAM Distance Warning and Number Plate Recognition System
import machine
from machine import Pin
import network
import time
import esp
import urequests as requests
import gc
import ujson
from umqtt.simple import MQTTClient

# WiFi credentials
ssid = ''     # Change to your WiFi name
password = ''   # Change to your WiFi password

# MQTT broker details
aws_broker = b"a2fcyk7jrcl2w-ats.iot.eu-north-1.amazonaws.com"
clientid = 'ParkingLot1-ESP32-1'
pkey = 'ParkingLot1-ESP32.private.key'
ccert = 'ParkingLot1-ESP32.cert.pem'
rroot_ca = 'root-CA.crt'
pub_topic = 'lots/gate'
sub_topic = 'lots/gatesBarrier'

# Load SSL certificates
def load_certificates():
    with open(pkey, 'r') as f:
        key_data = f.read()
    with open(ccert, 'r') as f:
        cert_data = f.read()
    with open(rroot_ca, 'r') as f:
            ca_data = f.read()
    return {"key": key_data, "cert": cert_data, "server_side": False}

# Server details for number plate recognition
serverName = 'www.circuitdigest.cloud'  # Replace with your server domain
serverPath = '/readnumberplate'         # API endpoint path
serverPort = 443                        # HTTPS port
apiKey = 'ozawI8ForsOJ'                 # Replace with your API key

# Pin definitions
TRIGGER_PIN = 13  # Ultrasonic sensor trigger pin
ECHO_PIN = 14     # Ultrasonic sensor echo pin
FLASH_LED = 4     # Built-in LED for flash
GATE_LED = 15     # External LED for gate

# Distance thresholds
DISTANCE_WARNING_THRESHOLD = 6    # For warning system
PLATE_CAPTURE_THRESHOLD = 100     # For number plate capture

# Initialize WiFi
def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.disconnect()
    wlan.connect(ssid, password)
    print("Connecting to WiFi...")
    while not wlan.isconnected():
        time.sleep(1)
        print('Connecting to WiFi...')
    print('WiFi connected')
    print('IP:', wlan.ifconfig()[0])
    return wlan

# Initialize ultrasonic sensor
trigger = Pin(TRIGGER_PIN, Pin.OUT)
echo = Pin(ECHO_PIN, Pin.IN)

# Initialize flash LED
flash = Pin(FLASH_LED, Pin.OUT)
gate = Pin(GATE_LED, Pin.OUT)

# Turn on flash and gate
flash.on()
gate.on()

def message_callback(topic, msg):
    print(f"Received message from topic {topic}: {msg}")
    if msg == b'{\n  "barrier": 0\n}':
        gate.off()  # Turn off gate
        time.sleep(5)   # Wait for 5 seconds
        gate.on()  # Turn on gate

# MQTT connection
def connect_mqtt():
    try:
        mqtt = MQTTClient(client_id=clientid, server=aws_broker, port=8883, keepalive=1200, ssl=True, ssl_params=load_certificates())
        mqtt.set_callback(message_callback)
        mqtt.connect()
        print("Connected to MQTT Broker :: {}".format(aws_broker))
        mqtt.subscribe(sub_topic)
        print("Subscribed to topic: {}".format(sub_topic))
        return mqtt
    except Exception as e:
        print("Failed to connect to MQTT Broker: {}".format(e))
        machine.reset()

# Initialize camera
def init_camera():
    while True:
        try:
            import camera
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.framesize(camera.FRAME_SVGA)
            camera.flip(1)
            print('Camera initialized')
            break
        except Exception as e:
            print('Failed to initialize camera:', e)
            print('Retrying camera initialization...')
            time.sleep(1)

# Get distance from ultrasonic sensor
def get_distance():
    trigger.off()
    time.sleep_us(2)
    trigger.on()
    time.sleep_us(10)
    trigger.off()
    try:
        pulse_time = machine.time_pulse_us(echo, 1, 30000)
        distance = (pulse_time / 2) / 29.1  # Convert to cm
        return distance
    except OSError as ex:
        print('Distance measurement error:', ex)
        return None

# Capture photo
def capture_photo():
    time.sleep(0.1)  # Allow time for the camera to adjust
    import camera
    buf = camera.capture()
    if buf:
        print('Photo captured')
        return buf
    else:
        print('Failed to capture photo')
        return None

# Send photo to server
def send_photo_to_server(image_data):
    url = 'https://' + serverName + serverPath
    boundary = '-----WebKitFormBoundary7MA4YWxkTrZu0gW'
    headers = {
        'Authorization': apiKey,
        'Content-Type': 'multipart/form-data; boundary={}'.format(boundary)
    }
    filename = apiKey + '.jpeg'

    data = '--{}\r\n'.format(boundary)
    data += 'Content-Disposition: form-data; name="imageFile"; filename="{}"\r\n'.format(filename)
    data += 'Content-Type: image/jpeg\r\n\r\n'
    multipart_data = data.encode('utf-8') + image_data + '\r\n--{}--\r\n'.format(boundary).encode('utf-8')

    try:
        response = requests.post(url, data=multipart_data, headers=headers)
        if response.status_code == 200:
            print('Photo sent to server')
            json_response = response.json()
            number_plate = json_response.get('number_plate', '')
            print('View Image:', json_response.get('view_image', ''))
            if number_plate:
                print('Number Plate:', number_plate)
                return number_plate
            else:
                print('Number plate not found in response')
        else:
            print('Failed to send photo, status code:', response.status_code)
    except Exception as e:
        print('Error sending photo:', e)

def publishMQTT(data):
    mssg = ujson.dumps(data)
    for _ in range(3):  # Retry up to 3 times
        try:
            print("Publishing message")
            mqtt.publish(pub_topic, mssg)
            print("Published message: {}".format(mssg))
            break
        except Exception as e:
            print("Failed to publish message: {}. Retrying...".format(e))
            time.sleep(1)  # Wait before retrying
    else:
        print("Failed to publish message after 3 attempts. Reconnecting...")
        mqtt.disconnect()
        mqtt = connect_mqtt()

# Main loop
def main():
    wlan = connect_wifi()
    mqtt = connect_mqtt()

    # Initialize camera
    init_camera()

    while True:
        mqtt.check_msg()
        distance = get_distance()
        if distance:
            print('Distance:', distance, 'cm')
            # Check for close objects (warning system)
            if distance < DISTANCE_WARNING_THRESHOLD:
                print('WARNING: Vehicle too close!')
            # Check for vehicles in range (number plate detection)
            elif distance < PLATE_CAPTURE_THRESHOLD:
                print('Vehicle detected at distance:', distance, 'cm')
                print('Capturing photo...')
                image = capture_photo()
                if image:
                    # Free up memory
                    gc.collect()
                    # Send photo to server
                    print('Sending photo to server...')
                    numberPlate = send_photo_to_server(image)

                    # Free memory
                    del image
                    gc.collect()

                    if not numberPlate:
                        print('Number plate not found')
                        continue
                    else:
                        print('Number Plate:', numberPlate)

                        # Prepare data to publish
                        data = {
                            "numberPlate": numberPlate,
                        }

                        # Publish data to MQTT
                        publishMQTT(data)
                time.sleep(5)  # Prevent multiple captures
            else:
                print('WARNING: Vehicle out of range')
        else:
            print('Failed to read distance')

        time.sleep(0.1)  # Small delay between readings

# Start the program
if __name__ == '__main__':
    main()