VehicleSecurityRework = {
    description = "Enhances the Security of civilian vehicles. Template for the Custom Hacking System",
}

function VehicleSecurityRework:new()

	registerForEvent("onInit", function()

		local CustomHackingSystem = GetMod("CustomHackingSystem")

		if CustomHackingSystem == nil then
			print("[VehicleSecurityRework] Custom Hacking System Mod not found, make sure it is properly installed (quickhacks won't be available)")
		end

		local hacks = require("Modules/Hack.lua")

		hacks.Generate()

		local quickhacks = require("Modules/Quickhack.lua")

		quickhacks.Generate()

		if VehicleSecurityRework_LTBF_Compatibility.IsLTBFPresent() then
			-- Fix for LTBF's added methods which would trigger a double callback for quickhacks
			-- i'll just take then added LTBF method (in redscript, there's no way to replace an added redscript method in redscript),
			-- and replace it by nothing inside (to avoid the ExecuteAction/ProcessRPGAction call)
			Override('VehicleObject', 'OnQuickSlotCommandUsed', function(_, evt)
			end)

		end
	end)

end

return VehicleSecurityRework:new()
