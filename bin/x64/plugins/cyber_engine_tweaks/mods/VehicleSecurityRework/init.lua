VehicleSecurityRework = {
    description = "Enhances the Security of civilian vehicles. Template for the Custom Hacking System",
	vehicleCombatModExists = false
}

function VehicleSecurityRework:new()

	registerForEvent("onInit", function()

		local CustomHackingSystem = GetMod("CustomHackingSystem")

		if CustomHackingSystem == nil then
			print("[VehicleSecurityRework] Custom Hacking System Mod not found")
		end

		local hacks = require("Modules/Hack.lua")

		hacks.Generate()

		local quickhacks = require("Modules/Quickhack.lua")

		quickhacks.Generate()

		--#region Vehicle Combat Compatibility

		Observe('VehicleSecurityRework.Hack.UnlockVehicleProgramAction','ExecuteProgramFailure',function (self)
			if Game.GetScriptableSystemsContainer():Get("VehicleSecurityRework.Base.VehicleSecurityRework").vehicleCombatCompatibility then
				---@type VehicleComponentPS
				local vehicle = self.hackInstanceSettings.hackedTarget
				if vehicle ~= nil then
					print(TweakDBInterface.GetVehicleRecord(vehicle:GetOwnerEntity():GetRecordID()):Affiliation():EnumName())
					PreventionSystem.CreateVCDamageRequest(Game.GetPlayer(),1.75,TweakDBInterface.GetVehicleRecord(vehicle:GetOwnerEntity():GetRecordID()):Affiliation():EnumName())
				else
					print("[VehicleSecurityRework] Error : Vehicle not found, Prevention response could not be sent")
				end
			end
		end)

	end)

end

return VehicleSecurityRework:new()
