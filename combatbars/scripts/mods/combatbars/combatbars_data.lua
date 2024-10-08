local mod = get_mod("combatbars")

--#region UTILS
local function widget(setting_id, type, default_value, sub_widgets)
    local w = {}

    w.setting_id = setting_id
    w.type = type
    w.default_value = default_value

    if sub_widgets then w.sub_widgets = sub_widgets end

    return w
end

local function list_options(enum)
    local options = {}
    for k, v in pairs(enum) do
        table.insert(options, { text = k, value = v })
    end
    return options
end
--#endregion
--#region COLOURS
local colors = {}

for _, color_name in ipairs(Color.list) do
    -- Regex "^(ui|terminal|item)
    if (color_name:find("^ui") ~= nil) or (color_name:find("^terminal") ~= nil) or (color_name:find("^item") ~= nil) then
        table.insert(colors, { text = color_name, value = color_name })
    end
end

table.sort(colors, function(a, b)
    return a.text < b.text
end)

local function get_colors()
    return table.clone(colors)
end
--#endregion
--#region ENUMS
mod.text_options = table.enum(
    "none",
    "text_option_ability",
    "text_option_blitz",
    "text_option_keystone"
)

mod.value_options = table.enum(
    "none",
    "value_option_damage",
    "value_option_stacks",
    "value_option_time_percent",
    "value_option_time_seconds"
)

mod.orientation_options = table.enum(
    "orientation_option_horizontal",
    "orientation_option_horizontal_flipped",
    "orientation_option_vertical",
    "orientation_option_vertical_flipped"
)
--#endregion



function bar_widgets()
    local bars = { "ability", "blitz", "keystone" }
    local default = {
        ability = {
            colour = mod.colours.ability,
            orientation = mod.orientation_options["orientation_option_horizontal"]
        },
        blitz = {
            colour = mod.colours.kinetic,
            orientation = mod.orientation_options["orientation_option_vertical_flipped"]
        },
        keystone = {
            colour = mod.colours.keystone,
            orientation = mod.orientation_options["orientation_option_vertical"]
        }
    }
    local widgets = {}
    for _, bar in pairs(bars) do
        local new_widget = {
            setting_id = bar .. "_enabled",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
                {
                    setting_id = bar .. "_orientation",
                    type = "dropdown",
                    default_value = default[bar].orientation,
                    options = list_options(mod.orientation_options)
                },
                {
                    setting_id = bar .. "_gauge_text",
                    type = "dropdown",
                    default_value = default[bar].text,
                    options = list_options(mod.text_options)
                },
                {
                    setting_id = bar .. "_gauge_value",
                    type = "dropdown",
                    default_value = default[bar].value,
                    options = list_options(mod.value_options)
                },
                {
                    setting_id = bar .. "_gauge_value_text",
                    type = "checkbox",
                    default_value = false
                },
                {
                    setting_id = bar .. "_auto_colour",
                    type = "checkbox",
                    default_value = false
                },
                {
                    setting_id = bar .. "_color_full",
                    type = "dropdown",
                    default_value = default[bar].colour,
                    options = get_colors()
                },
                {
                    setting_id = bar .. "_color_empty",
                    type = "dropdown",
                    default_value = mod.colours.disabled,
                    options = get_colors()
                },
            }
        }
        table.insert(widgets, new_widget)
    end
    return widgets
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "master_options",
                type = "group",
                sub_widgets = {
                    widget("fade_in_out", "checkbox", true),
                    widget("spectator", "checkbox", true),
                    widget("auto_text", "checkbox", true),
                    widget("auto_colour", "checkbox", true),
                    {
                        setting_id = "UI_pip_colour",
                        type = "dropdown",
                        default_value = mod.colours.disabled,
                        options = get_colors()
                    },
                    {
                        setting_id = "UI_bracket_colour",
                        type = "dropdown",
                        default_value = mod.colours.kinetic,
                        options = get_colors()
                    },
                }
            },
            -- widget("ability_enabled", "checkbox", true), -- custom_colours? else class colours
            -- widget("blitz_enabled", "checkbox", true),
            -- widget("keystone_enabled", "checkbox", true),
            {
                setting_id = "blitz_enabled",
                type = "checkbox",
                default_value = true,
                sub_widgets = {
                    {
                        setting_id = "blitz_orientation",
                        type = "dropdown",
                        default_value = mod.orientation_options["orientation_option_vertical"],
                        options = list_options(mod.orientation_options)
                    },
                    {
                        setting_id = "blitz_gauge_text",
                        type = "dropdown",
                        default_value = mod.text_options["text_option_blitz"],
                        options = list_options(mod.text_options)
                    },
                    {
                        setting_id = "blitz_gauge_value",
                        type = "dropdown",
                        default_value = mod.value_options["value_option_stacks"],
                        options = list_options(mod.value_options)
                    },
                    {
                        setting_id = "blitz_gauge_value_text",
                        type = "checkbox",
                        default_value = false
                    },
                    {
                        setting_id = "blitz_auto_colour",
                        type = "checkbox",
                        default_value = false
                    },
                    {
                        setting_id = "blitz_color_full",
                        type = "dropdown",
                        default_value = mod.colours.grenade,
                        options = get_colors()
                    },
                    {
                        setting_id = "blitz_color_empty",
                        type = "dropdown",
                        default_value = mod.colours.disabled,
                        options = get_colors()
                    },
                }
            },

        }
    }
}

--#region bar settings
-- blitz | ability | keystone
-- .. _UI_bracket_colour
-- .. _UI_pip_colour
-- .. "_auto_text_option"
-- .. "_gauge_text" -- set in bar.element.init
--#endregion
