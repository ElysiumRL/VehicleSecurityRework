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

		ObserveAfter('VehicleSecurityRework.Hack.UnlockVehicleProgramAction','ExecuteProgramFailure',function (self)
			local systemSettings = Game.GetScriptableSystemsContainer():Get("VehicleSecurityRework.Base.VehicleSecurityRework")
			if systemSettings.vehicleCombatCompatibility then
				---@type VehicleComponentPS
				local vehicle = self.hackInstanceSettings.hackedTarget
				if vehicle ~= nil then
					if not Game.GetPlayer():IsInCombat() then
						local affiliationName = TweakDBInterface.GetVehicleRecord(vehicle:GetOwnerEntity():GetRecordID()):Affiliation():EnumName()
						if vehicle:GetOwnerEntity().AffiliationOverrideString ~= "" then
							affiliationName = TweakDBInterface.GetAffiliationRecord(vehicle:GetOwnerEntity().AffiliationOverride):EnumName()
						end
						PreventionSystem.CreateVCDamageRequest(Game.GetPlayer(),5.00,NameToString(affiliationName))
						StatusEffectHelper.ApplyStatusEffect(Game.GetPlayer(), "VC.BeingCalledOn");
					end




					local vehiclesToSpawn = systemSettings.vehiclesToSpawnEasy
					---@type String
					local vehicleHackDifficulty = vehicle:GetVehicleCrackLockDifficulty()

					---WHY IS THERE NO SWITCH IN LUAAAAAA
					if vehicleHackDifficulty == "MEDIUM" then
						vehiclesToSpawn = systemSettings.vehiclesToSpawnMedium
					elseif vehicleHackDifficulty == "HARD" then
						vehiclesToSpawn = systemSettings.vehiclesToSpawnHard
					elseif vehicleHackDifficulty == "IMPOSSIBLE" then
						vehiclesToSpawn = systemSettings.vehiclesToSpawnVeryHard
					end

					---@type PreventionDelayedVehicleSpawnRequest
					local policeCarSpawn = PreventionDelayedVehicleSpawnRequest:new()
					policeCarSpawn.heatStage = EPreventionHeatStage.Heat_1
					---@type Float
					local preventionDelay = RandRangeF(systemSettings.preventionReactionTimeMin,systemSettings.preventionReactionTimeMax)
					for i = 1, vehiclesToSpawn, 1 do
						PreventionSystem.QueueRequest(policeCarSpawn,preventionDelay)
					end
				else
					print("[VehicleSecurityRework] Error : Vehicle not found, Prevention response could not be sent")
				end
			end
		end)

	end)

end

return VehicleSecurityRework:new()
