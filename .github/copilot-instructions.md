# GitHub Copilot Instructions for AMA Framework

This document provides guidance for GitHub Copilot when working with the AMA Framework repository.

## Repository Overview

AMA Framework is a modern and optimized FiveM framework written in Lua, inspired by ESX. It manages player spawning, position saving, and persistent player data.

## Technology Stack

- **Language**: Lua 5.4
- **Platform**: FiveM (GTA V multiplayer)
- **Database**: MySQL/MariaDB via oxmysql
- **Framework Type**: Server-side game framework

## File Structure and Naming Conventions

### Directory Structure
```
framework/
├── client/          # Client-side scripts
├── server/          # Server-side scripts  
├── shared/          # Shared scripts (client & server)
├── modules/         # Extension modules
├── sql/            # Database schema
├── version/        # Alternative versions (NOT loaded by default)
└── fxmanifest.lua  # Resource manifest
```

### File Naming Conventions

1. **Server files use `ama_` prefix** (except `command.lua`)
   - Examples: `ama_done.lua`, `ama_player.lua`, `ama_discord.lua`, `ama_crew.lua`, `ama_bitcoin.lua`
   - Exception: `command.lua` (not `commands.lua`)

2. **Client files** have specific names:
   - `ama_add.lua`
   - `spwan.lua` (note: typo in original, kept for compatibility)
   - `event.lua` (not `events.lua`)

3. **Files in `framework/version/` directory**:
   - These are alternative versions
   - Should NOT be loaded by default in `fxmanifest.lua`

## Configuration Guidelines

### Configuration Structure

The Config object is defined directly in shared files rather than in a separate config file:

- **Discord configuration**: Defined in `shared/ama_discord.lua` as `Config.Discord`
- **Serialization configuration**: Defined in `shared/ama_run.lua` as `Config.Serialization`
- **Logging configuration**: `Config.Logs` is referenced in `functions.lua`

**Note**: The framework expects `Config` to be a global table that is populated by the shared scripts before `functions.lua` is loaded.

### Script Loading Order in fxmanifest.lua

Current loading order in `shared_scripts`:
```lua
shared_scripts {
    'shared/functions.lua',      -- Defines AMA global and logging
    'shared/serialization.lua',  -- Legacy serialization (not actively used)
    'shared/ama_run.lua',        -- Module/hook system + Config.Serialization
    'shared/ama_discord.lua'     -- Discord webhooks + Config.Discord
}
```

**Important**: If adding a dedicated `shared/config.lua` file, it MUST be loaded FIRST before `functions.lua` since `functions.lua` references `Config.Logs.EnableConsole`.

### Database Configuration

1. **SQL file location**: `framework/sql/framework.sql`
2. **Important**: Database must be created before server starts
3. **Database library**: Uses `oxmysql` (not the old LDC resource)
   - Add `@oxmysql/lib/MySQL.lua` to server_scripts
   - Add `oxmysql` to dependencies
4. **Table naming**: All tables use `ama_` prefix

## Coding Standards

### Lua Conventions

1. **Global object**: Use `AMA` as the main framework object
   ```lua
   AMA = {}
   AMA.Players = {}
   ```

2. **Function naming**: Use PascalCase for framework functions
   ```lua
   function AMA.GetPlayer(source)
   function AMA.GetDistance(coords1, coords2)
   ```

3. **Logging**: Use the framework's logging system
   ```lua
   AMA.Log("INFO", "Message here")
   AMA.Log("ERROR", "Error message")
   ```

4. **Comments**: Write comments in French (the framework is French-language)

### FiveM-Specific Patterns

1. **Server detection**:
   ```lua
   if IsDuplicityVersion() then
       -- Server-side code
   else
       -- Client-side code
   end
   ```

2. **Events**: Use prefixed event names
   ```lua
   RegisterNetEvent('ama:eventName')
   TriggerServerEvent('ama:serverEvent')
   ```

3. **Callbacks**: Framework provides callback system
   ```lua
   AMA.TriggerServerCallback('callbackName', function(result)
       -- Handle result
   end, arg1, arg2)
   ```

## Database Operations

1. **Always use oxmysql** for database operations
   ```lua
   MySQL.Await.execute('query', {params})
   MySQL.Await.fetchAll('query', {params})
   ```

2. **Table naming**: All tables use `ama_` prefix
   - `ama_players`
   - `ama_jobs`
   - `ama_job_grades`
   - `ama_crews`
   - `ama_bitcoin_transactions`
   - etc.

## Module System

### Creating Modules

The module system is defined in `shared/ama_run.lua`. To create a module:

1. Place modules in `framework/modules/`
2. Use the module registration system:
   ```lua
   local MyModule = {}
   
   function MyModule.Init()
       -- Initialization code
   end
   
   AMA.RegisterModule("my_module", MyModule)
   ```

