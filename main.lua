#!/usr/bin/env lua

-- Подключаем модули (имена файлов без .lua)
local mqtt = require("mqtt")
local pzem = require("pzem_6l24")
local sht30 = require("sht30")

while true do
    os.execute("sleep 1")  

    -- Получаем данные с устройства pzem_6l24
    local volt_A, volt_B, volt_C, amp_A, amp_B, amp_C, freq_A, freq_B, freq_C =
        pzem.get_values("192.168.1.40", 18)

    -- Если ошибка – завершаем скрипт
    if volt_A == nil then
        return
    else
		-- Отправляем значения по MQTT
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/volt_A", tostring(volt_A))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/volt_B", tostring(volt_B))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/volt_C", tostring(volt_C))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/amp_A",  tostring(amp_A))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/amp_B",  tostring(amp_B))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/amp_C",  tostring(amp_C))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/freq_A", tostring(freq_A))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/freq_B", tostring(freq_B))
		mqtt.pub_string("cube-nas", "/modbus_devices/pzem_6l24/freq_C", tostring(freq_C))
    end
    
    -- Получаем данные с устройства sht30
    local humidity_str, temperature_str, humidity_raw, temperature_raw = sht30.get_values("192.168.1.40", 1)
    
    if humidity_str == nil then
		return
	else
		mqtt.pub_string("cube-nas", "/modbus_devices/sht30/humidity", tostring(humidity_raw))
		mqtt.pub_string("cube-nas", "/modbus_devices/sht30/tempetarure", tostring(temperature_raw))
	end
    
end
