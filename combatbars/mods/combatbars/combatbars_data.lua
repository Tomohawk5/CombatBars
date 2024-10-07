local mod = get_mod("combatbars")

local function widget(setting_id, type, default_value, sub_widgets)
    local w = {}

    w.setting_id = setting_id
    w.type = type
    w.default_value = default_value

    if sub_widgets then w.sub_widgets = sub_widgets end

    return w
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
                }
            },
            widget("ability_enabled", "checkbox", true),
            widget("blitz_enabled", "checkbox", true),
            widget("keystone_enabled", "checkbox", true),
        }
    }
}
