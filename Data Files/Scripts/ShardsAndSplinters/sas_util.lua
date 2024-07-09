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

function getSettingWeaponsAreBrittle()
    return settings:get("sasBrittleWeaponsToggle")
end

function getSettingShieldsAreBrittle()
    return settings:get("sasBrittleShieldsToggle")
end

function getSettingDurabilityThreshold()
    return settings:get("sasBreakThreshold")
end

function getSettingLuckModifier()
    return settings:get("sasLuckModifier")
end

function getSettingWhiteListedTypesAsArray()
    local t = {}
    for word in string.gmatch(settings:get("sasWhiteListedTypes"), '([^, ]+)') do
        table.insert(t, word)
    end
    return t
end

function getSettingDebug()
    return settings:get("sasBrittleDebugToggle")
end

-- -----------------------------------------------------------------------------

function getModifiedLuck () 
    return types.Actor.stats.attributes.luck(self).modified or 0
end

function getEquippedWeapon() 
    return types.Actor.getEquipment(self.object, types.Actor.EQUIPMENT_SLOT.CarriedRight)
end

function isWeaponSlotAWeapon()
    return types.Weapon.objectIsInstance(getEquippedWeapon())
end

function getEquippedWeaponId() 
    return getEquippedWeapon().id or 0
end

function getEquippedWeaponName() 
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

-- Shield Functions ------------------------------------------------------------

function getShieldSlot()
    return types.Actor.getEquipment(self.object, types.Actor.EQUIPMENT_SLOT.CarriedLeft)
end

function isShieldSlotAShield()
    return types.Armor.objectIsInstance(getShieldSlot())
end

function getEquippedShieldName() 
    return types.Armor.record(getShieldSlot()).name
end

function getShieldSlotId()
    return getShieldSlot().id or 0
end

function getEquippedShieldModel() 
    return types.Armor.record(getShieldSlot()).model
end

function getEquippedShieldHealth() 
    return types.Armor.record(getShieldSlot()).health
end

function getEquippedShieldCondition() 
    return types.Item.itemData(getShieldSlot()).condition
end

function getEquippedShieldPercentualCondition()
    return (getEquippedShieldCondition()/getEquippedShieldHealth())*1000
end

function getItemCondition(item) 
    return types.Item.itemData(item).condition or 0
end

function isItemBrittle(itemModel)

    local tmpBrittle = true

    for _, brittleMaterial in ipairs(getSettingWhiteListedTypesAsArray()) do
        if string.find(string.lower(itemModel), string.lower(brittleMaterial)) then
            tmpBrittle = false
            break
        end
    end
    
    return tmpBrittle
end

function getItemBreakChance(itemCondition, itemHealth)
    return (1000-((itemCondition/itemHealth)*1000)) / (getModifiedLuck()/getSettingLuckModifier()) 
end

function checkForItemBreak(itemCondition, itemHealth)
    
    broken = false
    
    local rand = math.random(1, 1000)
    
    if rand <= getItemBreakChance(itemCondition, itemHealth ) then
        broken = true
    end
    
    if getSettingDebug() then
        print('Breaking chance: ' .. getItemBreakChance(itemCondition, itemHealth )/10 .. '%, Rand: ' .. rand)
    end
    
    return broken
end

function itemBreakAlert(name)
    ui.showMessage(string.format(L("itemBreakMessage", {name = name})))
    ambient.playSound("critical damage")
    ambient.playSound("repair fail")
end


