-- DCS Simple Spawn Menu
-- Created by Popper
-- v0.1.2
-- Updated for multimenu handling by Gillogical
-- Repository: https://github.com/Markoudstaal/DCS-Simple-Spawn-Menu
-- License: MIT
-- You can edit the three lines below this if you want different characters or respawn behaviour

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
-- Added a WARN level logger to help with debugging
myLogger = mist.Logger:new("DSSM")

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
    if name == "" or name == nil then 
        return {}
    end
    
    local nextChar = string.find(name, identifier)
    if nextChar == nil then
        return {[name] = {}}
    end
    local firstOut = string.sub(name, 0, nextChar - 1)
    local lastOut = string.sub(name, nextChar + 1, string.len(name))
    return {[firstOut] = getStringToIdentifier(lastOut, identifier)}
end

local function countTableSize(table)
    local count = 0
    for k, v in pairs(table) do
        count = count + 1
    end
    return count
end

-- Recursively collapse a getStringToIdentifier result back to a single string
local function collapseToGroupName(name)
    if name == nil then
        return ''
    else
        local s = ''
        for k, v in pairs(name) do
            return k .. collapseToGroupName(v) 
        end
        return s
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

local function insertToLowestUnique(subMenu, newMenu)
    local foundMatch = nil
    local keyInsert = nil
    local toInsert = nil
    
    if countTableSize(subMenu) == 0 then
        return
    end
    
    for k, v in pairs(subMenu) do
        for knew, vnew in pairs(newMenu) do
            keyInsert = knew
            toInsert = vnew
            if knew == k then 
                foundMatch = k
            end
        end
    end
    
    if foundMatch == nil then
        subMenu[keyInsert] = toInsert
        print("Inserting k " .. keyInsert .. " | ")
    else
        insertToLowestUnique(subMenu[foundMatch], newMenu[foundMatch])
        print("Next Level " .. foundMatch)
    end
end


-- Parses a group if name starts with the menu prefix
local function parseGroup(group)
    local groupName = Group.getName(group) 
    local dssmString = getStringByIdentifier(groupName, dssmIdentifier)
    if dssmString ~= nil then
        local subMenuMainString = getStringByIdentifierGreedy(dssmString, menuIdentifier)   
        local subMenuName = getStringToIdentifier(subMenuMainString, menuIdentifier)        -- {["AIR"] = { ["SOUTH"] = {["mig"] = {}}}}
        myLogger:msg('DSSM $1 | subMenuMainString $2 | subMenuName $3 | $4', dssmString, subMenuMainString, subMenuName, countTableSize(subMenuName))
        if countTableSize(subMenuName) == 0 then
            subMenuName['root'] = {}
        end

        if countTableSize(subMenuDB) == 0 then
            subMenuDB = subMenuName
            for k, v in pairs(subMenuName) do
                subMenuDB[k] = v
            end
            myLogger:msg('New Submenu $1 \n DB $2', subMenuName, subMenuDB)
        else
            insertToLowestUnique(subMenuDB, subMenuName)
            myLogger:msg('Insert Submenu $1 \n DB $2', subMenuName, subMenuDB)
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


-- Creates a set of submenus from a getStringToIdentifier setup
local function createMultiMenus(name, parentMenu, curGroupDBName)
    if countTableSize(name) == 0 then
        return nil
    else
        for k, v in pairs(name) do
            local menu = missionCommands.addSubMenu(k, parentMenu)
            myLogger:msg('Multimenu creation $1 \nparent menu $2', name, parentMenu)
            if countTableSize(v) == 0 then
                myLogger:msg('Multimenu STOP $1| Group $2', menu,curGroupDBName .. k)
                addToMenu(curGroupDBName .. k, menu)
            else
                createMultiMenus(v, menu, curGroupDBName .. k)
            end
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

myLogger:warn('FINAL PARSED SubMenu $1', subMenuDB)
-- Create submenus and add groups to them
for key, subMenu in pairs(subMenuDB) do
    local menu = ''
    if key == 'root' then
        local groupDBName = key

        myLogger:msg('Root Menu $1', key)
        addToMenu(groupDBName, menu)
    else
        menu = missionCommands.addSubMenu(key)
        myLogger:msg('Top Menu $1', key)
        createMultiMenus(subMenu, menu, key)
    end
end
