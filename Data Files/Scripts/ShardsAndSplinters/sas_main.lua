local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local time = require('openmw_aux.time')
local core = require('openmw.core')
local sasUtil = require('scripts.shardsandsplinters.sas_util')

local savedWeaponInfo = nil
local savedShieldInfo = nil

local function debugPrint(message)
    if getSettingDebug() then
        print(message)
    end
end

local function handleEquipmentChange(equipmentType, newInfo)
    local savedInfo = equipmentType == "weapon" and savedWeaponInfo or savedShieldInfo
    if not savedInfo or savedInfo.id ~= newInfo.id then
        debugPrint(string.format('Equipped: %s, Model: %s, Type: %s', newInfo.name, newInfo.model, newInfo.type))
        debugPrint(string.format('Condition: %.2f%%, breakchance: %.2f%%, Threshold: %d%%', 
            getItemPercentualDurability(newInfo)/10, 
            getItemBreakChance(newInfo)/10, 
            getSettingDurabilityThreshold()))
        
        if isItemBrittle(newInfo.model) then
            debugPrint(string.format('Your %s looks somewhat brittle!', equipmentType))
        end
        
        return newInfo
    end
    return savedInfo
end

local function checkAndHandleBreak(equipmentType, info)
    if isItemBrittle(info.model) 
    and getItemPercentualDurability(info) <= getSettingDurabilityThreshold() * 10
    and (equipmentType ~= "weapon" or info.type ~= 11) -- Exclude thrown type for weapons
    then
        if checkForItemBreak(info)
        -- or info.condition == 0 
        then
            itemBreakAlert(info.name)
            core.sendGlobalEvent("remove", {object = equipmentType == "weapon" and getEquippedWeapon() or getEquippedShield()})
            return true
        end
    end
    return false
end

local function processEquipment(equipmentType)
    local getEquippedFunc = equipmentType == "weapon" and getEquippedWeapon or getEquippedShield
    local isEquippedFunc = equipmentType == "weapon" and isWeaponSlotAWeapon or isShieldSlotAShield
    local itemType = equipmentType == "weapon" and types.Weapon or types.Armor
    local isBrittleSettingFunc = equipmentType == "weapon" and getSettingWeaponsAreBrittle or getSettingShieldsAreBrittle
    
    if getEquippedFunc() and isBrittleSettingFunc() and isEquippedFunc() then
        local newInfo = getItemInfo(getEquippedFunc(), itemType)
        local savedInfo = equipmentType == "weapon" and savedWeaponInfo or savedShieldInfo
        
        if not savedInfo or savedInfo.id ~= newInfo.id then
            -- Equipment changed or first equip
            if equipmentType == "weapon" then
                savedWeaponInfo = newInfo
            else
                savedShieldInfo = newInfo
            end
            debugPrint(string.format('Equipped: %s, Model: %s, Type: %s', newInfo.name, newInfo.model, newInfo.type))
            debugPrint(string.format('Condition: %.2f%%, breakchance: %.2f%%, Threshold: %d%%', 
                getItemPercentualDurability(newInfo)/10, 
                getItemBreakChance(newInfo)/10, 
                getSettingDurabilityThreshold()))
            
            if isItemBrittle(newInfo.model) then
                debugPrint(string.format('Your %s looks somewhat brittle!', equipmentType))
            end
        elseif newInfo.condition < savedInfo.condition then
            -- Same item, condition worsened
            debugPrint(string.format("Your %s's condition got worse! %d -> %d", equipmentType, savedInfo.condition, newInfo.condition))
            if not checkAndHandleBreak(equipmentType, newInfo) then
                if equipmentType == "weapon" then
                    savedWeaponInfo = newInfo
                else
                    savedShieldInfo = newInfo
                end
            end
        end
    end
end

local loop = time.runRepeatedly(function()
    processEquipment("weapon")
    processEquipment("shield")
end, 0.5)
