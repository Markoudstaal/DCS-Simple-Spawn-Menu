-- DCS Simple Spawn Menu
-- Created by Popper
-- v0.0.1
-- Repository: https://github.com/Markoudstaal/DCS-Simple-Spawn-Menu
-- License: MIT

-- You can edit the three lines below this if you want different characters or respawn behaviour

-- Identifier for menu folders
local menuIdentifier = '!'

-- Identifier for bulk, so multiple groups in 1 menu
local bulkIdentifier = '*'

-- Set this to true if you want to respawn groups that are still alive
-- If set to false nothing will happen
local respawn = 'true'

-- DO NOT EDIT BELOW THIS LINE --

-- Inititate group and command db's
local groupDB = {}
local bulkDB = {}
local subMenuDB = {}
local commandDB = {}

-- Checks if a String starts with a specific Start string
function string.starts(string, start)
  return string.sub(string,1,string.len(start))==start
end

-- Removes menuIdentifier and submenu name
local function getCleanName(name)
  local endOfMenuName = string.find(name, '|')
  return string.sub(name, endOfMenuName+1, string.len(name))
end

-- Gets a string between 2 identifiers
local function getStringByIdentifier(name, identifier)
  local startChar = string.find(name, identifier)+1
  local endChar = string.find(name, identifier, startChar)-1
  return string.sub(name, startChar, endChar)
end

-- Parses a group if name starts with the menu prefix
local function parseGroup(group)
  local groupName = Group.getName(group)
  if string.starts(groupName, menuIdentifier)
  then
    local subMenuName = getStringByIdentifier(groupName, menuIdentifier)

    if subMenuName == '' then
      subMenuName = 'root'
    end

    if subMenuDB[subMenuName] == nil then
      subMenuDB[subMenuName] = subMenuName
    end
    
    -- Check if group is bulk
    if string.find(groupName, bulkIdentifier) == nil then
      -- Add group to groupDB
      if groupDB[subMenuName] == nil then
        groupDB[subMenuName] = {}
      end
      groupDB[subMenuName][Group.getName(group)] = group
    else
      -- Add Group to bulkDB
      local bulkName = getStringByIdentifier(groupName, bulkIdentifier)
      if bulkDB[subMenuName] == nil then
        bulkDB[subMenuName] = {}
      end
      if bulkDB[subMenuName][bulkName] == nil then
        bulkDB[subMenuName][bulkName] = {}
      end
      bulkDB[subMenuName][bulkName][Group.getName(group)] = group
    end
  end
end

-- Spawn or respawns a group
local function spawnGroup(groupName)
  if Group.getByName(groupName) then
    if respawn then
      mist.respawnGroup(groupName, true)
    else
      Group.activate(Group.getByName(groupName))
    end
  else
    mist.respawnGroup(groupName, true)
  end
end

-- Despawns a group
local function despawnGroup(groupName)
  Group.destroy(Group.getByName(groupName))
end

-- Spawns a bulk
local function spawnBulk(bulk)
  for groupName, group in pairs(bulk) do
    if Group.getByName(groupName) then
      if respawn then
        mist.respawnGroup(groupName, true)
      else
        Group.activate(Group.getByName(groupName))
      end
    else
      mist.respawnGroup(groupName, true)
    end
  end
end

-- Despawns a bulk
local function despawnBulk(bulk)
  for groupName, group in pairs(bulk) do
    Group.destroy(Group.getByName(groupName))
  end
end

-- Get all groups with a menuIdentifier and create sub menu entries for them.
-- Neutral coalition
for i, group in pairs(coalition.getGroups(0)) do
  parseGroup(group)
end
--Red coalition
for i, group in pairs(coalition.getGroups(1)) do
  parseGroup(group)
end
-- Blue coalition
for i, group in pairs(coalition.getGroups(2)) do
  parseGroup(group)
end

-- Create submenus and add groups to them
for i, subMenu in pairs(subMenuDB) do
  local menu = ''
  if subMenu ~= 'root' then
    menu = missionCommands.addSubMenu(subMenu)
  end

  if groupDB[subMenu] ~= nil then
    for i, group in pairs(groupDB[subMenu]) do
      local groupName = Group.getName(group)
      local menuName = getCleanName(groupName)
      local groupMenu = ''
      if subMenu == 'root' then
        groupMenu = missionCommands.addSubMenu(menuName)
      else
        groupMenu = missionCommands.addSubMenu(menuName, menu)
      end
      commandDB['s' .. groupName] = missionCommands.addCommand('Spawn', groupMenu, spawnGroup, groupName)
      commandDB['d' .. groupName] = missionCommands.addCommand('Despawn', groupMenu, despawnGroup, groupName)
    end
  end

  if bulkDB[subMenu] ~= nil then
    for bulkName, bulk in pairs(bulkDB[subMenu]) do
      local bulkMenu = ''
      if subMenu == 'root' then
        bulkMenu = missionCommands.addSubMenu(bulkName)
      else
        bulkMenu = missionCommands.addSubMenu(bulkName, menu)
      end
      commandDB['s' .. bulkName] = missionCommands.addCommand('Spawn', bulkMenu, spawnBulk, bulkDB[subMenu][bulkName])
      commandDB['d' .. bulkName] = missionCommands.addCommand('Despawn', bulkMenu, despawnBulk, bulkDB[subMenu][bulkName])
    end
  end
end
