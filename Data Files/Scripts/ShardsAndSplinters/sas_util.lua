local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local time = require('openmw_aux.time')
local ambient = require('openmw.ambient')
local core = require('openmw.core')
local storage = require('openmw.storage')
local interfaces = require('openmw.interfaces')

local L = core.l10n("ShardsAndSplinters")

math.randomseed(os.time())

local settings = storage.playerSection("ShardsAndSplintersSettings")

-- Settings functions
local function getSetting(key)
    return settings:get(key)
end

function getSettingWeaponsAreBrittle()
    return getSetting("sasBrittleWeaponsToggle")
end

function getSettingShieldsAreBrittle()
    return getSetting("sasBrittleShieldsToggle")
end

function getSettingDurabilityThreshold()
    return getSetting("sasBreakThreshold")
end

function getSettingLuckModifier()
    return getSetting("sasLuckModifier")
end

local whitelistedTypesCache = nil

function getSettingWhiteListedTypesAsArray()
    if not whitelistedTypesCache then
        whitelistedTypesCache = {}
        for word in string.gmatch(getSetting("sasWhiteListedTypes"), '([^, ]+)') do
            table.insert(whitelistedTypesCache, word)
        end
    end
    return whitelistedTypesCache
end

function getSettingDebug()
    return getSetting("sasBrittleDebugToggle")
end

-- General utility functions
function getModifiedLuck() 
    return types.Actor.stats.attributes.luck(self).modified or 0
end

function getEquippedItem(slot)
    return types.Actor.getEquipment(self.object, slot)
end

function isItemOfType(item, itemType)
    return itemType.objectIsInstance(item)
end

function getItemInfo(item, itemType)
    if not item then return nil end
    local record = itemType.record(item)
    return {
        id = item.id or 0,
        name = record.name or "",
        model = record.model or "",
        health = record.health or 0,
        condition = types.Item.itemData(item).condition or 0,
        type = record.type
    }
end

function getItemPercentualDurability(info)
    return (info.condition / info.health) * 1000
end

function isItemBrittle(model)
    for _, brittleMaterial in ipairs(getSettingWhiteListedTypesAsArray()) do
        if string.find(string.lower(model), string.lower(brittleMaterial)) then
            return false
        end
    end
    return true
end

function getItemBreakChance(info)
    return (1000 - getItemPercentualDurability(info)) / (getModifiedLuck() / getSettingLuckModifier())
end

function checkForItemBreak(info)
    local rand = math.random(1, 1000)
    local breakChance = getItemBreakChance(info)
    
    if getSettingDebug() then
        print(string.format('Breaking chance: %.2f%%, Rand: %d', breakChance / 10, rand))
    end
    
    return rand <= breakChance
end

function itemBreakAlert(name)
    ui.showMessage(string.format(L("itemBreakMessage", {name = name})))
    ambient.playSound("critical damage")
    ambient.playSound("repair fail")
end

-- Weapon-specific functions
function getEquippedWeapon()
    return getEquippedItem(types.Actor.EQUIPMENT_SLOT.CarriedRight)
end

function isWeaponSlotAWeapon()
    return isItemOfType(getEquippedWeapon(), types.Weapon)
end

-- Shield-specific functions
function getEquippedShield()
    return getEquippedItem(types.Actor.EQUIPMENT_SLOT.CarriedLeft)
end

function isShieldSlotAShield()
    return isItemOfType(getEquippedShield(), types.Armor)
end

