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
            key = "sasBrittleWeaponsToggle",
            name = "sasBrittleWeaponsToggleName",
            description = "sasBrittleWeaponsToggleDesc",
            default = true,
            renderer = "checkbox"
        },
        {
            key = "sasBrittleShieldsToggle",
            name = "sasBrittleShieldsToggleName",
            description = "sasBrittleShieldsToggleDesc",
            default = true,
            renderer = "checkbox"
        },
        {
            key = "sasBreakThreshold",
            name = "sasBreakThresholdName",
            description = "sasBreakThresholdDesc",
            default = 90,
            renderer = "number"
        },
        {
            key = "sasLuckModifier",
            name = "sasLuckModifierName",
            description = "sasLuckModifierDesc",
            default = 1.5,
            renderer = "number"
        },
        {
            key = "sasWhiteListedTypes",
            name = "sasWhiteListedTypesName",
            description = "sasWhiteListedTypesDesc",
            default = "dwemer, ebony, daedric, adamant, anarchy, w_de_fork, w_art, _uni",
            renderer = "textLine"
        },
        {
            key = "sasBrittleDebugToggle",
            name = "sasBrittleDebugToggleName",
            description = "sasBrittleDebugToggleDesc",
            default = false,
            renderer = "checkbox"
        }
    }
}


