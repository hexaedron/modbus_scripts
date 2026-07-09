#!/usr/bin/env python3
import os
import sys
import time
import datetime
import modbus_devices.aliexpress_screen as screen
import modbus_devices.sht30 as sht30

def main():
	
	screen.init_screen("192.168.1.40", 2)
	
	while True:		
		values = sht30.get_values()
		if values[0] is None:
			# Данные не получены – пропускаем запись и отправку
			return

		humidity_str, temperature_str, humidity_raw, temperature_raw = values

		# Сохранение в CSV
		timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
		try:
			with open("temp_hum.csv", "a") as f:
				f.write(f"{timestamp};{humidity_raw};{temperature_raw}\n")
		except IOError as e:
			sys.stderr.write(f"Ошибка записи в CSV: {e}\n")

		# Отправка форматированных строк на устройство
		time.sleep(1)
		screen.send_string(humidity_str, "192.168.1.40", 2)

		time.sleep(1)
		screen.send_string(temperature_str, "192.168.1.40", 2)
		time.sleep(1)

if __name__ == "__main__":
	main()

