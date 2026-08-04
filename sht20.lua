local M = {}

function M.get_values(ip, modbus_addr)
    -- Формируем команду (предполагаем, что ip и modbus_addr не содержат спецсимволов)
    local cmd = "mbpoll -c2 -1 -q -t3:int16 -a" .. modbus_addr .. " " .. ip

    -- Запускаем процесс для чтения stdout
    local p = io.popen(cmd, 'r')
    if not p then
        io.stderr:write("Ошибка запуска утилиты mbpoll\n")
        return nil, nil, nil, nil
    end

    -- Считываем весь вывод
    local output = p:read("*a")
    -- Закрываем и проверяем код возврата (аналог check=True)
    local ok, err = p:close()
    if not ok then
        io.stderr:write(string.format("Ошибка получения данных: %s\n", err))
        return nil, nil, nil, nil
    end

    -- Удаляем завершающие переводы строк и разбиваем на строки
    output = output:gsub("[\r\n]+$", "")
    local lines = {}
    for line in output:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    if #lines < 3 then
        io.stderr:write("Недостаточно строк в выводе утилиты\n")
        return nil, nil, nil, nil
    end

    -- Вспомогательная функция: извлекает второе поле строки как число
    local function get_second_field(line)
        local parts = {}
        for part in line:gmatch("%S+") do
            table.insert(parts, part)
        end
        if #parts >= 2 then
            return tonumber(parts[2])
        end
        return nil
    end

    -- Извлекаем сырые значения (индексы строк и полей как в оригинале)
    local humidity_raw_num = get_second_field(lines[3])   -- третья строка, второе поле
    local temperature_raw_num = get_second_field(lines[2]) -- вторая строка, второе поле

    if not humidity_raw_num or not temperature_raw_num then
        io.stderr:write("Невозможно извлечь числа из вывода\n")
        return nil, nil, nil, nil
    end

    -- Масштабируем в реальные величины
    local humidity_raw = humidity_raw_num / 10
    local temperature_raw = temperature_raw_num / 10

    -- Форматируем строки с выравниванием по левому краю до 7 символов (ljust)
    local humidity_str = string.format("%-7s", string.format("%.1f %%", humidity_raw))
    local temperature_str = string.format("%-7s", string.format("%.1f c", temperature_raw))

    return humidity_str, temperature_str, humidity_raw, temperature_raw
end

return M
