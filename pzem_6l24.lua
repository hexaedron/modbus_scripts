-- pzem_6l24.lua
local M = {}

function M.get_values(ip, modbus_addr)
    local cmd = "mbpoll -c9 -1 -q -t3:int16 -a" .. modbus_addr .. " " .. ip
    local p = io.popen(cmd, 'r')
    if not p then
        io.stderr:write("Ошибка запуска утилиты mbpoll\n")
        return nil, nil, nil, nil, nil, nil, nil, nil, nil
    end
    local output = p:read("*a")
    local ok, err = p:close()
    if not ok then
        io.stderr:write(string.format("Ошибка получения данных: %s\n", err))
        return nil, nil, nil, nil, nil, nil, nil, nil, nil
    end
    output = output:gsub("[\r\n]+$", "")
    local lines = {}
    for line in output:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    if #lines < 10 then
        io.stderr:write("Недостаточно строк в выводе утилиты\n")
        return nil, nil, nil, nil, nil, nil, nil, nil, nil
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
    local raw_volt_A = get_second_field(lines[2])
    local raw_volt_B = get_second_field(lines[3])
    local raw_volt_C = get_second_field(lines[4])
    local raw_amp_A  = get_second_field(lines[5])
    local raw_amp_B  = get_second_field(lines[6])
    local raw_amp_C  = get_second_field(lines[7])
    local raw_freq_A = get_second_field(lines[8])
    local raw_freq_B = get_second_field(lines[9])
    local raw_freq_C = get_second_field(lines[10])
    if not (raw_volt_A and raw_volt_B and raw_volt_C and raw_amp_A and raw_amp_B and raw_amp_C and raw_freq_A and raw_freq_B and raw_freq_C) then
        io.stderr:write("Невозможно извлечь числа из вывода\n")
        return nil, nil, nil, nil, nil, nil, nil, nil, nil
    end
    local function swap_bytes(val)
        local high = math.floor(val / 256)
        local low = val % 256
        return low * 256 + high
    end
    local volt_A = swap_bytes(raw_volt_A) / 10
    local volt_B = swap_bytes(raw_volt_B) / 10
    local volt_C = swap_bytes(raw_volt_C) / 10
    local amp_A  = swap_bytes(raw_amp_A)  / 100
    local amp_B  = swap_bytes(raw_amp_B)  / 100
    local amp_C  = swap_bytes(raw_amp_C)  / 100
    local freq_A = swap_bytes(raw_freq_A) / 100
    local freq_B = swap_bytes(raw_freq_B) / 100
    local freq_C = swap_bytes(raw_freq_C) / 100
    return volt_A, volt_B, volt_C, amp_A, amp_B, amp_C, freq_A, freq_B, freq_C
end

return M
