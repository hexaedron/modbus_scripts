-- screen.lua
local M = {}

-- Внутренняя вспомогательная функция: запуск mbpoll с проверкой ошибок
local function run_mbpoll(cmd)
    local p = io.popen(cmd, 'r')
    if not p then
        io.stderr:write("Файл mbpoll не найден\n")
        return false
    end
    local ok, err = p:close()
    if not ok then
        io.stderr:write(string.format("Ошибка отправки данных: %s\n", err))
        return false
    end
    return true
end

--- Инициализирует экранчик с Алиэкспресса (запись в регистр 24 значения 2)
function M.init_screen(ip, modbus_addr)
    local cmd = "mbpoll -t4 -r24 -a" .. modbus_addr .. " -q " .. ip .. " 2"
    run_mbpoll(cmd)
end

--- Очищает экранчик (отправляет 6 пробелов)
function M.clear_screen(ip, modbus_addr)
    M.send_string("      ", ip, modbus_addr)
end

--- Отправляет строку на экран.
-- Преобразует не более 6 символов в 16-битные hex-слова и записывает их
-- в регистры, начиная с 6.
function M.send_string(data_str, ip, modbus_addr)
    -- Ограничиваем длину строки максимум 6 символами
    local s = data_str:sub(1, 6)

    -- Собираем hex-слова
    local hex_values = {}
    local len = #s
    local i = 1
    while i <= len do
        local b1 = string.byte(s, i)
        local b2 = string.byte(s, i + 1)  -- если i+1 > len, будет nil
        local word
        if b2 then
            word = (b1 << 8) | b2
        else
            word = b1 << 8
        end
        table.insert(hex_values, string.format("0x%04X", word))
        i = i + 2
    end

    -- Формируем команду: mbpoll -t4 -r6 -a<addr> -q <ip> [hex-слова...]
    local cmd_parts = {
        "mbpoll", "-t4", "-r6",
        "-a" .. modbus_addr,
        "-q", ip
    }
    for _, val in ipairs(hex_values) do
        table.insert(cmd_parts, val)
    end
    local cmd = table.concat(cmd_parts, " ")

    run_mbpoll(cmd)
end

return M
