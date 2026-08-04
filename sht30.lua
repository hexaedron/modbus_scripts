function get_values(ip, modbus_addr)
    -- Изменён тип регистров: -t4:int16
    local cmd = "mbpoll -c2 -1 -q -t4:int16 -a" .. modbus_addr .. " " .. ip

    local p = io.popen(cmd, 'r')
    if not p then
        io.stderr:write("Ошибка запуска утилиты mbpoll\n")
        return nil, nil, nil, nil
    end

    local output = p:read("*a")
    local ok, err = p:close()
    if not ok then
        io.stderr:write(string.format("Ошибка получения данных: %s\n", err))
        return nil, nil, nil, nil
    end

    output = output:gsub("[\r\n]+$", "")
    local lines = {}
    for line in output:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    if #lines < 3 then
        io.stderr:write("Недостаточно строк в выводе утилиты\n")
        return nil, nil, nil, nil
    end

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

    -- Порядок извлечения изменён: humidity из lines[2] (вторая строка), temperature из lines[3] (третья)
    local humidity_raw_num = get_second_field(lines[2])
    local temperature_raw_num = get_second_field(lines[3])

    if not humidity_raw_num or not temperature_raw_num then
        io.stderr:write("Невозможно извлечь числа из вывода\n")
        return nil, nil, nil, nil
    end

    local humidity_raw = humidity_raw_num / 10
    local temperature_raw = temperature_raw_num / 10

    -- Выравнивание до 6 символов
    local humidity_str = string.format("%-6s", string.format("%.1f %%", humidity_raw))
    local temperature_str = string.format("%-6s", string.format("%.1f c", temperature_raw))

    return humidity_str, temperature_str, humidity_raw, temperature_raw
end
