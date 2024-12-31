local mod = get_mod("combatbars")

local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local HudElementBar = mod:io_dofile("combatbars/scripts/mods/combatbars/UI/settings")
local Definitions = mod:io_dofile("combatbars/scripts/mods/combatbars/UI/blitz/definitions")
local HudElementCombatBar_blitz = class("HudElementCombatBar_blitz", "HudElementBase")

HudElementCombatBar_blitz.init = function(self, parent, draw_layer, start_scale)
    HudElementCombatBar_blitz.super.init(self, parent, draw_layer, start_scale, Definitions)

    self._parent = parent

    self._shields = {}
    self._shield_width = 0
    self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

    self._player = Managers.player:local_player(1)
    self._archetype_name = self._player:archetype_name()

    self._enabled = mod:get("blitz_enabled")

    self.ability = nil

    if not self.ability and self._parent then
        local registered = self:_register_ability()
        if mod.debugging then mod:echo(registered and "Ability Registered" or "-") end
    end

    -- TODO: Move this comment to ability
    -- if mod:get("auto_colour") then
    --     self.color_full_name = "ui_" .. self._archetype_name
    --     self.color_empty_name = "ui_" .. self._archetype_name .. "_text"

    if mod:get("blitz_auto_colour") then
        if self._archetype_name == "psyker" then
            self.color_full_name = mod.colours.warp
            self.color_empty_name = mod.colours.warp_dark
        else
            self.color_full_name = mod.colours.grenade
            self.color_empty_name = mod.colours.grenade_dark
        end
    else
        self.color_full_name = mod:get("blitz_color_full")
        self.color_empty_name = mod:get("blitz_color_empty")
    end


end

HudElementCombatBar_blitz._register_ability = function(self)
    local player_extensions = self._parent:player_extensions()
    local talent_extension = ScriptUnit.extension(self._player.player_unit, "talent_system")

    local profile = self._player:profile()

    if not player_extensions or not talent_extension or not profile then return false end

    local ability_extension = player_extensions.ability
    if not ability_extension then return false end

    local player_talents = profile.talents
    --local player_talents = talent_extension:talents()
    local archetype_talents = profile.archetype.talents


--#region
                -- BLITZ

                --psyker 
                -- psyker_smite
                -- psyker_chain_lightning
                -- psyker_throwing_knives

                --veteran
                -- veteran_frag_grenade
                -- veteran_smoke_grenade
                -- veteran_krak_grenade

                --zealot
                -- zealot_shock_grenade
                -- zealot_fire_grenade
                -- zealot_throwing_knives

                --ogryn
                -- ogryn_grenade_frag
                -- ogryn_grenade_box
                -- ogryn_grenade_box_cluster
                -- ogryn_grenade_friend_rock

                
                -- psyker_grenade_throwing_knives
                -- PlayerAbilities.psyker_throwing_knives
                -- buff_template_name = "psyker_knife_replenishment"
			    -- player_talents.psyker_throwing_knives_reduced_cooldown
                -- buff_template_name = "psyker_reduced_throwing_knife_cooldown"
                
                -- --psyker_empowered_ability EMPOLWERED PSIONICS
                -- talent_extension:has_special_rule("psyker_empowered_grenades")
                
                
                -- --psyker_overcharge_stance_infinite_casting
                -- buff_extension:has_buff_using_buff_template("psyker_overcharge_stance")

                -- talent_extension:has_special_rule("psyker_overcharge_stance_infinite_casting")

                -- talent_extension:has_special_rule("psyker_increased_max_souls")
