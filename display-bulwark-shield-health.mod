return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`display-bulwark-shield-health` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("display-bulwark-shield-health", {
			mod_script       = "scripts/mods/display-bulwark-shield-health/display-bulwark-shield-health",
			mod_data         = "scripts/mods/display-bulwark-shield-health/display-bulwark-shield-health_data",
			mod_localization = "scripts/mods/display-bulwark-shield-health/display-bulwark-shield-health_localization",
		})
	end,
	packages = {
		"resource_packages/display-bulwark-shield-health/display-bulwark-shield-health",
	},
}
