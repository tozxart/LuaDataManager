local Data = {}
local DataFunctions = {}
local Http = game:GetService("HttpService")

-- Helper function to safely encode JSON
local function safeJSONEncode(data)
    local success, result = pcall(Http.JSONEncode, Http, data)
    if not success then
        warn("Error encoding JSON:", result)
        return nil
    end
    return result
end

-- Helper function to safely decode JSON
local function safeJSONDecode(str)
    local success, result = pcall(Http.JSONDecode, Http, str)
    if not success then
        warn("Error decoding JSON:", result)
        return nil
    end
    return result
end

function Data.new(folderName, fileName, defaultData)
    assert(type(folderName) == "string", "folderName must be a string")
    assert(type(fileName) == "string", "fileName must be a string")
    assert(type(defaultData) == "table", "defaultData must be a table")

    if not isfolder(folderName) then
        makefolder(folderName)
    end

    local filePath = folderName .. "/" .. fileName
    local savedData

    if isfile(filePath) then
        savedData = safeJSONDecode(readfile(filePath))
    end

    if not savedData then
        savedData = table.clone(defaultData)
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
    writefile(filePath, safeJSONEncode(savedData))

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
    self.Data = table.clone(self.DefaultData)
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
        writefile(filePath, jsonData)
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
    return table.clone(self.Data)
end

function DataFunctions:Clear()
    self.Data = {}
    self:Save()
end

return Data
