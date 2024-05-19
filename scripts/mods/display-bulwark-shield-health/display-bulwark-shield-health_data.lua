local mod = get_mod("display-bulwark-shield-health")

local menu = {
	name = "Display Shielded Chaos Warrior Health",
	description = mod:localize("mod_description"),
	is_togglable = true,
}


menu.options = {}
menu.options.widgets = {
	{
        setting_id = "predict_shield_health",
        type = "checkbox",
		default_value = true,
	},
	{
        setting_id = "display_regen_rate",
        type = "checkbox",
		default_value = true,
		tooltip = "display_regen_rate_desc"
	},
}

return menu