import network
import machine
import time
import ujson
from umqtt.simple import MQTTClient
import ntptime

# WiFi credentials
ssid = ""
psk = ""

# MQTT broker details
aws_broker = b"a2fcyk7jrcl2w-ats.iot.eu-north-1.amazonaws.com"
clientid = 'ParkingLot1-ESP32-1'
pkey = 'ParkingLot1-ESP32.private.key'
ccert = 'ParkingLot1-ESP32.cert.pem'
rroot_ca = 'root-CA.crt'
pub_topic = 'lots/spots'
sub_topic = 'lots/barriers'


# Initialize IR sensor pin
spot_A01_IR = machine.Pin(18, machine.Pin.IN)  # Spot 1 IR Sensor
spot_A02_IR = machine.Pin(19, machine.Pin.IN)  # Spot 2 IR Sensor

# Initialize LED pin
spot_A01_gate = machine.Pin(4, machine.Pin.OUT)  # Spot 1 Gate
spot_A02_gate = machine.Pin(5, machine.Pin.OUT)  # Spot 2 Gate

# Load SSL certificates
def load_certificates():
    with open(pkey, 'r') as f:
        key_data = f.read()
    with open(ccert, 'r') as f:
        cert_data = f.read()
    with open(rroot_ca, 'r') as f:
            ca_data = f.read()
    return {"key": key_data, "cert": cert_data, "server_side": False}

# WiFi connection
def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(ssid, psk)
    print("Connecting to WiFi...")
    start_time = time.time()
    while not wlan.isconnected():
        if time.time() - start_time > 15:  # 15 seconds timeout
            raise Exception("Could not connect to WiFi")
        print(".", end=" ")
        time.sleep(0.5)
    print("\nConnected to WiFi {} with IP: {}".format(ssid, wlan.ifconfig()[0]))
    return wlan

def message_callback(topic, msg):
    print(f"Received message from topic {topic}: {msg}")
    if msg == b'{\n  "parkingLotId": 1,\n  "spotId": "A-01",\n  "barrier": 1\n}':
        spot_A01_gate.value(1)  # Turn on LED
    elif msg == b'{\n  "parkingLotId": 1,\n  "spotId": "A-01",\n  "barrier": 0\n}':
        spot_A01_gate.value(0) # Turn off LED
    elif msg == b'{\n  "parkingLotId": 1,\n  "spotId": "A-02",\n  "barrier": 1\n}':
        spot_A02_gate.value(1) # Turn on LED
    elif msg == b'{\n  "parkingLotId": 1,\n  "spotId": "A-02",\n  "barrier": 0\n}':
        spot_A02_gate.value(0) # Turn off LED

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

# Publish message
def publish_message(mqtt, mssg):
    for _ in range(3):  # Retry up to 3 times
        try:
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
    
    previous_status_A01 = spot_A01_IR.value()
    previous_status_A02 = spot_A02_IR.value()
    
    try:
        while True:
            mqtt.check_msg()
            time.sleep(1)
            
            current_status_A01 = spot_A01_IR.value()
            current_status_A02 = spot_A02_IR.value()
            
            # Check for changes in Spot A-01
            if current_status_A01 != previous_status_A01:
                previous_status_A01 = current_status_A01
                spot_status = "available" if current_status_A01 else "occupied"
                
                # Prepare and publish data to MQTT for Spot A-01
                data = {
                    "parkingLotId": 1,
                    "spotId": "A-01",
                    "status": spot_status,
                }
                mssg = ujson.dumps(data)
                publish_message(mqtt, mssg)
                
                print("IR Sensor A-01 Status Changed: {}".format("HIGH" if current_status_A01 else "LOW"))
            
            # Check for changes in Spot A-02
            if current_status_A02 != previous_status_A02:
                previous_status_A02 = current_status_A02
                spot_status = "available" if current_status_A02 else "occupied"
                
                # Prepare and publish data to MQTT for Spot A-02
                data = {
                    "parkingLotId": 1,
                    "spotId": "A-02",
                    "status": spot_status,
                }
                mssg = ujson.dumps(data)
                publish_message(mqtt, mssg)
                
                print("IR Sensor A-02 Status Changed: {}".format("HIGH" if current_status_A02 else "LOW"))
            
            time.sleep(0.1)  # Adjust the sleep time as needed
    except KeyboardInterrupt:
        print("Terminating the script.")
    finally:
        try:
            mqtt.disconnect()
        except Exception as e:
            print("Error during disconnect: {}".format(e))
        wlan.disconnect()
        machine.reset()

# Run the main loop
if __name__ == "__main__":
    main()