local mod = get_mod("combatbars")

return settings("UICombatbars", {
    center_offset = 210,
    spacing = 4,
    half_distance = 1,
    bar_size = {
        200,
        9
    },
    area_size = {
        220,
        40
    },
    styles = {
        orientation_option_horizontal = {
            value_horizontal_alignment      = "right",
            value_text_horizontal_alignment = "right",
            value_offset                    = {
                0,
                10,
                3
            },
            name_horizontal_alignment       = "left",
            name_text_horizontal_alignment  = "left",
            name_offset                     = {
                0,
                10,
                3
            },
            angle                           = 0
        },
        orientation_option_horizontal_flipped = {
            value_horizontal_alignment      = "right",
            value_text_horizontal_alignment = "right",
            value_offset                    = {
                0,
                -30,
                3
            },
            name_horizontal_alignment       = "left",
            name_text_horizontal_alignment  = "left",
            name_offset                     = {
                0,
                -30,
                3
            },
            angle                           = math.pi
        },
        orientation_option_vertical = {
            value_horizontal_alignment = "right",
            value_text_horizontal_alignment = "right",
            value_offset = {
                -118,
                -86,
                3
            },
            name_horizontal_alignment = "right",
            name_text_horizontal_alignment = "right",
            name_offset = {
                -118,
                -104,
                3
            },
            angle = (math.pi * 3) / 2
        },
        orientation_option_vertical_flipped = {
            value_horizontal_alignment = "left",
            value_text_horizontal_alignment = "left",
            value_offset = {
                118,
                -86,
                3
            },
            name_horizontal_alignment = "left",
            name_text_horizontal_alignment = "left",
            name_offset = {
                118,
                -104,
                3
            },
            angle = math.pi / 2
        }
    }
})
