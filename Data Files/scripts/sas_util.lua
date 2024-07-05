local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local time = require('openmw_aux.time')
local ambient = require('openmw.ambient')
local core = require('openmw.core')
local storage = require('openmw.storage')
local interfaces = require('openmw.interfaces')

math.randomseed(os.time())

local settings = storage.playerSection("ShardsAndSplintersSettings")

function getSettingWeaponsAreBrittle()
    return settings:get("brittleWeaponsSetting")
end

function getSettingDurabilityThreshold()
    return settings:get("breakThresholdSetting")
end

function getSettingLuckModifier()
    return settings:get("luckModifierSetting")
end

function getSettingBrittleMaterialsAsArray()
    local t = {}
    for word in string.gmatch(settings:get("brittleMaterialsSetting"), '([^, ]+)') do
        table.insert(t, word)
    end
    return t
end

function getSettingWhiteListedTypesAsArray()
    local t = {}
    for word in string.gmatch(settings:get("whiteListedTypesSetting"), '([^, ]+)') do
        table.insert(t, word)
    end
    return t
end

function getSettingDebug()
    return settings:get("brittleDebug")
end

function getModifiedLuck () 
    return types.Actor.stats.attributes.luck(self).modified or 0
end

function getEquippedWeapon() 
    return types.Actor.getEquipment(self.object, types.Actor.EQUIPMENT_SLOT.CarriedRight)
end

function getEquippedWeaponId () 
    return getEquippedWeapon().id or 0
end

function getEquippedWeaponName () 
    return types.Weapon.record(getEquippedWeapon()).name or 0
end

function getEquippedWeaponModel () 
    return types.Weapon.record(getEquippedWeapon()).model or 0
end

function getEquippedWeaponHealth () 
    return types.Weapon.record(getEquippedWeapon()).health or 0
end

function getEquippedWeaponDurability () 
    return types.Weapon.itemData(getEquippedWeapon()).condition or 0
end

function getEquippedWeaponPercentualDurability ()
    return ((getEquippedWeaponDurability()/getEquippedWeaponHealth())*1000)
end

function getEquippedWeaponType()
    return types.Weapon.record(getEquippedWeapon()).type
end

function getEquippedWeaponBreakChance ()
    local breakchance = (1000-((getEquippedWeaponDurability()/getEquippedWeaponHealth())*1000)) / (getModifiedLuck()/getSettingLuckModifier()) 
    return breakchance
end

function isEquippedWeaponBrittle ()

    local tmpBrittle = true

    for _, brittleMaterial in ipairs(getSettingWhiteListedTypesAsArray()) do
        if string.find(string.lower(getEquippedWeaponModel()), string.lower(brittleMaterial)) then
            tmpBrittle = false
            break
        end
    end
    
    return tmpBrittle
end

function checkForBreak()
    
    broken = false
    
    local rand = math.random(1, 1000)
    
    if rand <= getEquippedWeaponBreakChance() then
        broken = true
    end
    
    if getSettingDebug() then
        print('Breaking chance: ' .. getEquippedWeaponBreakChance()/10 .. '%, Rand: ' .. rand)
    end
    
    return broken
end

if getSettingDebug() then
    print('Shards & Splinters successfully loaded!')
end
