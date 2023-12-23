-- DCS Simple Spawn Menu
-- Created by Popper
-- v0.1.1
-- Repository: https://github.com/Markoudstaal/DCS-Simple-Spawn-Menu
-- License: MIT
-- You can edit the three lines below this if you want different characters or respawn behaviour

-- Update 02 Dec 2023: Added ability to create a multi level menu by adding additional '?' symbols e.g. "!?GROUND?GRD UNITS?LIGHT ARMOUR?!BRDM"

-- Identifier for the script
local dssmIdentifier = '!'

-- Identifier for submenu's
local menuIdentifier = '?'

-- Identifier for bulk, so multiple groups in 1 menu
local bulkIdentifier = '*'

-- Set this to true if you want to respawn groups that are still alive
-- If set to false nothing will happen
local respawn = true

-- DO NOT EDIT BELOW THIS LINE --

-- Inititate group and command db's
local groupDB = {}
local bulkDB = {}
local subMenuDB = {}
local commandDB = {}

-- Checks if a String starts with a specific Start string
function string.starts(string, start)
    return string.sub(string, 1, string.len(start)) == start
end

-- Gets a string between 2 identifiers
local function getStringByIdentifier(name, identifier)
    local startChar = string.find(name, identifier)
    if startChar == nil then
        return nil
    end
    local endChar = string.find(name, identifier, startChar + 1)
    if endChar == nil then
        return nil
    else
        return string.sub(name, startChar + 1, endChar - 1)
    end
end

-- Gets a string between 2 identifiers
local function getStringByIdentifierGreedy(name, identifier)
    local startChar = string.find(name, identifier)
    if startChar == nil then
        return nil
    end

    local nextChar = string.find(name, identifier, startChar + 1)
    local lastChar = startChar
    if nextChar == nil then
        return nil
    end
    local curString = string.sub(name, lastChar + 1, nextChar - 1)

    while nextChar do
        lastChar = nextChar
        nextChar = string.find(name, identifier, lastChar + 1)
    end
    return string.sub(name, startChar + 1, lastChar - 1)
end

-- Recursively parse a string until we have no identifiers left to eat
local function getStringToIdentifier(name, identifier)
    local nextChar = string.find(name, identifier)
    if nextChar == nil then
        return {name, nil}
    end
    local firstOut = string.sub(name, 0, nextChar - 1)
    local lastOut = string.sub(name, nextChar + 1, string.len(name))
    return {firstOut, getStringToIdentifier(lastOut, identifier)}
end

-- Recursively collapse a getStringToIdentifier result back to a single string
local function collapseToGroupName(name)
    if name == nil then
        return ''
    else
        return name[1] .. collapseToGroupName(name[2])
    end
end

-- Creates a set of submenus from a getStringToIdentifier setup
-- returns the lowest level menu
local function createMultiMenus(name, parentMenu)
    if name == nil then
        return nil
    else
        local menu = missionCommands.addSubMenu(name[1], parentMenu)
        if name[2] == nil then
            return menu
        else
            return createMultiMenus(name[2], menu)
        end
    end
end

local function getCleanName(name)
    local startChar = string.find(name, dssmIdentifier)
    local endChar = string.find(name, dssmIdentifier, startChar + 1)
    local cleanName = string.sub(name, endChar + 1, string.len(name))
    if string.starts(cleanName, ' ') then
        return string.sub(cleanName, 2, string.len(cleanName))
    else
        return cleanName
    end
end

