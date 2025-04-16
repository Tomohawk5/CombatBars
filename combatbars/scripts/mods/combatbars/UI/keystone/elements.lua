local mod = get_mod("combatbars")

local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local TalentSettings = mod:original_require("scripts/settings/talent/talent_settings")

local HudElementBar = mod:io_dofile("combatbars/scripts/mods/combatbars/UI/settings")
local Definitions = mod:io_dofile("combatbars/scripts/mods/combatbars/UI/keystone/definitions")
local HudElementCombatBar_keystone = class("HudElementCombatBar_keystone", "HudElementBase")

HudElementCombatBar_keystone.init = function(self, parent, draw_layer, start_scale)
    HudElementCombatBar_keystone.super.init(self, parent, draw_layer, start_scale, Definitions)

    self._parent = parent

    self._shields = {}
    self._shield_width = 0
    self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

    self._player = Managers.player:local_player(1)
    self._archetype_name = self._player:archetype_name()

    self._enabled = mod:get("keystone_enabled")

    self.keystone = nil

    if not self.keystone and self._parent then
        local registered = self:_register_keystone()
        if mod.debugging then mod:echo(registered and "Keystone Registered" or "-") end
    end

    if mod:get("keystone_auto_colour") then
        self.color_full_name = mod.colours[self._archetype_name]
        self.color_empty_name = mod.colours[self._archetype_name] .. "_text"
    else
        self.color_full_name = mod:get("keystone_color_full")
        self.color_empty_name = mod:get("keystone_color_empty")
    end


end

HudElementCombatBar_keystone._register_keystone = function(self)
    local player_extensions = self._parent:player_extensions()
    local talent_extension = ScriptUnit.extension(self._player.player_unit, "talent_system")

    local profile = self._player:profile()

    if not player_extensions or not talent_extension or not profile then return false end

    local player_talents = profile.talents
    local archetype_talents = profile.archetype.talent

--#region
                -- KEYSTONE

                --psyker 
                -- psyker_passive_souls_from_elite_kills
                -- psyker_empowered_ability
                -- psyker_new_mark_passive

                --veteran
                -- veteran_snipers_focus
                -- veteran_improved_tag
                -- veteran_weapon_switch_passive

                --zealot
                -- zealot_fanatic_rage
                -- zealot_martyrdom
                -- zealot_quickness_passive

                --ogryn
                -- ogryn_heavy_hitter 
                -- ogryn_carapace_armor
                -- ogryn_leadbelcher ?
                
                -- --psyker_empowered_ability EMPOLWERED PSIONICS
                -- talent_extension:has_special_rule("psyker_empowered_grenades")
                
                -- --psyker_overcharge_stance_infinite_casting
                -- buff_extension:has_buff_using_buff_template("psyker_overcharge_stance")

                -- talent_extension:has_special_rule("psyker_overcharge_stance_infinite_casting")

                -- talent_extension:has_special_rule("psyker_increased_max_souls")
