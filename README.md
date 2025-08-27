# KCDUtils

**Version:** <!--VERSION-->0.0.19<!--/VERSION-->
**Author:** Destuur  
**Game:** Kingdom Come: Deliverance 2  

---

## Overview

**KCDUtils** is a collection of Lua utilities designed to simplify modding in **Kingdom Come: Deliverance 2**.  
It provides ready-to-use functions, helpers, and a consistent framework for creating Lua-based mods.

---

## Features

- Modular utility scripts organized under `Scripts/Mods/Utils`.  
- Core loader file: `kcdutils.lua`.  
- Helper functions for common gameplay modifications, event handling, and data management.  
- Fully structured mod folder with `mod.manifest` for seamless integration.  
- Namespaced under `KCDUtils` to prevent conflicts with other mods.

---

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
              Utils/
                (all utility Lua files)
      mod.manifest

4. Reference `kcdutils.lua` in your own Lua mods as needed.

---

## Dependencies

- **LuaDB** is required only if you want to use database-related utilities.  
  Players using mods depending on KCDUtils with DB functionality must also have LuaDB installed: [LuaDB on Nexus Mods](https://www.nexusmods.com/kingdomcomedeliverance2/mods/1523).

---

## Usage

1. Set table at the top of your entry .lua file:  

    ```lua
    {{MODNAME_CLASS}} = {{MODNAME_CLASS}} or {
        Name = "{{MODNAME_CLASS}}",
        DB = nil,
        Logger = nil,
        Config = nil
    }
    ```

2. Register mod first in your initialization and get instantiated utils:  

    ```lua
    function {{MODNAME_CLASS}}.Init()
        KCDUtils.RegisterMod({{MODNAME_CLASS}}.Name)
        {{MODNAME_CLASS}}.DB = KCDUtils.DB.Factory({{MODNAME_CLASS}}.Name)
        {{MODNAME_CLASS}}.Logger = KCDUtils.Logger.Factory({{MODNAME_CLASS}}.Name)
        {{MODNAME_CLASS}}.Config = KCDUtils.Config.Factory({{MODNAME_CLASS}}.Name)
        -- rest of your init
    end
    ```

3. Explore the scripts in `Utils/` to see available helper functions.

---

## Notes

- KCDUtils is **standalone**, no other dependencies required for general utilities.  
- Future updates will include new utility functions and improvements.  

---

## License

This project is released under the MIT License. See the `LICENSE` file for details.
