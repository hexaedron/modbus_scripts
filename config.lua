-- config.lua
return {
    ip = "192.168.1.40",          -- общий IP для всех устройств Modbus
    mqtt_host = "cube-nas",       -- адрес/имя MQTT-брокера

    -- Настройки для каждого устройства
    pzem_enabled = true,          -- опрашивать PZEM-6L24?
    pzem_addr   = 18,             -- его Modbus-адрес

    sht30_enabled = false,
    sht30_addr   = 1
}
