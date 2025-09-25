![KCDUtils – 9 out of 10 blacksmiths praise it… the 10th burned his forge.](https://i.imgur.com/OJsBmGU.png)

# KCDUtils

**Version:** <!--VERSION-->0.4.1<!--/VERSION-->  
**Author:** Destuur  
**Game:** Kingdom Come: Deliverance 2  



## Overview

**KCDUtils** is a collection of Lua utilities designed to simplify modding in **Kingdom Come: Deliverance 2**.  
It provides ready-to-use functions, helpers, and a consistent framework for creating Lua-based mods.



## Features

- Modular utility scripts organized under `Scripts/Mods/KCDUtils`.  
- Core loader file: `kcdutils.lua`.  
- Helper functions for common gameplay modifications, event handling, and data management.  
- Fully structured mod folder with `mod.manifest` for seamless integration.  
- Namespaced under `KCDUtils` to prevent conflicts with other mods.



## Installation

1. Download the latest release ZIP.  
2. Extract the contents into your `Mods` folder:
    ```
    ../KingdomComeDeliverance2/Mods/
    ```
3. Folder structure:

    kcdutils/
      Data/
        kcdutils/
          Scripts/
            Mods/
              kcdutils.lua
              KCDUtils/
                (all utility Lua files)
      mod.manifest



## Dependencies

- **LuaDB** is required only if you want to use database-related utilities.
  Players using mods depending on KCDUtils with DB functionality must also have LuaDB installed: [LuaDB on Nexus Mods](https://www.nexusmods.com/kingdomcomedeliverance2/mods/1523).

### Be aware, that also KCDUtils.Config uses LuaDB, to persist config values.



## Usage

> [!IMPORTANT]
> Before using instantiated KCDUtils functions in your mod, you **must register your mod** with `KCDUtils.RegisterMod()`.  
> This ensures that the DB, Logger, Config, and other utility tables are correctly instantiated and namespaced.

1. Set table at the top of your entry .lua file:  

    ```lua
    {{MODNAME_CLASS}} = {{MODNAME_CLASS}} or { Name = "{{MODNAME_CLASS}}" }
    ```

2. Register mod right after, and before calling your first function to get instantiated utils:  

    ```lua
    {{MODNAME_CLASS}}.DB, {{MODNAME_CLASS}}.Logger = KCDUtils.RegisterMod({{MODNAME_CLASS}})
    ```

3. Explore the scripts in `KCDUtils/` to see available helper functions.



## Notes

- KCDUtils is **standalone**, no other dependencies required for general utilities.  
- Future updates will include new utility functions and improvements.  



## License

This project is released under the MIT License. See the [`LICENSE`](https://github.com/Destuur/KCDUtils/blob/main/LICENSE) file for details.
Please credit the author **Destuur** and **KCDUtils framework** when using it in your mods, for example on Nexus Mods.
