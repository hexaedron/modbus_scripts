import subprocess

def pub_string(mqtt_ip, mqtt_topic, data_str):
	"""
	Отправляет строчку в топик
	"""
	
	cmd = [
		"mosquitto_pub",
		"-h",
		mqtt_ip,
		"-p", "1883",
		"-t",  mqtt_topic,
		"-m",  data_str
	] 

	try:
		subprocess.run(cmd, check=True)
	except subprocess.CalledProcessError as e:
		sys.stderr.write(f"Ошибка отправки данных: {e}\n")
	except FileNotFoundError:
		sys.stderr.write("Файл mosquitto_pub не найден\n")
