local mod = get_mod("combatbars")

mod:io_dofile("combatbars/scripts/mods/combatbars/UI/settings")

local HUD_elements = {
    -- "ability", --HudElementCombatBar
    -- "blitz", --HudElementBlitzBar
    -- "keystone" --HudElementKeystoneBar
    "blitz"
}


mod.widget_angles = {}
for _, e in ipairs(HUD_elements) do
    if mod.debugging then mod:notify("Registering HUD:" .. e) end
    mod.widget_angles[e] = 0
    local success = mod:register_hud_element({
        class_name = "HudElementCombatBar_" .. e,
        filename = "combatbars/scripts/mods/combatbars/UI/" .. e .. "/elements",
        use_hud_scale = true,
        visibility_groups = {
            "alive"
        },
        -- validation_function = function(params) -- omit = true
        --     return mod:get(e .. "_enabled")
        -- end
    })
    if mod.debugging then mod:notify(success) end
end