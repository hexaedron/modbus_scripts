-- mqtt.lua
local M = {}

function M.pub_string(mqtt_ip, mqtt_topic, data_str)
    local cmd = "mosquitto_pub -h " .. mqtt_ip .. " -p 1883 -t " .. mqtt_topic .. " -m " .. data_str
    local p = io.popen(cmd, 'r')
    if not p then
        io.stderr:write("Файл mosquitto_pub не найден\n")
        return false
    end
    local ok, err = p:close()
    if not ok then
        io.stderr:write(string.format("Ошибка отправки данных: %s\n", err))
        return false
    end
    return true
end

return M
