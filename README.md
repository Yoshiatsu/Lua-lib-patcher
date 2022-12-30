# Patcher
Patcher is a library for patching lib in gameguardian scripts.

## Basic Usage

```lua
local Patcher = require("Patcher")

local config = {
  title   = "Super ModMenu !",
  author  = "SuperDev",
  target  = { libName = "libil2cpp.so" }
}

local p = Patcher.new( config )

p:hook({
  name      = "GetCurrency", 
  offset    = 0x12345678,
  valueTo   = "00 12 A0 52 C0 03 5F D6",
  valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
})

p:hook({
  name      = "GetCurrency2", 
  offset    = 0x12345679,
  valueTo   = "00 12 A0 52 C0 03 5F D6",
  valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
})

p:run()
```

note : <b>?</b> means optional

## Functions

| Name | Description |  Return |  Params | 
| --- | --- | --- | --- | 
| new | Create a new Patcher instance | Patcher | [Config](#config) |
| hook | Add a hook to the patcher |  | [Method](#method)  |
| run | Run the patcher | boolean |  


## Config (required)
| Name | Type | Description | default |
| --- | --- | --- | --- |
| ?title | string | Title of the menu | Patcher |
| ?author | string | Author of the menu |  |
| target | table | see  [Target](#target) |  |
| ?flags | integer | Flags of the menu see [here](https://gameguardian.net/help/classgg.html#a2caf0befac443b24f1044eeb4003eee4) | TYPE_QWORD  |

<b>Note</b>: When flags is not set, [TYPE_QWORD](https://gameguardian.net/help/classgg.html#a273526589fd3c74f878f7dee4d9d9156) is used by default.

## Target (required)

| Name | Type | Description |
| --- | --- | --- |
| libName | string | Name of the lib to patch |
| ?packageName | string | Package name of the app to patch |
| ?x64 | boolean | If the lib is 64 bits |
| ?versionName | string | Version name of the app to patch |

<b>Notes</b>:
- If libName is not provided or not found in the app, the patcher will terminate with an error.
- When packageName, or x64, or versionName is provided, they will be compared with the current target app and if any don't match the patcher will terminate iwth an error.

## Method (required)
| Name | Type | Description |
| --- | --- | --- |
| name | string | Name that will be displayed in the menu |
| offset | integer | Offset of the method to patch |
| ?libName | string | Name of the lib to patch to get get the sarting address of the method |
| valueTo | string | Value used when enabling the hook |
| ?valueFrom | string | Value to restore when disabling the hook |
| ?flags | integer | Flags of the hook see [here](https://gameguardian.net/help/classgg.html#a2caf0befac443b24f1044eeb4003eee4) |

<b>Notes</b>:
- When flags is not set, the flags set in the config will be used by default.

- When libName is not set, the libName set in the config.target will be used by default.

- When valueFrom is not set, only activation of the hook will be possible.
-  When valueFrom is set, activation and deactivation of the hook will be possible.

<p style="color:red"> <b>Notes:</b> If a mandatory field or parameters is not set, the patcher will terminate with an error.</p>

## Installation

There is two ways to import Patcher in your script.

### 1. Local import

Download the Patcher.lua file and put it in the same folder as your script.

```lua
local Patcher = require("Patcher")
```

### 2. Import from pastebin

<b>Note:</b> Remote import will provide only the latest version
if you want to use old version you will need to download it frpm the [releases](https://github.com/maarsalien/patcher/releases)

```lua
local _, Patcher = pcall(load(gg.makeRequest("https://pastebin.com/raw/wz1sfmWF").content))
```

## Examples

### 1. Hooking multiple methods in the same lib

```lua
local Patcher = require("Patcher")

local config = {
  title   = "Super ModMenu !",
  author  = "SuperDev",
  target  = { libName = "libil2cpp.so" }
}

local p = Patcher.new( config )

local methods = {
  {
    name      = "GetCurrency", 
    offset    = 0x12345678,
    valueTo   = "00 12 A0 52 C0 03 5F D6",
    valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
  },
  {
    name      = "GetCurrency2", 
    offset    = 0x12345679,
    valueTo   = "00 12 A0 52 C 03 5F D6",
  },
}

for _, m in ipairs(methods) do
  p:hook(m)
end

p:run()
```

### 2. Hooking multiple methods in different libs

```lua

local Patcher = require("Patcher")

local config = {
  title   = "Super ModMenu !",
  author  = "SuperDev",
  target  = { libName = "libil2cpp.so" }
}

local p = Patcher.new( config )

local methods = {
  {
    name      = "GetCurrency", 
    offset    = 0x12345678,
    valueTo   = "00 12 A0 52 C0 03 5F D6",
    valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
  },
  {
    name      = "GetCurrency2", 
    offset    = 0x12345679,
    libName   = "libmain.so"
    valueTo   = "00 12 A0 52 C 03 5F D6",
    valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
  },
  {
    name      = "GetCurrency3", 
    offset    = 0x12345679,
    libName   = "libunity.so"
    valueTo   = "00 12 A0 52 C 03 5F D6",
    valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
  },
}

for _, m in ipairs(methods) do
  p:hook(m)
end

p:run()
```

### 3. Hooking multiple methods in different libs with different flags

```lua

local Patcher = require("Patcher")

local config = {
  title   = "Super ModMenu !",
  author  = "SuperDev",
  target  = { libName = "libil2cpp.so" }
}

local p = Patcher.new( config )

local methods = {
  {
    name      = "GetCurrency", 
    offset    = 0x12345678,
    valueTo   = "00 12 A0 52 C0 03 5F D6",
    valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
  },
  {
    name      = "GetCurrency2", 
    offset    = 0x12345679,
    libName   = "libmain.so"
    valueTo   = "00 12 A0 52 C 03 5F D6",
    valueFrom = "F5 0F 1D F8 F4 4F 01 A9",
  },
  {
    name      = "GetCurrency3", 
    offset    = 0x12345679,
    libName   = "libunity.so"
    valueTo   = "00 12 A0 52",
    valueFrom = "F5 0F 1D F8",
    flags     = gg.TYPE_DWORD
  },
}
```

# Contributing

If you want to contribute to the project, you can do it by forking the project and making a pull request.
Any help is welcome.

## Contributors
- Be the first to contribute to the project
<hr>

If you have any questions, you can contact me on

- discord: [MΛΛRS](https://discord.com/users/MΛΛRS#2270)
- telegram: [@maarsalien](https://t.me/maarsalien)
- gameguardian [MAARS](https://gameguardian.net/forum/profile/1138303-maars/)
- onlyfans: [MAARS](https://youtu.be/dQw4w9WgXcQ)