local mod = get_mod("combatbars")

local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local HudElementBar = mod:io_dofile("combatbars/scripts/mods/combatbars/UI/settings")
local Definitions = mod:io_dofile("combatbars/scripts/mods/combatbars/UI/blitz/definitions")
local HudElementBlitzBar = class("HudElementBlitzBar", "HudElementBase")

local resource_info_template = {
    display_name = nil,
    max_stacks = nil,
    max_duration = nil,
    decay = nil,           -- STACKS FALL OFF 1 AT A TIME ?
    grenade_ability = nil,
    talent_resource = nil, -- unit_data_extension:read_component("talent_resource")
    stack_buff = nil,      -- BUFF THAT DETERMINES STACK COUNT
    stacks = 0,
    progress = 0,
    timed = nil,          -- DOES THE BUFF HAVE A TIMER ?
    replenish = nil,      -- DOES THE BUFF REFILL ITSELF ?
    replenish_buff = nil, -- BUFF THAT DETEMINES REFILL
    damage_per_stack = nil,
    damage_boost = function(self)
        if not self.stacks then return nil end
        if not self.max_stacks then return nil end
        if not self.damage_per_stack then return nil end

        return math.min(self.stacks, self.max_stacks) * self.damage_per_stack
    end
}

local resource_info

HudElementBlitzBar.init = function(self, parent, draw_layer, start_scale)
    HudElementBlitzBar.super.init(self, parent, draw_layer, start_scale, Definitions)

    self._shields = {}
    self._shield_width = 0
    self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

    self._player = Managers.player:local_player(1)
    self._archetype_name = self._player:archetype_name()

    self._enabled = mod:get("blitz_show_gauge")

    -- TODO: Move this comment to ability
    -- if mod:get("auto_colour") then
    --     self.color_full_name = "ui_" .. self._archetype_name
    --     self.color_empty_name = "ui_" .. self._archetype_name .. "_text"

    if mod:get("auto_colour") then
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

    resource_info = {}

    resource_info.stacks = 5
    resource_info.max_stacks = 10

    if resource_info == nil then
        resource_info = {
            display_name = mod.text_options["none"],
            max_stacks = nil,
            max_duration = nil,
            decay = true,
            grenade_ability = false,
            stack_buff = nil,
            stacks = nil,
            progress = nil,
            timed = nil,
            replenish = nil,
            replenish_buff = nil,
            damage_per_stack = nil,
            damage_boost = nil
        }
        mod:error("No Blitz")
    end

    mod:set("blitz_gauge_text", mod:get("blitz_auto_text_option")
        and resource_info.display_name
        or mod.text_options["text_option_blitz"])
end

HudElementBlitzBar.destroy = function(self)
    HudElementBlitzBar.super.destroy(self)
end

HudElementBlitzBar._add_shield = function(self)
    self._shields[#self._shields + 1] = {}
end

HudElementBlitzBar._remove_shield = function(self)
    self._shields[#self._shields] = nil
end

HudElementBlitzBar.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    HudElementBlitzBar.super.update(self, dt, t, ui_renderer, render_settings, input_service)
    if not self._enabled then return end

    local widget = self._widgets_by_name.gauge
    if not widget then return end

    --TODO: Logic here blitzbar/scripts/mods/blitzbar/UI/UI_elements.lua[594<->652]

    self:_update_shield_amount()

    if mod:get("show_gauge") then
        widget.content.visible = true
    else
        self:_update_visibility(dt)
    end
end

HudElementBlitzBar._update_shield_amount = function(self)
    local shield_amount = resource_info.max_stacks or 0
    if shield_amount ~= self._shield_amount then
        local amount_difference = (self._shield_amount or 0) - shield_amount
        self._shield_amount = shield_amount

        self:_resize_shield()

        local add_shields = amount_difference < 0

        for i = 1, math.abs(amount_difference) do
            if add_shields then
                self:_add_shield()
            else
                self:_remove_shield()
            end
        end
    end
end

HudElementBlitzBar._update_visibility = function(self, dt)
    local draw = resource_info.stacks > 0 or resource_info.replenish

    local alpha_speed = 1 --3
    local alpha_multiplier = self._alpha_multiplier or 0

    if draw then
        alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
    else
        alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
    end

    self._alpha_multiplier = alpha_multiplier
end

HudElementBlitzBar._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
    if not self._enabled or mod._is_in_hub() then return end

    if self._alpha_multiplier ~= 0 then
        local previous_alpha_multiplier = render_settings.alpha_multiplier
        render_settings.alpha_multiplier = self._alpha_multiplier

        HudElementBlitzBar.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

        local gauge_widget = self._widgets_by_name.gauge
        gauge_widget.content.value_text = self:_get_value_text()

        self:_draw_shields(dt, t, ui_renderer)

        render_settings.alpha_multiplier = previous_alpha_multiplier
    end
end

HudElementBlitzBar._draw_shields = function(self, dt, t, ui_renderer)
    local num_shields = self._shield_amount

    if not num_shields then return end
    if num_shields < 1 then return end

    local step_fraction = 1 / num_shields
    local spacing = HudElementBar.spacing
    local shield_offset
    if self._horizontal then
        shield_offset = (self._shield_width + spacing) * (num_shields - 1) * 0.5
    else
        shield_offset = 5 --TODO: find better solution for "y_offset()"
    end

    local progress = (resource_info.timed and resource_info.progress) or 0.99
    local stacks = resource_info.stacks - (resource_info.replenish and 0 or 1)
    local souls_progress = (progress + (stacks)) / resource_info.max_stacks

    local decay = resource_info.decay

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
            local scenegraph_size = self:scenegraph_size("shield")
            local height = scenegraph_size.y

            self._shield_widget.offset[1] = 0
            self._shield_widget.offset[2] = height - shield_offset
        end

        UIWidget.draw(self._shield_widget, ui_renderer) -- TODO: Add dirty checks for performance

        shield_offset = shield_offset - self._shield_width - spacing
    end
end

return HudElementBlitzBar
