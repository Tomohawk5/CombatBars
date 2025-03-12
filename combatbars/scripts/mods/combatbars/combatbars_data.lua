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
    "text_option_none",
    "text_option_auto",
    "text_option_ability",
    "text_option_blitz",
    "text_option_keystone",
    "text_option_krak"
)

mod.value_options = table.enum(
    "value_option_none",
    "value_option_auto",
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
                    widget("fade_in_out", "checkbox", false),
                    widget("spectator", "checkbox", true),
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
            {
                setting_id = "blitz_enabled",
                type = "checkbox",
                default_value = true,
                sub_widgets = {
                    {
                        setting_id = "blitz_orientation",
                        type = "dropdown",
                        default_value = mod.orientation_options["orientation_option_horizontal"],
                        options = list_options(mod.orientation_options)
                    },
                    {
                        setting_id = "blitz_gauge_text",
                        type = "dropdown",
                        default_value = "text_option_auto",
                        --options = list_options(mod.text_options)
                        options = {
                            { text = "text_option_none", value = "text_option_none" },
                            { text = "text_option_auto", value = "text_option_auto" },
                            { text = "text_option_blitz", value = "text_option_blitz" },
                        }
                    },
                    {
                        setting_id = "blitz_gauge_value",
                        type = "dropdown",
                        default_value = "value_option_auto",
                        options = list_options(mod.value_options)
                    },
                    {
                        setting_id = "blitz_gauge_value_prefix",
                        type = "checkbox",
                        default_value = false
                    },
                    {
                        setting_id = "blitz_auto_colour",
                        type = "checkbox",
                        default_value = true,
                        sub_widgets = {
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
            },
        }
    }
}
