-- Load the Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/tozxart/The-Intruders/main/ArrayFieldMain.lua'))()

-- Load the enhanced data module
local DataModule = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tozxart/LuaDataManager/main/DataManager.lua"))()

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