3. Load modules in `fxmanifest.lua`:
   ```lua
   shared_scripts {
       'shared/functions.lua',
       'shared/serialization.lua',
       'shared/ama_run.lua',        -- Required for module system
       'shared/ama_discord.lua',
       'modules/*.lua'               -- Load all modules
   }
   ```

**Note**: The serialization system provides hooks, modules, metadata, and utility functions for extending the framework without modifying core files.

### Using Hooks

The framework provides a hook system for extensibility (defined in `shared/ama_run.lua`):

```lua
-- Register a hook
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    -- Your code here
end, priority)

-- Trigger a hook
AMA.TriggerHook("hookName", arg1, arg2)
```

Common hooks (see `shared/ama_run.lua` for complete list):
- `ama:hook:playerLoaded` - When player data loads
- `ama:hook:playerSpawned` - When player spawns
- `ama:hook:moneyChanged` - When player money changes
- `ama:hook:beforeSave` - Before saving player data

## Testing and Debugging

1. **Debug mode**: The framework supports debug mode that can be enabled for different systems:
   ```lua
   -- In the file where Config properties are defined
   Config.Framework = {
       Debug = true
   }
   
   Config.Serialization = {
       Debug = true  -- Defined in ama_run.lua
   }
   ```

2. **Console logging**: Control via Config (referenced in `functions.lua`):
   ```lua
   Config.Logs = {
       EnableConsole = true
   }
   ```

3. **Logging levels**:
   - DEBUG: Detailed information
   - INFO: General information
   - WARN: Warning messages
   - ERROR: Error messages

## Best Practices

### Do's ✅

- Always validate player source before operations
- Use proper error handling with pcall/xpcall
- Follow the existing file naming conventions
- Use the framework's logging system (`AMA.Log()`)
- Test with oxmysql dependency loaded
- Define Config properties in appropriate shared files (follow the pattern in `ama_discord.lua` and `ama_run.lua`)
- Use hooks instead of modifying core files
- Maintain French comments and messages (framework is French-language)
- Use the module system (`AMA.RegisterModule`) for extensions

### Don'ts ❌

- Don't modify files in `framework/version/` directory
- Don't use synchronous MySQL queries
- Don't use old MySQL libraries (e.g., LDC)
- Don't hardcode values that should be configurable
- Don't remove the `ama_` prefix from existing files
- Don't load version files in fxmanifest.lua
- Don't modify core framework files when hooks/modules can be used instead

## Common Patterns

### Player Object Structure

```lua
xPlayer = {
    source = source,
    identifier = identifier,
    name = name,
    money = money,
    bank = bank,
    job = job,
    job_grade = job_grade,
    group = group,
    position = {x, y, z},
    -- Methods
    addMoney = function(amount),
    removeMoney = function(amount),
    setJob = function(job, grade),
    -- etc.
}
```

### Saving Player Data

```lua
-- Position is saved automatically every 30 seconds (configurable)
-- Manual save:
TriggerEvent('ama:savePlayer', source)
```

### Distance Calculations

```lua
local dist = AMA.GetDistance(coords1, coords2)
if dist < 10.0 then
    -- Player is within 10 units
end
```

## Discord Integration

The framework includes Discord webhook integration configured in `shared/ama_discord.lua`:

```lua
Config.Discord = {
    Enabled = true,
    Webhooks = {
        Connection = "webhook_url",
        Disconnection = "webhook_url",
        PlayerData = "webhook_url",
        Transactions = "webhook_url",
        JobChanges = "webhook_url"
    },
    Colors = {
        Connection = 3066993,      -- Green
        Disconnection = 15158332,  -- Red
        PlayerData = 3447003,      -- Blue
        Transaction = 15844367,    -- Gold
        JobChange = 10181046       -- Purple
    },
    Settings = {
        SendFullDataOnConnect = true,
        SendOnlyTimeOnDisconnect = true,
        -- ... other settings
    }
}
```

Modify these values in `shared/ama_discord.lua` to configure Discord logging for your server.

## Security Considerations

1. **Input validation**: Always validate user input
2. **Permission checks**: Verify player permissions before admin commands
3. **SQL injection**: Use parameterized queries with oxmysql
4. **Rate limiting**: Implement for resource-intensive operations

## Documentation

- Main README: `framework/readme/readme.md`
- Database guide: `framework/readme/database.md`
- Additional docs in `framework/readme/` directory

## Support and Resources

- FiveM documentation: https://docs.fivem.net/
- Lua 5.4 reference: https://www.lua.org/manual/5.4/
- oxmysql documentation: https://github.com/overextended/oxmysql

---

**Note**: This framework is designed for FiveM servers and follows FiveM-specific patterns and conventions. When suggesting code, ensure compatibility with the FiveM runtime environment.