--#endregion

    self.keystone = {
        name = "keystone",
        stacks = 0,
        max_stacks = nil,
        stack_buff = nil,       -- BUFF THAT DETERMINES STACK COUNT
        stack_value = nil,
        stack_duration = nil,
        duration = 0,
        replenish = false,      -- DOES THE BUFF REFILL ITSELF ?
        replenish_buff = nil,   -- BUFF THAT DETEMINES REFILL
        timed = false,          -- DOES THE BUFF HAVE A TIMER ?
        decay = false           -- STACKS FALL OFF 1 AT A TIME ?
    }

    if self._archetype_name == "psyker" then
        if player_talents.psyker_passive_souls_from_elite_kills == 1 then

            local warp_siphon = TalentSettings.psyker_2.passive_1 -- [base_max_souls = 4, damage = 0.24, soul_duration = 25]
            local warp_battery = TalentSettings.psyker_2.offensive_2_1.max_souls_talent -- 6

            self.keystone.name = mod.text_options["text_option_soul"]
            self.keystone.stack_buff = talent_extension:has_special_rule("psyker_increased_max_souls") and "psyker_souls_increased_max_stacks" or "psyker_souls"
            self.keystone.max_stacks = talent_extension:has_special_rule("psyker_increased_max_souls") and warp_battery or warp_siphon.base_max_souls
            self.keystone.stack_value = warp_siphon.damage / warp_battery
            self.keystone.stack_duration = warp_siphon.soul_duration
            self.keystone.timed = true
            self.keystone.decay = true

        end

        if player_talents.psyker_empowered_ability == 1 then
            local increased_stacks = talent_extension:has_special_rule("psyker_empowered_grenades_increased_max_stacks")

            self.keystone.name = "empowered psyonics"
            self.keystone.max_stacks = increased_stacks and TalentSettings.psyker_3.offensive_2.max_stacks_talent or 1
            self.keystone.stack_buff = increased_stacks and "psyker_empowered_grenades_passive_visual_buff_increased" or "psyker_empowered_grenades_passive_visual_buff"
        end

        if player_talents.psyker_new_mark_passive then
            local increased_stacks = talent_extension:has_special_rule("psyker_mark_increased_max_stacks")
		    local increased_duration = talent_extension:has_special_rule("psyker_mark_increased_duration")

            self.keystone.name = "disrupt destiny"
            self.keystone.max_stacks = increased_stacks and 25 or 15
            self.keystone.stack_buff =  (increased_stacks and "psyker_marked_enemies_passive_bonus_stacking_increased_stacks") or
                                        (increased_duration and "psyker_marked_enemies_passive_bonus_stacking_increased_duration") or
                                        "psyker_marked_enemies_passive_bonus_stacking"
            self.keystone.stack_value = 0.01
            self.keystone.stack_duration = increased_duration and 10 or 5
            self.keystone.timed = true
            self.keystone.decay = true
        end
    end

    if self._archetype_name == "ogryn" then
        if player_talents.ogryn_passive_heavy_hitter then
            self.keystone.name = "heavy hitter"
            self.keystone.max_stacks = 8
            self.keystone.stack_buff = "ogryn_heavy_hitter_damage_effect" --"ogryn_passive_heavy_hitter" --"ogryn_heavy_hitter_damage_effect"
            self.keystone.stack_value = 0.05
            self.keystone.stack_duration = 7.5
            self.keystone.timed = true
            --self.keystone.decay = true
        end

        -- ogryn_heavy_hitter = {
		-- 	cleave = 0.15,
		-- 	heavy_stacks = 2,
		-- 	max_stacks = 8,
		-- 	melee_damage = 0.03,
		-- 	stacks = 1,
		-- 	stagger = 0.1,
		-- 	tdr = 0.015,
		-- 	toughness_melee_replenish = 0.15,
		-- },

        if player_talents.ogryn_carapace_armor then
            self.keystone.name = "feel no pain"
            self.keystone.max_stacks = 10
            self.keystone.stack_buff = "ogryn_carapace_armor_child"
            self.keystone.stack_value = 0.025
            self.keystone.stack_duration = 6
            self.keystone.timed = true
            self.keystone.replenish = true
            self.keystone.replenish_buff = "ogryn_carapace_armor_parent"
        end

        if player_talents.ogryn_leadbelcher_no_ammo_chance then
            self.keystone.name = "burst limiter override"
            self.keystone.max_stacks = 10
            self.keystone.stack_buff = "ogryn_blo_stacking_buff"
            self.keystone.stack_value = 0.02
            self.keystone.stack_duration = 10
            self.keystone.timed = true
        end
    end

    local refill = talent_extension:has_special_rule("ogryn_carapace_armor") or talent_extension:has_special_rule("veteran_improved_tag")
    if mod.debugging then mod:echo("Replenish: " .. (self.keystone.replenish and "t" or "f")) end

    if mod.debugging then
        mod:echo("> KEYSTONE")
        mod:echo("name " .. self.keystone.name)
        mod:echo("buff " .. self.keystone.stack_buff .. " " .. (self.keystone.replenish_buff or "-"))
        mod:echo("stacks " .. self.keystone.stacks .. " " .. self.keystone.max_stacks)
        mod:echo("duration " .. self.keystone.duration .. " " .. (self.keystone.stack_duration or "-"))
        mod:echo("Timed Replenish Decay " .. (self.keystone.timed and "T" or "F") .. " " .. (self.keystone.replenish and "T" or "F") .. " " .. (self.keystone.decay and "T" or "F"))
        mod:echo("< KEYSTONE")
    end

    if mod:get("keystone_gauge_text") == "text_option_auto" then
        if mod.debugging then
            mod:notify(self.keystone.name)
            mod:notify(player_talents[self.keystone.name])
        end

        mod.keystone.gauge_text = self.keystone.name
    elseif mod:get("keystone_gauge_text") == "text_option_none" then
        mod.keystone.gauge_text = ""
    else
        mod.keystone.gauge_text = Utf8.upper(mod:localize(mod:get("keystone_gauge_text")))
    end

    return true
end

HudElementCombatBar_keystone.destroy = function(self)
    HudElementCombatBar_keystone.super.destroy(self)
end

