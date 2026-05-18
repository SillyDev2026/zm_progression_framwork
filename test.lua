EnableGlobals()

local IO = require("io")
local save = [[.\players\stats_zm_0.cgp]]
local encryptionkey = 1337

CoD.SaveData = {}

local function SplitString(str, sep)
    local result = {}

    for match in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(result, match)
    end

    return result
end

function FileExists(path)
    local file = io.open(path, "r")

    if file then
        file:close()
        return true
    end

    return false
end

local function Encrypt(value)
    local result = ""

    value = tostring(value)

    for i = 1, #value do
        local c = string.byte(value, i)
        result = result .. string.char(bit.bxor(c, encryptionkey % 255))
    end

    return result
end

local function Decrypt(value)
    local result = ""

    for i = 1, #value do
        local c = string.byte(value, i)
        result = result .. string.char(bit.bxor(c, encryptionkey % 255))
    end

    return result
end

local function CreateDefaultData()
    return {
        xp = 0,
        level = 1,
        prestige = 0,
        kills = 0,
        headshots = 0,
        games_played = 0,
        highest_round = 0
    }
end

local SetUpInfomationValuesTable = function()
    local result = {}

    local tableName = "gamedata/leveling/saving_data_index.csv"
    local rowCount = Engine.TableGetRowCount(tableName)

    for index = 0, rowCount - 1 do
        local dataName = Engine.TableGetColumnValueForRow(tableName, index, 1)

        if dataName ~= nil and dataName ~= "" then
            result[dataName] = 0
        end
    end

    return result
end

local function SerializeTable(tbl)
    local result = ""

    for key, value in pairs(tbl) do
        result = result .. tostring(key) .. "=" .. tostring(value) .. "\n"
    end

    return result
end

local function DeserializeTable(data)
    local result = {}

    for line in string.gmatch(data, "[^\r\n]+") do
        local split = SplitString(line, "=")

        if split[1] and split[2] then
            local key = split[1]
            local value = tonumber(split[2]) or split[2]

            result[key] = value
        end
    end

    return result
end

function CoD.SaveData.Save()
    local file = io.open(save, "w+")

    if not file then
        print("[SAVE SYSTEM] Failed to open save file")
        return false
    end

    local serialized = SerializeTable(CoD.SaveData.Data)
    local encrypted = Encrypt(serialized)

    file:write(encrypted)
    file:close()

    print("[SAVE SYSTEM] Save successful")

    return true
end

function CoD.SaveData.Load()
    if not FileExists(save) then
        print("[SAVE SYSTEM] Save file missing, creating new one")

        CoD.SaveData.Data = CreateDefaultData()
        CoD.SaveData.Save()

        return
    end

    local file = io.open(save, "rb")

    if not file then
        print("[SAVE SYSTEM] Failed to open save file")

        CoD.SaveData.Data = CreateDefaultData()
        return
    end

    local encrypted = file:read("*all")
    file:close()

    if not encrypted or encrypted == "" then
        print("[SAVE SYSTEM] Save file empty")

        CoD.SaveData.Data = CreateDefaultData()
        CoD.SaveData.Save()

        return
    end

    local decrypted = Decrypt(encrypted)
    local loadedData = DeserializeTable(decrypted)

    if not loadedData then
        print("[SAVE SYSTEM] Failed to deserialize save")

        CoD.SaveData.Data = CreateDefaultData()
        return
    end

    CoD.SaveData.Data = loadedData

    print("[SAVE SYSTEM] Save loaded")
    print("XP: " .. tostring(CoD.SaveData.Data.xp))
    print("LEVEL: " .. tostring(CoD.SaveData.Data.level))
end

function CoD.SaveData.Reset()
    CoD.SaveData.Data = CreateDefaultData()
    CoD.SaveData.Save()

    print("[SAVE SYSTEM] Data reset")
end

function CoD.SaveData.Init()
    print("[SAVE SYSTEM] Initializing")

    CoD.SaveData.Data = CreateDefaultData()

    CoD.SaveData.Load()
end

function CoD.SaveData.Debug()
    print("===== SAVE DATA =====")

    for key, value in pairs(CoD.SaveData.Data) do
        print(tostring(key) .. " = " .. tostring(value))
    end
end

CoD.SaveData.Init()

print("Testing Save System...")

return CoD