--#endregion


    local ability_type = "grenade_ability" -- or "combat_ability"
    local equipped_ability = ability_extension:equipped_abilities().grenade_ability
    if not equipped_ability then return false end

    local refill = talent_extension:has_special_rule("veteran_grenade_replenishment") or player_talents.ogryn_grenade_friend_rock or player_talents.psyker_grenade_throwing_knives
    if mod.debugging then mod:echo("refill: " .. (refill and "t" or "f")) end

    local name = equipped_ability.name
    local psyker_blitz = name == "psyker_chain_lightning" or name == "psyker_smite"

    self.ability = {
        cooldown            = ability_extension:remaining_ability_cooldown(ability_type),
        max_cooldown        = ability_extension:max_ability_cooldown(ability_type),
        custom_cooldown     = psyker_blitz,
        cooldown_percent    =   (function()
                                    if self.ability.cooldown == 0 or self.ability.max_cooldown == 0 then return 1 end
                                    return 1 - (self.ability.cooldown / self.ability.max_cooldown)
                                end),
        charges             = psyker_blitz and 1 or ability_extension:remaining_ability_charges(ability_type),
        max_charges         = psyker_blitz and 1 or ability_extension:max_ability_charges(ability_type),

        name                = name,
        timed               = refill,
        replenish           = refill or psyker_blitz,
        decay               = true
    }

    if mod.debugging then
        mod:echo("name " .. self.ability.name)
        mod:echo("cooldown " .. self.ability.cooldown .. " " .. self.ability.max_cooldown)
        mod:echo("charges " .. self.ability.charges .. " " .. self.ability.max_charges)
        mod:echo("Timed Replenish Decay " .. (self.ability.timed and "T" or "F") .. " " .. (self.ability.replenish and "T" or "F") .. " " .. (self.ability.decay and "T" or "F"))
    end

    if mod:get("blitz_gauge_text") == "text_option_auto" then
        if mod.debugging then
            mod:notify(self.ability.name)
            mod:notify(player_talents[self.ability.name]) --TODO: nil on psyker (talent is psyker_grenade_throwing_knives)
            --if player_talents[self.ability.name] then mod:notify(player_talents[self.ability.name].display_name) end
        end

        --mod.blitz.gauge_text = Utf8.upper(Localize(player_talents[self.ability.name].display_name)) work for abilities whose name matches thier talent
        mod.blitz.gauge_text = self.ability.name
    else
        mod.blitz.gauge_text = Utf8.upper(mod:localize(mod:get("blitz_gauge_text")))
    end

    return true
end

HudElementCombatBar_blitz.destroy = function(self)
    HudElementCombatBar_blitz.super.destroy(self)
end

