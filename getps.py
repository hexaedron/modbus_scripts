#!/usr/bin/env python3
import os
import sys
import time
import datetime
import modbus_devices.aliexpress_screen as screen
import modbus_devices.sht30 as sht30
import modbus_devices.pzem_6l24 as pzem_6l24
import mqtt_tools.mqtt_pub as mqtt

def main():
	
	#screen.init_screen("192.168.1.40", 2)
	#screen.clear_screen("192.168.1.40", 2)
	
	while True:
		time.sleep(1)
		values = pzem_6l24.get_values("192.168.1.40", 18)
		if values[0] is None:
			# Данные не получены – пропускаем запись и отправку
			return

		volt_A, volt_B, volt_C, amp_A, amp_B, amp_C, freq_A, freq_B, freq_C = values
		
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/volt_A", str(volt_A))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/volt_B", str(volt_B))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/volt_C", str(volt_C))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/amp_A", str(amp_A))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/amp_B", str(amp_B))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/amp_C", str(amp_C))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/freq_A", str(freq_A))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/freq_B", str(freq_B))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/freq_C", str(freq_C))
		
		# Отправка форматированных строк на устройство и в MQTT
		#time.sleep(1)
		#screen.send_string(humidity_str, "192.168.1.40", 2)
		#mqtt.pub_string("cube-nas", "/modbus_devices/sht30/humidity", str(humidity_raw))

		#time.sleep(1)
		#screen.send_string(temperature_str, "192.168.1.40", 2)
		#mqtt.pub_string("cube-nas", "/modbus_devices/sht30/tempetarure", str(temperature_raw))
		#time.sleep(1)

if __name__ == "__main__":
	main()

