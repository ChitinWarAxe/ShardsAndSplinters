local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local time = require('openmw_aux.time')
local ambient = require('openmw.ambient')
local core = require('openmw.core')
local storage = require('openmw.storage')
local interfaces = require('openmw.interfaces')
local sasUtil = require('scripts.sas_util')

local savedDurability = 0
local savedId = 0
local brittle = false
    
local loop = time.runRepeatedly(function()

    if getEquippedWeapon() and getSettingWeaponsAreBrittle() then

        if savedId ~= getEquippedWeaponId() then

            savedId = getEquippedWeaponId()
            savedDurability = getEquippedWeaponDurability()
            brittle = isEquippedWeaponBrittle()
            
            if getSettingDebug() then
                print('Equipped: ' .. getEquippedWeaponName() .. ', Model: ' .. getEquippedWeaponModel() .. ', Type: ' .. getEquippedWeaponType() )
                print('Condition: ' .. getEquippedWeaponPercentualDurability()/10 .. '%, breakchance: ' .. getEquippedWeaponBreakChance()/10 .. '%, Threshold: ' .. getSettingDurabilityThreshold() .. '%')
                
                if brittle then
                    print('Your weapons looks somewhat brittle!')
                end
            end
        end
        
        if (brittle
            and getEquippedWeaponDurability() < savedDurability
            and getEquippedWeaponPercentualDurability() <= getSettingDurabilityThreshold()*10)
            or (getEquippedWeaponDurability() == 0 and 11 ~= getEquippedWeaponType())
            then
            
            if getSettingDebug() then
                print("Your weapon's condition got worse! " .. savedDurability .. " -> " .. getEquippedWeaponDurability())
            end

            if (checkForBreak() or getEquippedWeaponDurability() == 0) then
                ui.showMessage('Your ' .. getEquippedWeaponName() .. ' broke!')   
                core.sendGlobalEvent("remove", {object=getEquippedWeapon()})         
                ambient.playSound("critical damage")
                ambient.playSound("repair fail")
            end            
        end
        
        savedDurability = getEquippedWeaponDurability()

    end
end,0.5 )  