-- Parses a group if name starts with the menu prefix
local function parseGroup(group)
    local groupName = Group.getName(group) 
    local dssmString = getStringByIdentifier(groupName, dssmIdentifier)
    if dssmString ~= nil then
        local subMenuMainString = getStringByIdentifierGreedy(dssmString, menuIdentifier)
        local subMenuName = getStringToIdentifier(subMenuMainString, menuIdentifier)
        if subMenuName == nil then
            subMenuName = {}
            subMenuName[1] = 'root'
            subMenuName[2] = nil
        end

        if subMenuDB[subMenuName[1]] == nil then
            subMenuDB[subMenuName[1]] = {subMenuName[2]}
        else

            local foundMatch = false
            local subGroupName = collapseToGroupName(subMenuName[2])
            for index, data in ipairs(subMenuDB[subMenuName[1]]) do
                if collapseToGroupName(data) == subGroupName then
                    foundMatch = true
                end
            end
            if foundMatch ~= true then
                table.insert(subMenuDB[subMenuName[1]], 1, subMenuName[2])
            end
        end

        -- Check if group is bulk
        local groupDBName = collapseToGroupName(subMenuName)
        if getStringByIdentifier(groupName, bulkIdentifier) == nil then
            -- Add group to groupDB

            if groupDB[groupDBName] == nil then
                groupDB[groupDBName] = {}
            end
            groupDB[groupDBName][Group.getName(group)] = group
        else
            -- Add Group to bulkDB
            local bulkName = getStringByIdentifier(groupName, bulkIdentifier)
            if bulkDB[groupDBName] == nil then
                bulkDB[groupDBName] = {}
            end
            if bulkDB[groupDBName][bulkName] == nil then
                bulkDB[groupDBName][bulkName] = {}
            end
            bulkDB[groupDBName][bulkName][Group.getName(group)] = group
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

local function addToMenu(groupDBName, parentMenu)
    if groupDB[groupDBName] ~= nil then
        for i, group in pairs(groupDB[groupDBName]) do
            local groupName = Group.getName(group)
            local menuName = getCleanName(groupName)
            local groupMenu = ''
            if groupDBName == 'root' then
                groupMenu = missionCommands.addSubMenu(menuName)
            else
                groupMenu = missionCommands.addSubMenu(menuName, parentMenu)
            end
            commandDB['s' .. groupName] = missionCommands.addCommand('Spawn', groupMenu, spawnGroup, groupName)
            commandDB['d' .. groupName] = missionCommands.addCommand('Despawn', groupMenu, despawnGroup, groupName)
        end
    end

    if bulkDB[groupDBName] ~= nil then
        for bulkName, bulk in pairs(bulkDB[groupDBName]) do
            local bulkMenu = ''
            if groupDBName == 'root' then
                bulkMenu = missionCommands.addSubMenu(bulkName)
            else
                bulkMenu = missionCommands.addSubMenu(bulkName, parentMenu)
            end
            commandDB['s' .. bulkName] = missionCommands.addCommand('Spawn', bulkMenu, spawnBulk,
                bulkDB[groupDBName][bulkName])
            commandDB['d' .. bulkName] = missionCommands.addCommand('Despawn', bulkMenu, despawnBulk,
                bulkDB[groupDBName][bulkName])
        end
    end
end

-- Get all groups with a menuIdentifier and create sub menu entries for them.
-- Neutral coalition
for i, group in pairs(coalition.getGroups(0)) do
    parseGroup(group)
end
-- Red coalition
for i, group in pairs(coalition.getGroups(1)) do
    parseGroup(group)
end
-- Blue coalition
for i, group in pairs(coalition.getGroups(2)) do
    parseGroup(group)
end


for key, subMenu in pairs(subMenuDB) do
    local menu = ''
    if key ~= 'root' then
        menu = missionCommands.addSubMenu(key)
    end

    if key == 'root' then
        local groupDBName = key
        addToMenu(groupDBName, menu)
    else
        -- { [1] = "F16", [2] = "Group", }
        for i, subMenu2 in ipairs(subMenu) do
            local level2Menu = ''
            local groupDBName = key
            groupDBName = key .. collapseToGroupName(subMenu2)
            level2Menu = createMultiMenus(subMenu2, menu)
            addToMenu(groupDBName, level2Menu)
        end
    end
end
