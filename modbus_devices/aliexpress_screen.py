import subprocess

def init_screen(ip, modbus_addr):
	"""
	Инициализирует экранчик с Алиэкспресса.
	"""
	
	cmd = [
		"mbpoll",
		"-t4",
		"-r24",
		"-a" + str(modbus_addr),
		"-q",
		ip,
		"2"
	] 

	try:
		subprocess.run(cmd, check=True)
	except subprocess.CalledProcessError as e:
		sys.stderr.write(f"Ошибка отправки данных: {e}\n")
	except FileNotFoundError:
		sys.stderr.write("Файл mbpoll не найден\n")

def send_string(data_str, ip, modbus_addr):
	"""
	Преобразует строку data_str в последовательность 16-битных hex-слов
	и отправляет их командой mbpoll на экранчик с Алиэкспресса.
	"""
	hex_values = []
	length = len(data_str)
	if length > 6: length = 6

	for i in range(0, length, 2):
		if i + 1 < len(data_str):
			word = (ord(data_str[i]) << 8) | ord(data_str[i+1])
		else:
			word = ord(data_str[i]) << 8
		hex_values.append(f"0x{word:04X}")

	cmd = [
		"mbpoll",
		"-t4",
		"-r6",
		"-a" + str(modbus_addr),
		"-q",
		ip
	] + hex_values

	try:
		subprocess.run(cmd, check=True)
	except subprocess.CalledProcessError as e:
		sys.stderr.write(f"Ошибка отправки данных: {e}\n")
	except FileNotFoundError:
		sys.stderr.write("Файл mbpoll не найден\n")
