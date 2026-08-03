import subprocess
import sys

def get_values(ip, modbus_addr):
	"""
	Вызывает внешнюю утилиту mbpoll с заданными параметрами,
	извлекает из вывода два числа и возвращает их
	в виде форматированных строк, а также сырые значения.

	Returns:
		tuple: (volt_A, volt_B, volt_C, amp_A, amp_B, amp_C, freq_A, freq_B, freq_C)
			   или (None, None, None, None, None, None, None, None, None) при ошибке.
	"""
	cmd = ["mbpoll", "-c9", "-1", "-q", "-t3:int16", "-a" + str(modbus_addr), ip]

	try:
		result = subprocess.run(cmd, capture_output=True, text=True, check=True)
	except (subprocess.CalledProcessError, FileNotFoundError) as e:
		sys.stderr.write(f"Ошибка получения данных: {e}\n")
		return None, None, None, None, None, None, None, None, None

	lines = result.stdout.strip().splitlines()
	if len(lines) < 10:
		sys.stderr.write("Недостаточно строк в выводе утилиты\n")
		return None, None, None, None, None, None, None, None, None

	volt_A = int(lines[1].split()[1]) 
	volt_B = int(lines[2].split()[1])
	volt_C = int(lines[3].split()[1])
	amp_A  = int(lines[4].split()[1])
	amp_B  = int(lines[5].split()[1])
	amp_C  = int(lines[6].split()[1])
	freq_A = int(lines[7].split()[1])
	freq_B = int(lines[8].split()[1])
	freq_C = int(lines[9].split()[1])
	
	# Переставляем байты местами
	volt_A = ((volt_A & 0xFF) << 8) | ((volt_A >> 8) & 0xFF)
	volt_B = ((volt_B & 0xFF) << 8) | ((volt_B >> 8) & 0xFF)
	volt_C = ((volt_C & 0xFF) << 8) | ((volt_C >> 8) & 0xFF)
	amp_A  = ((amp_A  & 0xFF) << 8) | ((amp_A  >> 8) & 0xFF)
	amp_B  = ((amp_B  & 0xFF) << 8) | ((amp_B  >> 8) & 0xFF)
	amp_C  = ((amp_C  & 0xFF) << 8) | ((amp_C  >> 8) & 0xFF)
	freq_A = ((freq_A & 0xFF) << 8) | ((freq_A >> 8) & 0xFF)
	freq_B = ((freq_B & 0xFF) << 8) | ((freq_B >> 8) & 0xFF)
	freq_C = ((freq_C & 0xFF) << 8) | ((freq_C >> 8) & 0xFF)

	return volt_A / 10, volt_B / 10, volt_C / 10, amp_A / 100, amp_B / 100, amp_C / 100, freq_A / 100, freq_B / 100, freq_C / 100
