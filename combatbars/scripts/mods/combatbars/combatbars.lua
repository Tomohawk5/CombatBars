local mod = get_mod("combatbars")
mod.debugging = false --TODO: Turn off 
mod.blitz = {
    gauge_text = "<<BLITZ>>"
}
mod.keystone = {
    gauge_text = "<<KEYSTONE>>"
}

mod:io_dofile("combatbars/scripts/mods/combatbars/UI/register")

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
    if mod.debugging then mod:echo(view_name) end
    if view_name == "dmf_options_view"
        or view_name == "inventory_view"
        or view_name == "inventory_background_view"
        or view_name == "talent_builder_view" then
        recreate_hud()
    end
end)

mod:command("CBdebug", "", function()
    mod.debugging = not mod.debugging
    mod:echo(" CBdebug -> " .. (mod.debugging and "On" or "Off"))
end)

mod._is_in_hub = function()
    local game_mode_name = Managers.state.game_mode:game_mode_name()
    return (game_mode_name == "hub" or game_mode_name == "prologue_hub")
  end