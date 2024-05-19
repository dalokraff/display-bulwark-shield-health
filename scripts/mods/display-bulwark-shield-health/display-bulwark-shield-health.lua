local mod = get_mod("display-bulwark-shield-health")

local function get_shield_health(unit, difficulty_tweaks, dt)
    local shield_health

    local blackboard = BLACKBOARDS[unit]
    local current_stagger = blackboard.cached_stagger

    local stagger_regen_rate = difficulty_tweaks.stagger_regen_rate
    local shield_open_stagger_threshold = difficulty_tweaks.shield_open_stagger_threshold
    local t = Managers.time:time("game")
    local normalizing_value = {
        0,
        10,
    }
    local regen_rate = math.lerp(stagger_regen_rate[1], stagger_regen_rate[2], (blackboard.cached_stagger or 0.1) / shield_open_stagger_threshold)

    if mod:get('predict_shield_health') then

        local regen = math.clamp(t - (blackboard.shield_regen_time_stamp or t), 0, math.huge) * regen_rate
        shield_health = math.clamp((current_stagger or 0) - regen, 0, math.huge)

        rr = regen_rate
    else
        shield_health = current_stagger
    end

    return shield_health, regen_rate
end

mod.shields = {}
local font_size = 0.25
local font_material = "materials/fonts/arial"
local font = "arial"

mod.update = function(dt)
    if Managers.state.debug_text then
        mod.gui = Managers.state.debug_text._world_gui
        for unit, data in pairs(mod.shields) do
            if data.gui_id then
                if mod.gui then
                    Gui.destroy_text_3d(mod.gui, data.gui_id)
                end
            end
            if data.regen_gui_id then
                if mod.gui then
                    Gui.destroy_text_3d(mod.gui, data.regen_gui_id)
                end
            end
            if Unit.alive(unit) then
                if BLACKBOARDS[unit] then
                    local difficulty_manager = Managers.state.difficulty
                    local difficulty_rank = difficulty_manager:get_difficulty_rank()
                    local breed = Unit.get_data(unit, "breed")
                    local difficulty_tweaks = breed.stagger_difficulty_tweak_index[difficulty_rank]
                    local stagger_regen_rate = difficulty_tweaks.stagger_regen_rate
                    local shield_open_stagger_threshold = difficulty_tweaks.shield_open_stagger_threshold

                    local color_stagger = Color(0,0,255)
                    local color_regen = Color(255,0,0)
                    local text_pos = Unit.local_position(unit, 0) + Vector3(0,0,1)
                    local rot = Quaternion.multiply(Unit.local_rotation(unit, 0), Quaternion.from_elements(0, 0, math.pi*7/4, 1))
                    local m = Matrix4x4.from_quaternion_position(rot, text_pos)

                    local shield_health, regen_rate = get_shield_health(unit, difficulty_tweaks, dt)

                    if (shield_health or 0) > 0 then
                        if mod.gui then
                            local stagger_text = tostring(string.format("%.1f", shield_health or 0)).."/"..tostring(shield_open_stagger_threshold)
                            data.gui_id = Gui.text_3d(mod.gui, stagger_text, font_material, font_size, font, m, Vector3(0,0,0), 3, color_stagger)

                            if mod:get("display_regen_rate") then
                                local regen_rate_text = tostring(string.format("%.2f", regen_rate))
                                data.regen_gui_id = Gui.text_3d(mod.gui, regen_rate_text, font_material, font_size, font, m, Vector3(0,-0.5,0), 3, color_regen)
                            end
                        end
                    end
                else
                    mod.shields[unit] = nil
                end
            else
                mod.shields[unit] = nil
            end
        end
    end
end

mod:hook_safe(Breeds['chaos_bulwark'], 'before_stagger_enter_function', function(unit, blackboard, attacker_unit, is_push, stagger_value_to_add, predicted_damage)
    local breed = blackboard.breed

    local difficulty_manager = Managers.state.difficulty
    local difficulty_rank = difficulty_manager:get_difficulty_rank()
    local difficulty_tweaks = breed.stagger_difficulty_tweak_index[difficulty_rank]

    local color = Color(0,0,255)
    local font_size = 0.25
    local font_material = "materials/fonts/arial"
    local font = "arial"
    local text_pos = Unit.local_position(unit, 0) + Vector3(0,0,1)
    local rot = Unit.local_rotation(unit, 0)
    local m = Matrix4x4.from_quaternion_position(rot, text_pos)

    if not mod.shields[unit] then
        mod.shields[unit] = {
            gui_id = Gui.text_3d(mod.gui, tostring(string.format("%.1f", blackboard.stagger)).."/"..tostring(shield_open_stagger_threshold), font_material, font_size, font, m, Vector3(0,0,0), 3, color),
            stagger = blackboard.cached_stagger
        }
    else
        mod.shields[unit]['stagger'] = blackboard.stagger
    end
end)