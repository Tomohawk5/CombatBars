local mod = get_mod("combatbars")

mod.colours = {
    -- (optional) [choose]
    -- ui_item_rarity_(dark|desaturated)_[1|2|3|4|5|6]
    kinetic  = "item_rarity_1", -- grey
    grenade  = "item_rarity_2", -- green
    warp     = "item_rarity_3", -- blue
    keystone = "item_rarity_4", -- purple
    aura     = "item_rarity_5", -- orange
    ability  = "item_rarity_6", -- red

    kinetic_dark  = "item_rarity_dark_1", -- grey
    grenade_dark  = "item_rarity_dark_2", -- green
    warp_dark     = "item_rarity_dark_3", -- blue
    keystone_dark = "item_rarity_dark_4", -- purple
    aura_dark     = "item_rarity_dark_5", -- orange
    ability_dark  = "item_rarity_dark_6", -- red

    -- ui_[psyker|veteran|zealot|ogryn]_(text)
    psyker   = "ui_psyker",             -- blue
    veteran  = "ui_veteran",            -- green
    zealot   = "ui_zealot",             -- red
    ogryn    = "ui_ogryn",              -- orange

    disabled = "ui_disabled_text_color" -- dark grey
}

--#region UTILS
local function colour_text(text, color_name)
    local color = Color[color_name or "ui_disabled_text_color"](255, true) -- color[0] = alpha
    return string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4]) .. text .. "{#reset()}"
end

--#endregion

local localizations = {
    mod_name = {
        en = "Combat Bars",
    },
    mod_description = {
        en = "Adds a stamina style bar to the HUD for blitz, combat ability & grenades",
    },

    -- ##############################
    -- #          SETTINGS          #
    -- ##############################
    --#region SETTINGS

    fade_in_out = {
        en = "Fade in/out",
    },
    fade_in_out_description = {
        en = "Bars fade in / out when it changes visiblity.",
    },
    spectator = {
        en = "Spectator view",
    },
    spectator_description = {
        en = "Visiblity when spectating another player.",
    },

    --#region ABILITY
    ability_enabled = {
        en = colour_text("Ability", mod.colours.ability),
    },
    --#endregion
    --#region BLITZ
    blitz_enabled = {
        en = colour_text("Blitz", mod.colours.grenade),
    },
    --#endregion
    --#region KEYSTONE
    keystone_enabled = {
        en = colour_text("Keystone", mod.colours.keystone),
    },
    --#endregion
    --#endregion
}

--#region COLOURS
local function display_name(text)
    local display_text = ""
    local words = string.split(text, "_")
    for _, word in ipairs(words) do
        word = (word:gsub("^%l", string.upper)) -- Parenthesis [https://www.luafaq.org/gotchas.html#T8.1]
        display_text = display_text .. " " .. word
    end
    return display_text
end

local color_names = Color.list
for _, color_name in ipairs(color_names) do
    localizations[color_name] = { en = colour_text(display_name(color_name), color_name) }
end
--#endregion

return localizations
