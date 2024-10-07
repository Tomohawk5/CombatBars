return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`combatbars` encountered an error loading the Darktide Mod Framework.")

		new_mod("blitzbar", {
			mod_script       = "combatbars/scripts/mods/combatbars/combatbars",
			mod_data         = "combatbars/scripts/mods/combatbars/combatbars_data",
			mod_localization = "combatbars/scripts/mods/combatbars/combatbars_localization",
		})
	end,
	packages = {},
}
