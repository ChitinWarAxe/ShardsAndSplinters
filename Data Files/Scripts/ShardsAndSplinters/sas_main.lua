local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local time = require('openmw_aux.time')
local ambient = require('openmw.ambient')
local core = require('openmw.core')
local storage = require('openmw.storage')
local interfaces = require('openmw.interfaces')
local sasUtil = require('scripts.shardsandsplinters.sas_util')

local savedWeaponCondition = 0
local savedWeaponId = 0
local isSavedWeaponBrittle = false

local savedShieldCondition = 0
local savedShieldId = 0
local isSavedShieldBrittle = false
    
local loop = time.runRepeatedly(function()

    if getEquippedWeapon() and getSettingWeaponsAreBrittle() then

        if isWeaponSlotAWeapon() then

            if (savedWeaponId ~= getEquippedWeaponId()) then

                savedWeaponId = getEquippedWeaponId()
                savedWeaponCondition = getEquippedWeaponDurability()
                isSavedWeaponBrittle = isEquippedWeaponBrittle()
                
                if getSettingDebug() then
                    print('Equipped: ' .. getEquippedWeaponName() .. ', Model: ' .. getEquippedWeaponModel() .. ', Type: ' .. getEquippedWeaponType() )
                    print('Condition: ' .. getEquippedWeaponPercentualDurability()/10 .. '%, breakchance: ' .. getEquippedWeaponBreakChance()/10 .. '%, Threshold: ' .. getSettingDurabilityThreshold() .. '%')
                    
                    if isSavedWeaponBrittle then
                        print('Your weapon looks somewhat brittle!')
                    end
                end
            end
            
            if isSavedWeaponBrittle 
            and getEquippedWeaponDurability() < savedWeaponCondition 
            and getEquippedWeaponPercentualDurability() <= getSettingDurabilityThreshold()*10 
            and 11 ~= getEquippedWeaponType() 
            then
                
                if getSettingDebug() then
                    print("Your weapon's condition got worse! " .. savedWeaponCondition .. " -> " .. getEquippedWeaponDurability())
                end

                if (checkForBreak() or getEquippedWeaponDurability() == 0) then
                    itemBreakAlert(getEquippedWeaponName())
                    core.sendGlobalEvent("remove", {object=getEquippedWeapon()})
                end            
            end
            
            savedWeaponCondition = getEquippedWeaponDurability()
        
        end

    end

    -- Do the same for shields. ------------------------------------------------
    
    if getShieldSlot() and getSettingShieldsAreBrittle() then
    
        if isShieldSlotAShield() then
        
            if (savedShieldId ~= getShieldSlotId()) then  -- Equipped another shield, or Lua script was reloaded.
                
                savedShieldId = getShieldSlotId()
                savedShieldCondition = getEquippedShieldCondition()
                isSavedShieldBrittle = isItemBrittle(getEquippedShieldModel())
                
                if getSettingDebug() then
                    print('Equipped: ' .. getEquippedShieldName() .. ', Model: ' .. getEquippedShieldModel())
                    print('Condition: ' .. getEquippedShieldPercentualCondition()/10 .. '%, breakchance: ' .. getItemBreakChance(getEquippedShieldCondition(),getEquippedShieldHealth() )/10 .. '%, Threshold: ' .. getSettingDurabilityThreshold() .. '%')
                --    
                    if isSavedShieldBrittle then
                        print('Your shield looks somewhat brittle!')
                    end
                end
            end
            
            if (isSavedShieldBrittle
                and getEquippedShieldCondition() < savedShieldCondition
                and getEquippedShieldPercentualCondition() <= getSettingDurabilityThreshold()*10)
            then
                if getSettingDebug() then
                    print("Your shield's condition got worse! " .. savedShieldCondition .. " -> " .. getEquippedShieldCondition() )
                end
                
                    if (checkForItemBreak(getEquippedShieldCondition(), getEquippedShieldHealth())) then
                    itemBreakAlert(getEquippedShieldName())
                    core.sendGlobalEvent("remove", {object=getShieldSlot()})
                end      
            end
            
            savedShieldCondition = getEquippedShieldCondition()
        
        end
        
    end
    
end,0.5 )  

