-- Load the Rayfield UI Library
local Rayfield = loadstring(game:HttpGet(
    'https://raw.githubusercontent.com/tozxart/The-Intruders/main/ArrayFieldMain.lua'))())

-- Load the enhanced data module
local DataModule = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tozxart/LuaDataManager/main/DataManager.lua"))())

-- Available file systems
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

local LuaFileSystem = {
    -- ... (existing LuaFileSystem implementation)
}

-- Set the file system to Roblox (for Roblox environment)
DataModule.setFileSystem(RobloxFileSystem)

-- Note: You can create custom file systems or extend existing ones
-- Example of extending RobloxFileSystem:
-- local CustomFileSystem = table.clone(RobloxFileSystem)
-- CustomFileSystem.customFunction = function() ... end
-- DataModule.setFileSystem(CustomFileSystem)

-- Define default data
local defaultData = {
    AutoTrial = false,
    FarmOnTarget = false,
    SavedFarmPosition = "0, 0, 0"
}

-- Initialize player data
local playerName = game:GetService("Players").LocalPlayer.Name
local PlayerData = DataModule.new("The Intruders", playerName .. "_Settings.json", defaultData)

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "The Intruders",
    LoadingTitle = "The Intruders Interface Suite",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "The Intruders"
    }
})

-- Create the main tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- Create the Auto Farm section
local AutoFarmSection = MainTab:CreateSection("Auto Farm")

-- Update Farm Location button
MainTab:CreateButton({
    Name = "Update Farm Location",
    Info = "Updates the saved farm location to your current position",
    Interact = "Click",
    Callback = function()
        local currentPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        PlayerData:Set("SavedFarmPosition", tostring(currentPosition))
        Rayfield:Notify({
            Title = "Farm Location Updated",
            Content = "New position: " .. tostring(currentPosition),
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Auto Farm on Target toggle
MainTab:CreateToggle({
    Name = "Auto Farm on Target",
    Info = "Toggles auto farming on the target",
    CurrentValue = PlayerData:Get("FarmOnTarget"),
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        PlayerData:Set("FarmOnTarget", Value)
    end
})

-- Create the Settings section
local SettingsSection = MainTab:CreateSection("Settings")

-- Reset to Default Settings button
MainTab:CreateButton({
    Name = "Reset to Default Settings",
    Info = "Resets all settings to their default values",
    Interact = "Click",
    Callback = function()
        PlayerData:ResetToDefaults()
        Rayfield:Notify({
            Title = "Settings Reset",
            Content = "All settings have been reset to default values",
            Duration = 3,
            Image = 4483362458
        })
        -- Update UI elements to reflect default values
        Rayfield:SetValue("AutoFarmToggle", PlayerData:Get("FarmOnTarget"))
    end
})

-- Clear All Settings button
MainTab:CreateButton({
    Name = "Clear All Settings",
    Info = "Clears all saved settings",
    Interact = "Click",
    Callback = function()
        PlayerData:Clear()
        Rayfield:Notify({
            Title = "Settings Cleared",
            Content = "All settings have been cleared",
            Duration = 3,
            Image = 4483362458
        })
        -- Update UI elements to reflect cleared values
        Rayfield:SetValue("AutoFarmToggle", false)
    end
})

-- Example of using the Exists method
if PlayerData:Exists("CustomSetting") then
    print("Custom setting exists:", PlayerData:Get("CustomSetting"))
else
    print("Custom setting does not exist")
end

-- Example of using the GetAll method
local allSettings = PlayerData:GetAll()
for key, value in pairs(allSettings) do
    print(key, value)
end

-- Example of using the Delete method
PlayerData:Delete("TemporarySetting")

-- Example of using the Update method
MainTab:CreateButton({
    Name = "Update Multiple Settings",
    Info = "Updates multiple settings at once",
    Interact = "Click",
    Callback = function()
        PlayerData:Update({
            AutoTrial = true,
            FarmOnTarget = true,
            SavedFarmPosition = "10, 20, 30"
        })
        Rayfield:Notify({
            Title = "Settings Updated",
            Content = "Multiple settings have been updated",
            Duration = 3,
            Image = 4483362458
        })
        -- Update UI elements to reflect new values
        Rayfield:SetValue("AutoFarmToggle", PlayerData:Get("FarmOnTarget"))
    end
})

-- Add explanations about DataModule features
local InfoSection = MainTab:CreateSection("DataModule Info")

MainTab:CreateParagraph({
    Title = "About DataModule",
    Content = [[
DataModule is a flexible data management system that supports both Roblox and standard Lua environments.

Key features:
1. Easy-to-use API for data management
2. Automatic JSON encoding and decoding
3. Support for custom file systems
4. Error handling and input validation
5. Data integrity checks
6. Support for default values
7. Methods for resetting to defaults, clearing data, and checking for existing keys

You can extend or customize the file system by creating your own implementation and using the setFileSystem function.
    ]]
})

-- Example of error handling
MainTab:CreateButton({
    Name = "Test Error Handling",
    Info = "Attempts to set an invalid value",
    Interact = "Click",
    Callback = function()
        local success, error = pcall(function()
            PlayerData:Set("InvalidKey", {[{}] = "InvalidValue"})
        end)
        if not success then
            Rayfield:Notify({
                Title = "Error Handled",
                Content = "Attempted to set an invalid value. Error: " .. tostring(error),
                Duration = 5,
                Image = 4483362458
            })
        end
    end
})
