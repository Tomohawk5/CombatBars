local mod = get_mod("combatbars")
mod.debugging = true


mod:register_hud_element({
    class_name = "ExampleElement",
    filename = "path/to/element",
    use_hud_scale = true,
    visibility_groups = {
        "alive"
    },
    validation_function = function(params)
        return mod:is_enabled()
    end
})

local function recreate_hud()
    local ui_manager = Managers.ui
    if ui_manager then
        local hud = ui_manager._hud
        if hud then
            local player = Managers.player:local_player(1)
            local peer_id = player:peer_id()
            local local_player_id = player:local_player_id()
            local elements = hud._element_definitions
            local visibility_groups = hud._visibility_groups

            hud:destroy()
            ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
        end
    end
end

function mod.on_all_mods_loaded()
    recreate_hud()
end

function mod.on_unload(exit_game)
end

local UIViewHandler = mod:original_require("scripts/managers/ui/ui_view_handler")
mod:hook_safe(UIViewHandler, "close_view", function(self, view_name, force_close)
    --mod:echo(view_name)
    if view_name == "dmf_options_view"
        or view_name == "inventory_view"
        or view_name == "inventory_background_view"
        or view_name == "talent_builder_view" then
        recreate_hud()
    end
end)

mod:command("CB.debug", "", function()
    mod.debugging = not mod.debugging
end)
