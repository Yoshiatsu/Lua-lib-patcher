local gg = gg
local table = table

-- ON / OFF strings for the menu
-- You can change them if you want
local ON  = "[ ON ]"
local OFF = "[ OFF ]"

local Patcher = {}
Patcher.__index = Patcher

-- [[ DO NOT EDIT BELOW THIS LINE ]]
Patcher.AUTHOR       = "Maars"
Patcher.VERSION_CODE = 1
Patcher.VERSION_NAME = "2.0.0"

-- Print all arguments to the console and exit the script
local function die(...)
  print(...)
  os.exit()
end

-- Add all keys from t2 to t1 and return the results
local function addTable(t1, t2)
  local t = {}
  for k, v in pairs(t1) do t[k] = v end
  for k, v in pairs(t2) do t[k] = v end
  return t
end

-- The every method tests whether all elements in the array pass the test implemented by
-- the provided function. It returns a Boolean value.
table.every = function(tbl, func)
  for k, v in pairs(tbl) do
    if not func(v, k) then return false end
  end
  return true
end

-- The forEach method executes a provided function once for each array element.
table.forEach = function(tbl, func)
  for k, v in pairs(tbl) do
    func(v, k)
  end
end

-- The map() method creates a new array populated with the
--  results of calling a provided function on every element in the calling array.
table.map = function(tbl, func)
  local newTbl = {}
  table.forEach(tbl, function(v, k)
    newTbl[k] = func(v, k)
  end)
  return newTbl
end

-- reduce return the sum of all the elements in an array
table.reduce = function(tbl, func, init)
  local acc = init
  table.forEach(tbl, function(v, k)
    acc = func(acc, v, k)
  end)
  return acc
end

-- concat all arguments to a string and return the results
local function concat(...)
  return table.reduce({ ... }, function(acc, v)
    return acc .. tostring(v)
  end, "")
end

-- Check if the target is valid
local function checkTargetInfo(target)
  local infos = gg.getTargetInfo()

  if not infos then
    gg.alert("Error: ", "gg.getTargetInfo() returned nil")
    die("Error: ", "gg.getTargetInfo() returned nil")
  end

  -- Check packageName
  if target.packageName then
    if infos.packageName ~= target.packageName then
      gg.alert("This script work only for ", target.packageName)
      die("This script work only for  ", target.packageName)
    end
  end

  -- Check if the target is 32bits or 64bits
  if target.x64 then
    if infos.x64 ~= target.x64 then
      gg.alert("This script work only for the ", target.x64 and "64bits" or "32bits", " variant of the game.")
      die("This script work only for the ", target.x64 and "64bits" or "32bits", " variant of the game.")
    end
  end

  if target.versionName then
    if infos.versionName ~= target.versionName then
      gg.alert("This script work only for the version ", target.versionName)
      die("This script work only for the version ", target.versionName)
    end
  end

end

-- Get the start address in Xa of a library
local function getStartAddr(libName)
  local startAddr
  local ranges = gg.getRangesList(libName)
  if #ranges == 0 then return nil end

  table.every(ranges, function(v)
    if v.state == "Xa" then
      startAddr = v.start
      return false
    end
    return true
  end)

  return startAddr
end

-- local function tohex(n, prefix)
--   return string.format("%s%x", prefix and "0x" or "", n)
-- end

--  Emulate a try/catch block
local function try(f, catch_f)
  local status, exception = pcall(f)
  if not status then
    catch_f(exception)
  end
end

-- Get the metod/value from the address and flags in memory
local function getMethod(addr, flags)
  local method
  try(
    function() method = gg.getValues({ { address = addr, flags = flags } }) end,
    function(e)
      gg.alert("Error: ", e)
      print(e, "\n", debug.traceback())
    end
  )

  return method and method[1] or nil
end

-- Set the value in memory at the address with the flags provided
local function setValue(addr, value, flags)
  gg.setValues({ { address = addr, flags = flags, value = concat(value, "r") } })
end

local function refreshMenu(methods)
  return table.map(methods, function(m)
    return concat(m.state and ON or OFF, " ", m.name)
  end)
end

-- Create a new Patcher object
function Patcher.new(config)
  checkTargetInfo(config.target)

  local self      = setmetatable({}, Patcher)
  self.methods    = {}
  self.config     = config
  local startAddr = getStartAddr(config.target.libName)
  if not startAddr then
    gg.alert(concat("Library '", config.target.libName, "' not found :("))
    die("Please make sure you have the library loaded in memory.")
  end

  -- Default config
  self.config.flags     = config.flags or gg.TYPE_QWORD
  self.config.startAddr = startAddr
  self.config.bigEndian = config.bigEndian or false

  return self
end

-- Add a new method to the patcher object
function Patcher:add(method)
  local config = self.config

  local startAddr = (method.libName and getStartAddr(method.libName) or config.startAddr) + (method.offset or 0)
  method          = addTable(method, getMethod(startAddr, method.flags or config.flags))
  method.state    = false

  table.insert(self.methods, method)
end

-- Run the patcher
function Patcher:run()
  local config = self.config
  local function main()
    if #self.methods == 0 then
      gg.alert("No methods to patch :(")
      return
    end
    local choice = gg.choice(refreshMenu(self.methods), 0, self.config.title or "Patcher")
    if choice == nil then return end

    local method = self.methods[choice]

    if (method.state) then
      setValue(method.address, method.valueFrom, method.flags or config.flags)
      gg.toast("Disabled " .. method.name)
    else
      setValue(method.address, method.valueTo, method.flags or config.flags)
      gg.toast("Enabled " .. method.name)
    end

    method.state = not method.state
  end

  gg.showUiButton()
  while true do
    if gg.isClickedUiButton() then main() end
    gg.sleep(100)
  end
end

return Patcher
