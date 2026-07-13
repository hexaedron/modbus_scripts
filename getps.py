#!/usr/bin/env python3
import os
import sys
import time
import datetime
import modbus_devices.aliexpress_screen as screen
import modbus_devices.sht30 as sht30
import mqtt_tools.mqtt_pub as mqtt

def main():
	
	screen.init_screen("192.168.1.40", 2)
	screen.clear_screen("192.168.1.40", 2)
	
	while True:
		time.sleep(1)
		values = sht30.get_values("192.168.1.40", 1)
		if values[0] is None:
			# Данные не получены – пропускаем запись и отправку
			return

		humidity_str, temperature_str, humidity_raw, temperature_raw = values
		
		# Отправка форматированных строк на устройство и в MQTT
		time.sleep(1)
		screen.send_string(humidity_str, "192.168.1.40", 2)
		mqtt.pub_string("cube-nas", "/modbus_devices/sht30/humidity", str(humidity_raw))

		time.sleep(1)
		screen.send_string(temperature_str, "192.168.1.40", 2)
		mqtt.pub_string("cube-nas", "/modbus_devices/sht30/tempetarure", str(temperature_raw))
		time.sleep(1)

if __name__ == "__main__":
	main()

