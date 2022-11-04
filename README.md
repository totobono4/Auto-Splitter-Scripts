🌏 [Documentation Française](README.fr.md)

# Auto-Splitter-Scripts
Some auto splitter scripts I made.

## LUA Scripts

### *Installation*

**Prerequisites**: 
- Emulator Bizhawk
- LiveSplit 1.7+

Open EmuHawk.exe, then go to the `Tools` tab and open the `Lua Console` in order to insert the `LUA` script.

Once you have the `LUA Console` opened, go to `Script` -> `Open script` and select the `.lua` file you want.

Don't forget to keep the `LUA Console` tab opened to keep the script active!

## Troubleshooting

### I get "Failed to open LiveSplit named pipe!"

```
NLua.Exceptions.LuaScriptException: [string "main"]:15: 
Failed to open LiveSplit named pipe!
Please make sure LiveSplit is running and is at least 1.7, then load this script againNLua.Exceptions.LuaScriptException: [string "main"]:15: 
Failed to open LiveSplit named pipe!
Please make sure LiveSplit is running and is at least 1.7, then load this script again
```

If this happens, it's probably a right management issue. Livesplit shouldn't be located in a protected folder such as `C:\Program Files\`.

Make sure both Livesplit and Bizhawk executables are running outside of a protected folder. (for example, place them in `C:\Users\Username\My Documents\`).
