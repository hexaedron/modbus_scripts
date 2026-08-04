#!/usr/bin/env lua

-- Подключаем модули
package.path = "/root/modbus_scripts/?.lua" -- Правильный путь для OpenWrt
local mqtt   = require("mqtt")
local pzem   = require("pzem_6l24")
local sht30  = require("sht30")
local config = require("config")

while true do
    os.execute("sleep 1")  

    -- ========== PZEM-6L24 ==========
    if config.pzem_enabled then
        local volt_A, volt_B, volt_C, amp_A, amp_B, amp_C, freq_A, freq_B, freq_C =
            pzem.get_values(config.ip, config.pzem_addr)

        if volt_A == nil then
            -- ошибка опроса – можно либо выйти, либо только пропустить отправку
            -- здесь выходим, как в оригинале
            return
        else
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/volt_A", tostring(volt_A))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/volt_B", tostring(volt_B))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/volt_C", tostring(volt_C))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/amp_A",  tostring(amp_A))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/amp_B",  tostring(amp_B))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/amp_C",  tostring(amp_C))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/freq_A", tostring(freq_A))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/freq_B", tostring(freq_B))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/pzem_6l24/freq_C", tostring(freq_C))
        end
    end

    -- ========== SHT30 ==========
    if config.sht30_enabled then
        local humidity_str, temperature_str, humidity_raw, temperature_raw =
            sht30.get_values(config.ip, config.sht30_addr)

        if humidity_str == nil then
            return   -- ошибка – завершаем скрипт
        else
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/sht30/humidity",    tostring(humidity_raw))
            mqtt.pub_string(config.mqtt_host, "/modbus_devices/sht30/temperature", tostring(temperature_raw))
        end
    end
end