HudElementCombatBar_blitz._add_shield = function(self)
    self._shields[#self._shields + 1] = {}
end

HudElementCombatBar_blitz._remove_shield = function(self)
    self._shields[#self._shields] = nil
end

HudElementCombatBar_blitz.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    HudElementCombatBar_blitz.super.update(self, dt, t, ui_renderer, render_settings, input_service)
    if not self._enabled then return end

    local widget = self._widgets_by_name.gauge
    if not widget then return end

    --TODO: Logic here blitzbar/scripts/mods/blitzbar/UI/UI_elements.lua[594<->652]


    if not self.ability then
        local registered = self:_register_ability()
        if mod.debugging then mod:notify(registered and "Ability Registered" or "-") end
        if not registered then return end
    end

    local parent = self._parent
    local player_extensions = parent:player_extensions()

    if player_extensions then

        local ability_extension = player_extensions.ability

        if ability_extension and ability_extension:ability_is_equipped("grenade_ability") then

            self.ability.charges = ability_extension:remaining_ability_charges("grenade_ability")
            --self.ability.max_charges = ability_extension:max_ability_charges("grenade_ability")

            self.ability.cooldown = ability_extension:remaining_ability_cooldown("grenade_ability")
        end

        if self.ability.custom_cooldown then
            if self.ability.name == "psyker_chain_lightning" then
                self.ability.cooldown = 0.75
            elseif self.ability.name == "psyker_smite" then
                self.ability.cooldown = 0.50
            else
                self.ability.cooldown = 0.25
            end
        else
            if self.ability.max_cooldown == 0 then self.ability.cooldown = 0 end
        end
    end

    self:_update_shield_amount()

    if mod:get("fade_in_out") and not self.ability.replenish then
        self:_update_visibility(dt)
    else
        widget.content.visible = true
    end
end
HudElementCombatBar_blitz._resize_shield = function(self)
    local shield_amount         = self.ability.max_charges or 0
    local bar_size              = HudElementBar.bar_size
    local segment_spacing       = HudElementBar.spacing
    local total_segment_spacing = segment_spacing * math.max(shield_amount - 1, 0)
    local total_bar_length      = bar_size[1] - total_segment_spacing

    self._shield_width          = math.round(shield_amount > 0 and total_bar_length / shield_amount or total_bar_length)
    local shield_height         = 9

    local horizontal            = mod:get("blitz_orientation") == "orientation_option_horizontal" or mod:get("blitz_orientation") == "orientation_option_horizontal_flipped"
    self._horizontal            = horizontal

    local flipped               = mod:get("blitz_orientation") == "orientation_option_horizontal_flipped" or mod:get("blitz_orientation") == "orientation_option_vertical_flipped"
    self._flipped               = flipped

    local width                 = horizontal and self._shield_width or shield_height
    local height                = horizontal and shield_height or self._shield_width

    self:_set_scenegraph_size("shield", width, height)

    local widget = self._widgets_by_name.gauge
    if not widget then return end

    local gauge_style                          = widget.style
    local value_text_style                     = gauge_style.value_text
    local name_text_style                      = gauge_style.name_text
    local warning_style                        = gauge_style.warning

    local style = HudElementBar.styles[mod:get("blitz_orientation")]

    value_text_style.horizontal_alignment      = style.value_horizontal_alignment
    value_text_style.text_horizontal_alignment = style.value_text_horizontal_alignment
    value_text_style.offset                    = style.value_offset

    name_text_style.horizontal_alignment       = style.name_horizontal_alignment
    name_text_style.text_horizontal_alignment  = style.name_text_horizontal_alignment
    name_text_style.offset                     = style.name_offset

    warning_style.angle                        = style.angle

end

HudElementCombatBar_blitz._update_shield_amount = function(self)
    local shield_amount = self.ability.max_charges or 0
    if shield_amount ~= self._shield_amount then
        local amount_difference = (self._shield_amount or 0) - shield_amount
        self._shield_amount = shield_amount

        self:_resize_shield()

        local add_shields = amount_difference < 0

        for _ = 1, math.abs(amount_difference) do
            if add_shields then
                self:_add_shield()
            else
                self:_remove_shield()
            end
        end
    end
end

HudElementCombatBar_blitz._update_visibility = function(self, dt)
    local draw = self.ability.charges > 0 or self.ability.replenish --or resource_info.replenish

    local alpha_speed = 1 --3
    local alpha_multiplier = self._alpha_multiplier or 0

    if draw then
        alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
    else
        alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
    end

    self._alpha_multiplier = alpha_multiplier
end

HudElementCombatBar_blitz._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
    if not self._enabled or mod._is_in_hub() then return end

    if self._alpha_multiplier ~= 0 then
        local previous_alpha_multiplier = render_settings.alpha_multiplier
        render_settings.alpha_multiplier = self._alpha_multiplier

        local gauge_widget = self._widgets_by_name.gauge
        gauge_widget.content.value_text = self:_get_value_text()

        HudElementCombatBar_blitz.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

        self:_draw_shields(dt, t, ui_renderer)

        render_settings.alpha_multiplier = previous_alpha_multiplier
    end
end

HudElementCombatBar_blitz._get_value_text = function(self)
    if not self.ability then return "" end
    local option = mod:get("blitz_gauge_value")
    if option == "value_option_stacks" then
        return string.format("%.0fx", self.ability and self.ability.charges or 0)
    end
    if option == "value_option_time_seconds" then
        return string.format("%.2fs", self.ability and self.ability.cooldown or 0)
    end
    if option == "value_option_time_percent" then
        return string.format("%02.0f%%", self.ability and self.ability:cooldown_percent() * 100 or 0)
    end
    return ""
end

HudElementCombatBar_blitz._draw_shields = function(self, dt, t, ui_renderer)
    local num_shields = self._shield_amount

    if not num_shields then return end
    if num_shields < 1 then return end

    local spacing = HudElementBar.spacing
    local shield_offset
    if self._horizontal then
        shield_offset = (self._shield_width + spacing) * (num_shields - 1) * 0.5
    else
        shield_offset = ((self._shield_width - spacing) * (num_shields + 0) * 0.5)
                        - (HudElementBar.bar_size[1] - spacing * (num_shields + 1))
    end

    local progress = (self.ability.timed and self.ability.cooldown_percent()) or 0.99
    local stacks = self.ability.charges - (self.ability.replenish and 0 or 1)
    local souls_progress = (progress + (stacks)) / self.ability.max_charges

    local decay = self.ability.decay

    local step_fraction = 1 / num_shields

    for i = num_shields, 1, -1 do
        local shield = self._shields[i]

        if not shield then return end

        local end_value = i * step_fraction
        local start_value = end_value - step_fraction

        local value
        if souls_progress >= end_value then
            value = decay and 1 or progress
        elseif start_value < souls_progress then
            value = progress
        else
            value = 0
        end

        local color_full = Color[self.color_full_name](255, true)
        local color_empty = Color[self.color_empty_name](value == 1 and 255 or 100, true)

        for e = 1, 4 do
            self._shield_widget.style.full.color[e] = math.lerp(color_empty[e], color_full[e], value)
        end

        if self._horizontal then
            self._shield_widget.offset[1] = shield_offset
            self._shield_widget.offset[2] = self._flipped and 2 or 1
        else
            self._shield_widget.offset[1] = 0
            self._shield_widget.offset[2] = shield_offset
        end

        UIWidget.draw(self._shield_widget, ui_renderer) -- TODO: Add dirty checks for performance

        if self._horizontal then
            shield_offset = shield_offset - self._shield_width - spacing
        else
            shield_offset = shield_offset + self._shield_width + spacing
        end

    end
end

return HudElementCombatBar_blitz
