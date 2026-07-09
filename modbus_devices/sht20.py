import subprocess

def get_values(ip, modbus_addr):
	"""
	Вызывает внешнюю утилиту mbpoll с заданными параметрами,
	извлекает из вывода два числа и возвращает их
	в виде форматированных строк, а также сырые значения.

	Returns:
		tuple: (humidity_str, temperature_str, humidity_raw, temperature_raw)
			   или (None, None, None, None) при ошибке.
	"""
	cmd = ["mbpoll", "-c2", "-1", "-q", "-t3:int16", "-a" + str(modbus_addr), ip]

	try:
		result = subprocess.run(cmd, capture_output=True, text=True, check=True)
	except (subprocess.CalledProcessError, FileNotFoundError) as e:
		sys.stderr.write(f"Ошибка получения данных: {e}\n")
		return None, None, None, None

	lines = result.stdout.strip().splitlines()
	if len(lines) < 3:
		sys.stderr.write("Недостаточно строк в выводе утилиты\n")
		return None, None, None, None

	humidity_raw = int(lines[2].split()[1]) / 10
	temperature_raw = int(lines[1].split()[1]) / 10

	humidity_str = f"{humidity_raw} %".ljust(7)
	temperature_str = f"{temperature_raw} c".ljust(7)

	return humidity_str, temperature_str, humidity_raw, temperature_raw
