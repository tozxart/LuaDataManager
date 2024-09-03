local Data = {}
local DataFunctions = {}

-- FileSystem interface
local FileSystem = {
    readFile = nil,
    writeFile = nil,
    appendFile = nil,
    isFile = nil,
    isFolder = nil,
    makeFolder = nil,
    deleteFolder = nil,
    deleteFile = nil,
    listFiles = nil
}

-- Default implementation (Roblox)
local RobloxFileSystem = {
    readFile = readfile,
    writeFile = writefile,
    appendFile = appendfile,
    isFile = isfile,
    isFolder = isfolder,
    makeFolder = makefolder,
    deleteFolder = delfolder,
    deleteFile = delfile,
    listFiles = listfiles
}

-- Standard Lua filesystem implementation
local luaFileSystem = {
    readFile = function(path)
        local file = io.open(path, "r")
        if not file then return nil end
        local content = file:read("*all")
        file:close()
        return content
    end,
    writeFile = function(path, content)
        local file, err = io.open(path, "w")
        if not file then
            print("Error opening file for writing:", err)
            return false
        end
        file:write(content)
        file:close()
        return true
    end,
    appendFile = function(path, content)
        local file, err = io.open(path, "a")
        if not file then
            print("Error opening file for appending:", err)
            return false
        end
        file:write(content)
        file:close()
        return true
    end,
    isFile = function(path)
        local file = io.open(path, "r")
        if file then
            file:close()
            return true
        end
        return false
    end,
    isFolder = function(path)
        local success, _, code = os.rename(path, path)
        if not success and code == 13 then
            return true
        end
        return success
    end,
    makeFolder = function(path)
        local command
        if package.config:sub(1, 1) == '\\' then
            -- Windows
            command = 'mkdir "' .. path .. '"'
        else
            -- Unix-based systems
            command = 'mkdir -p "' .. path .. '"'
        end
        local success = os.execute(command)
        if success ~= 0 then
            print("Error creating folder:", path)
            return false
        end
        return true
    end,
    deleteFolder = function(path)
        return os.execute("rm -r " .. path) == 0
    end,
    deleteFile = function(path)
        return os.remove(path)
    end,
    listFiles = function(path)
        local files = {}
        for file in io.popen('dir "' .. path .. '" /b'):lines() do
            table.insert(files, file)
        end
        return files
    end
}

-- Set the current file system (default to Roblox)
local currentFileSystem = luaFileSystem

-- Function to set custom file system functions
function Data.setFileSystem(customFileSystem)
    for key, func in pairs(customFileSystem) do
        if type(func) == "function" then
            currentFileSystem[key] = func
        end
    end
end

-- Minimal JSON library
local json = {
    encode = function(tbl)
        local function serialize(tbl)
            local result = {}
            for k, v in pairs(tbl) do
                local key = type(k) == "string" and '"' .. k .. '"' or k
                local value = type(v) == "table" and serialize(v) or '"' .. tostring(v) .. '"'
                table.insert(result, key .. ":" .. value)
            end
            return "{" .. table.concat(result, ",") .. "}"
        end
        return serialize(tbl)
    end,
    decode = function(str)
        local function parse(str)
            local result = {}
            for k, v in string.gmatch(str, '"(.-)":(.-)[,}]') do
                result[k] = v:match('^"(.*)"$') or v
            end
            return result
        end
        return parse(str)
    end
}

-- Custom clone function that works in both Roblox and Lua
local function deepClone(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepClone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Helper function to safely encode JSON
local function safeJSONEncode(data)
    if currentFileSystem == RobloxFileSystem then
        local success, result = pcall(function()
            local HttpService = game:GetService("HttpService")
            return HttpService:JSONEncode(data)
        end)
        if not success then
            warn("Error encoding JSON:", result)
            return nil
        end
        return result
    else
        -- Use the minimal JSON library for non-Roblox environments
        local success, result = pcall(json.encode, data)
        if not success then
            warn("Error encoding JSON:", result)
            return nil
        end
        return result
    end
end

-- Helper function to safely decode JSON
local function safeJSONDecode(str)
    if currentFileSystem == RobloxFileSystem then
        local success, result = pcall(function()
            local HttpService = game:GetService("HttpService")
            return HttpService:JSONDecode(str)
        end)
        if not success then
            warn("Error decoding JSON:", result)
            return nil
        end
        return result
    else
        -- Use the minimal JSON library for non-Roblox environments
        local success, result = pcall(json.decode, str)
        if not success then
            warn("Error decoding JSON:", result)
            return nil
        end
        return result
    end
end

-- Custom table.clone function for Lua environment
local function tableClone(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = tableClone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Data.new(folderName, fileName, defaultData)
    assert(type(folderName) == "string", "folderName must be a string")
    assert(type(fileName) == "string", "fileName must be a string")
    assert(type(defaultData) == "table", "defaultData must be a table")

    if not currentFileSystem.isFolder(folderName) then
        print("Creating folder:", folderName)
        currentFileSystem.makeFolder(folderName)
    end

    local filePath = folderName .. "/" .. fileName
    local savedData

    if currentFileSystem.isFile(filePath) then
        savedData = safeJSONDecode(currentFileSystem.readFile(filePath))
    end

    if not savedData then
        savedData = deepClone(defaultData)
    else
        -- Update savedData with any missing default values
        for key, value in pairs(defaultData) do
            if savedData[key] == nil then
                savedData[key] = value
            end
        end
    end

    -- Remove any keys in savedData that are not in defaultData
    for key in pairs(savedData) do
        if defaultData[key] == nil then
            savedData[key] = nil
        end
    end

    -- Always write the file to ensure it's up to date
    print("Writing file:", filePath)
    currentFileSystem.writeFile(filePath, safeJSONEncode(savedData))

    return setmetatable({
        Data = savedData,
        FolderName = folderName,
        FileName = fileName,
        DefaultData = defaultData
    }, {
        __index = DataFunctions
    })
end

function DataFunctions:ResetToDefaults()
    self.Data = currentFileSystem == RobloxFileSystem and table.clone(self.DefaultData) or tableClone(self.DefaultData)
    self:Save()
end

function DataFunctions:Update(data)
    assert(type(data) == "table", "Update data must be a table")
    for key, value in pairs(data) do
        self.Data[key] = value
    end
    self:Save()
end

function DataFunctions:Set(name, value)
    assert(type(name) == "string", "Key must be a string")
    self.Data[name] = value
    self:Save()
end

function DataFunctions:Get(name)
    assert(type(name) == "string", "Key must be a string")
    return self.Data[name]
end

function DataFunctions:Save()
    local filePath = self.FolderName .. "/" .. self.FileName
    local jsonData = safeJSONEncode(self.Data)
    if jsonData then
        print("Saving data to file:", filePath)
        currentFileSystem.writeFile(filePath, jsonData)
    else
        warn("Failed to save data due to JSON encoding error")
    end
end

function DataFunctions:Delete(name)
    assert(type(name) == "string", "Key must be a string")
    self.Data[name] = nil
    self:Save()
end

function DataFunctions:Exists(name)
    assert(type(name) == "string", "Key must be a string")
    return self.Data[name] ~= nil
end

function DataFunctions:GetAll()
    return deepClone(self.Data)
end

function DataFunctions:Clear()
    self.Data = {}
    self:Save()
end

return Data
