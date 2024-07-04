local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local time = require('openmw_aux.time')
local ambient = require('openmw.ambient')
local core = require('openmw.core')
local storage = require('openmw.storage')
local interfaces = require('openmw.interfaces')

local modId = "ShardsAndSplinters"
local modSettingsKey = "settings" .. modId
local settings = storage.playerSection(modSettingsKey)

interfaces.Settings.registerPage {
    key = modId,
    l10n = modId,
    name = 'name',
    description = 'description'
}

interfaces.Settings.registerGroup {
    key = modSettingsKey,
    l10n = modId,
    name = "settingsTitle",
    page = modId,
    description = "settingsDesc",
    permanentStorage = false,
    settings = {
        {
            key = "brittleWeaponsSetting",
            name = "Brittle Weapons",
            description= "Certain Weapons have a chance to shatter.",
            default = true,
            renderer = "checkbox"
        },
        {
            key = "breakThresholdSetting",
            name = "Durability threshold",
            description= "If the durability of a weapon falls below this threshold in %, the weapon will be at risk of breaking.",
            default = 90,
            renderer = "number"
        },
        {
            key = "luckModifierSetting",
            name = "Luck Modifier",
            description= "Negativly impacts how luck is decreasing the break chance. A higher number means a greater breaking chance.",
            default = 1.5,
            renderer = "number"
        },
        {
            key = "whiteListedTypesSetting",
            name = "Whitelisted Materials and Types",
            description= "List of materials and types of weapons that deemed of higher quality, and will not shatter despite being damaged. Keywords are based on the weapon model.",
            default = "dwemer, ebony, daedric, adamantium, w_art, _uni",
            renderer = "textLine"
        },
        {
            key = "brittleDebug",
            name = "Debug Log",
            description= "Adds info to the console log for debugging. ",
            default = false,
            renderer = "checkbox"
        }
    }
}

math.randomseed(os.time())

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

