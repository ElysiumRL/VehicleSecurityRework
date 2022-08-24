VehicleSecurityRework = {
    description = "Enhances the Security of civilian vehicles. Template for the Custom Hacking System"
}

function VehicleSecurityRework:new()

	registerForEvent("onInit", function()

		local CustomHackingSystem = GetMod("CustomHackingSystem")

		if CustomHackingSystem == nil then
			print("[VehicleSecurityRework] Custom Hacking System Mod not found")
		end

		local hacks = require("Modules/Hack.lua")

		hacks.Generate()

		local quickhacks = require("Modules/Quickhack.lua");

		quickhacks.Generate()

	end)

end

return VehicleSecurityRework:new()
