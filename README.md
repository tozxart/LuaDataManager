# LuaDataManager

LuaDataManager is a robust and flexible data management module for Lua projects, with support for both Roblox and standard Lua environments. It provides an easy-to-use interface for saving, loading, and manipulating persistent data, making it ideal for storing user settings, game progress, and other types of data that need to persist between sessions.

## Features

- Easy-to-use API for data management
- Automatic JSON encoding and decoding
- Support for both Roblox and standard Lua environments
- Customizable file systems
- Error handling and input validation
- Data integrity checks
- Support for default values
- Methods for resetting to defaults, clearing data, and checking for existing keys
- Designed with game development in mind, but suitable for various Lua projects

## Installation

To use LuaDataManager in your project, simply copy the `DataManager.lua` file into your project directory or use it as a module.

For Roblox projects, you can load it directly from this GitHub repository:

```lua
local DataManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/tozxart/LuaDataManager/main/DataManager.lua"))()
```

## Usage

Here's a quick example of how to use LuaDataManager:

```lua
-- Define default data
local defaultData = {
    playerName = "Guest",
    score = 0,
    settings = {
        musicVolume = 0.5,
        sfxVolume = 0.7
    }
}

-- Initialize data manager
local dataManager = DataManager.new("MyGame", "playerData.json", defaultData)

-- Get a value
local playerName = dataManager:Get("playerName")

-- Set a value
dataManager:Set("score", 100)

-- Update multiple values
dataManager:Update({
    playerName = "John",
    settings = {
        musicVolume = 0.8
    }
})

-- Reset to default values
dataManager:ResetToDefaults()

-- Check if a key exists
if dataManager:Exists("customSetting") then
    print("Custom setting exists")
end

-- Get all data
local allData = dataManager:GetAll()

-- Clear all data
dataManager:Clear()
```

## UI Example

We've provided an example of how to use LuaDataManager with a UI library (Orion UI Library in this case). You can find this example in the `UIExample.lua` file. This example demonstrates:

- How to initialize the data manager
- How to create UI elements that interact with the data manager
- How to use various methods of the data manager within UI callbacks

## Customizing File Systems

LuaDataManager supports custom file systems. You can set a custom file system using the `setFileSystem` function:

```lua
local customFileSystem = {
    writeFile = function(fileName, data)
        -- Custom implementation for writing data to a file
    end,
    readFile = function(fileName)
        -- Custom implementation for reading data from a file
    end,
    -- ... other file system functions ...
}

DataManager.setFileSystem(customFileSystem)
```

The module comes with built-in support for Roblox and standard Lua file systems.

## API Reference

- `DataManager.new(folderName, fileName, defaultData)`: Create a new data manager instance
- `Set(key, value)`: Set a value for a specific key
- `Get(key)`: Get the value for a specific key
- `Update(data)`: Update multiple values at once
- `ResetToDefaults()`: Reset all data to default values
- `Clear()`: Remove all data
- `Exists(key)`: Check if a key exists
- `GetAll()`: Get all current data
- `Delete(key)`: Remove a specific key-value pair
- `Save()`: Manually save data (automatically called after changes)
- `setFileSystem(customFileSystem)`: Set a custom file system implementation

## Error Handling

LuaDataManager includes built-in error handling for JSON encoding and decoding operations. It will warn users of any errors that occur during these processes.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).
