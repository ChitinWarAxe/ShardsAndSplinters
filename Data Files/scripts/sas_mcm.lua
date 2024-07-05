local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local time = require('openmw_aux.time')
local ambient = require('openmw.ambient')
local core = require('openmw.core')
local storage = require('openmw.storage')
local I = require('openmw.interfaces')

I.Settings.registerPage {
    key = "ShardsAndSplinters",
    l10n = "ShardsAndSplinters",
    name = 'name',
    description = 'description'
}

I.Settings.registerGroup {
    key = "ShardsAndSplintersSettings",
    l10n = "ShardsAndSplinters",
    name = "settingsTitle",
    page = "ShardsAndSplinters",
    description = "settingsDesc",
    permanentStorage = false,
    settings = {
        {
            key = "brittleWeaponsSetting",
            name = "Enable/Disable Weapons breaking",
            description= "Enable or disable the chance for weapons to shatter when used.",
            default = true,
            renderer = "checkbox"
        },
        {
            key = "breakThresholdSetting",
            name = "Durability Threshold",
            description= "When a weapon's durability falls below this percentage, it becomes at risk of breaking.",
            default = 90,
            renderer = "number"
        },
        {
            key = "luckModifierSetting",
            name = "Luck Modifier",
            description= "Negatively affects how luck reduces the chance of a weapon breaking. A higher number increases the chance of breaking.",
            default = 1.5,
            renderer = "number"
        },
        {
            key = "whiteListedTypesSetting",
            name = "Whitelisted Materials and Types",
            description= "List of materials and weapon types that will not shatter despite being damaged. Keywords are checked to exist within the weapon model.",
            default = "dwemer, ebony, daedric, adamant, w_art, _uni",
            renderer = "textLine"
        },
        {
            key = "brittleDebug",
            name = "Debug Log",
            description= "Enables additional information in the console log for debugging purposes.",
            default = false,
            renderer = "checkbox"
        }
    }
}


