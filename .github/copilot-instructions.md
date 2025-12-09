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

### Critical: Script Loading Order

**IMPORTANT**: In `fxmanifest.lua`, `Config.lua` MUST be loaded BEFORE `functions.lua` in `shared_scripts`.

```lua
shared_scripts {
    'shared/config.lua',      -- Must be first!
    'shared/functions.lua',   -- Depends on Config
    -- ... other scripts
}
```

**Reason**: `functions.lua` references `Config.Logs.EnableConsole` and other Config values. Loading Config first prevents "attempt to index a nil value" errors.

### Database Configuration

1. **Database name**: Default is `'framework'` (see `Config.Database.Name` in `shared/config.lua`)
2. **SQL file location**: `framework/sql/framework.sql`
3. **Important**: Database must be created before server starts
4. **Database library**: Uses `oxmysql` (not the old LDC resource)
   - Add `@oxmysql/lib/MySQL.lua` to server_scripts
   - Add `oxmysql` to dependencies

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
       'shared/config.lua',
       'shared/functions.lua',
       'shared/serialization.lua',  -- Required for modules
       'modules/*.lua'
   }
   ```

### Using Hooks

The framework provides a hook system for extensibility:

```lua
-- Register a hook
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    -- Your code here
end, priority)

-- Trigger a hook
AMA.TriggerHook("hookName", arg1, arg2)
```

Common hooks:
- `ama:hook:playerLoaded` - When player data loads
- `ama:hook:playerSpawned` - When player spawns
- `ama:hook:moneyChanged` - When player money changes
- `ama:hook:beforeSave` - Before saving player data

## Testing and Debugging

1. **Debug mode**: Enable in `shared/config.lua`
   ```lua
   Config.Framework = {
       Debug = true
   }
   ```

2. **Console logging**: Enable/disable via Config
   ```lua
   Config.Logs.EnableConsole = true
   ```

## Best Practices

### Do's ✅

- Always validate player source before operations
- Use proper error handling with pcall/xpcall
- Follow the existing file naming conventions
- Use the framework's logging system
- Test with oxmysql dependency loaded
- Keep configuration in `shared/config.lua`
- Use hooks instead of modifying core files
- Maintain French comments and messages (framework is French-language)

### Don'ts ❌

- Don't modify files in `framework/version/` directory
- Don't use synchronous MySQL queries
- Don't break the Config loading order
- Don't use old MySQL libraries (e.g., LDC)
- Don't hardcode database names (use Config)
- Don't remove the `ama_` prefix from existing files
- Don't load version files in fxmanifest.lua

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

The framework includes Discord webhook integration:

```lua
Config.Discord = {
    Enabled = true,
    Webhooks = {
        Connection = "webhook_url",
        Disconnection = "webhook_url",
        -- etc.
    }
}
```

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