HudElementCombatBar_keystone._add_shield = function(self)
    self._shields[#self._shields + 1] = {}
end

HudElementCombatBar_keystone._remove_shield = function(self)
    self._shields[#self._shields] = nil
end

HudElementCombatBar_keystone.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    HudElementCombatBar_keystone.super.update(self, dt, t, ui_renderer, render_settings, input_service)
    if not self._enabled then return end

    local widget = self._widgets_by_name.gauge
    if not widget then return end

    if not self.keystone then
        local registered = self:_register_keystone()
        if mod.debugging then mod:notify(registered and "Keystone Registered" or "-") end
        if not registered then return end
    end

    local parent = self._parent
    local player_extensions = parent:player_extensions()

    if player_extensions then
        local buff_extension = player_extensions.buff

        if buff_extension then
            local found_buff = 0
            local found_buff_target = 1 + (self.keystone.replenish and 1 or 0)
            local stack_buff = self.keystone.stack_buff
            local buffs = buff_extension:buffs()

            for i = 1, #buffs do
                local buff_instance = buffs[i]
                local instance_buff_name = buff_instance:template_name()

                if self.keystone.replenish and (instance_buff_name == self.keystone.replenish_buff) then
                    found_buff = found_buff + 1
                    self.keystone.duration = buff_instance:duration_progress()
                    if found_buff == found_buff_target then break end
                end

                if instance_buff_name == stack_buff then
                    found_buff = found_buff + 1
                    self.keystone.stacks = math.min(buff_instance:stack_count(), self.keystone.max_stacks)
                    if not self.keystone.replenish then self.keystone.duration = buff_instance:duration_progress() end
                    if found_buff == found_buff_target then break end
                end
            end

            if not found_buff then
                self.keystone.stacks = 0
                self.keystone.duration = 0
            end
        end
    end

    self:_update_shield_amount()

    if mod:get("fade_in_out") and not self.keystone.replenish then
        self:_update_visibility(dt)
    else
        widget.content.visible = true
    end
end
HudElementCombatBar_keystone._resize_shield = function(self)
    local shield_amount         = self.keystone.max_stacks or 0
    local bar_size              = HudElementBar.bar_size
    local segment_spacing       = HudElementBar.spacing
    local total_segment_spacing = segment_spacing * math.max(shield_amount - 1, 0)
    local total_bar_length      = bar_size[1] - total_segment_spacing

    self._shield_width          = math.round(shield_amount > 0 and total_bar_length / shield_amount or total_bar_length)
    local shield_height         = 9

    local orientation = mod:get("keystone_orientation")

    local horizontal            = orientation == "orientation_option_horizontal" or orientation == "orientation_option_horizontal_flipped"
    self._horizontal            = horizontal

    local flipped               = orientation == "orientation_option_horizontal_flipped" or orientation == "orientation_option_vertical_flipped"
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

    local style = HudElementBar.styles[mod:get("keystone_orientation")]

    value_text_style.horizontal_alignment      = style.value_horizontal_alignment
    value_text_style.text_horizontal_alignment = style.value_text_horizontal_alignment
    value_text_style.offset                    = style.value_offset

    name_text_style.horizontal_alignment       = style.name_horizontal_alignment
    name_text_style.text_horizontal_alignment  = style.name_text_horizontal_alignment
    name_text_style.offset                     = style.name_offset

    warning_style.angle                        = style.angle

end

HudElementCombatBar_keystone._update_shield_amount = function(self)
    local shield_amount = self.keystone.max_stacks or 0
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

HudElementCombatBar_keystone._update_visibility = function(self, dt)
    local draw = self.keystone.stacks > 0 or self.keystone.replenish

    local alpha_speed = 1
    local alpha_multiplier = self._alpha_multiplier or 0

    if draw then
        alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
    else
        alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
    end

    self._alpha_multiplier = alpha_multiplier
end

HudElementCombatBar_keystone._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
    if not self._enabled or mod._is_in_hub() then return end

    if self._alpha_multiplier ~= 0 then
        local previous_alpha_multiplier = render_settings.alpha_multiplier
        render_settings.alpha_multiplier = self._alpha_multiplier

        local gauge_widget = self._widgets_by_name.gauge
        gauge_widget.content.value_text = self:_get_value_text()

        HudElementCombatBar_keystone.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

        self:_draw_shields(dt, t, ui_renderer)

        render_settings.alpha_multiplier = previous_alpha_multiplier
    end
end

HudElementCombatBar_keystone._get_value_text = function(self)
    if not self.keystone then return "" end

    local prefix = mod:get("keystone_gauge_value_prefix")
    local option = mod:get("keystone_gauge_value")

    if option == "value_option_auto" then
        if self.keystone.timed then  option = "value_option_time_percent"
        else                        option = "value_option_stacks" end
    end

    local value = ""
    if option == "value_option_stacks" then
        value = string.format(
            prefix and mod:localize(option) .. "%.0fx" or "%.0fx",
            self.keystone and self.keystone.stacks or 0)
    end
    if option == "value_option_time_seconds" and self.keystone.timed then
        local time_s = (self.keystone.stack_duration * self.keystone.duration) or 0
        local format_string =
            time_s > 10 and "%.0fs" or
            time_s > 1  and "%.1fs" or
            time_s == 0 and "0s"    or
                            "%.2fs"

        value = string.format(format_string, time_s) --["%." .. (time_s > 1 and "0" or "2") .. "fs"]
    end
    if option == "value_option_time_percent" and self.keystone.timed then
        value = string.format("%02.0f%%", self.keystone.duration * 100 or 0)
    end
    if option == "value_option_value" and self.keystone.stack_value then
        value = string.format("%.2f", ((self.keystone.stack_value or 0) * self.keystone.stacks))
    end

    return (prefix and mod:localize(option) or "") .. value
end

HudElementCombatBar_keystone._draw_shields = function(self, dt, t, ui_renderer)
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

    local progress = (self.keystone.timed and self.keystone.duration) or 0.99
    local stacks = self.keystone.stacks - (self.keystone.replenish and 0 or 1)
    local souls_progress = (progress + (stacks)) / self.keystone.max_stacks

    local decay = self.keystone.decay

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

return HudElementCombatBar_keystone
