Quickhack = {}

function Quickhack.Generate()
	-- Quickhack Template
	--local category = Quickhack.API.CreateQuickhackGameplayCategory("QuickhackTemplate","UIIcon.nut_ring",LocKey(8879),LocKey(8879))
	--local cost = Quickhack.API.CreateQuickhackMemoryStatModifier("QuickhackTemplate","BaseCost","Additive",15.00)
	--local interaction = Quickhack.API.CreateInteractionUI("QuickhackTemplate",LocKey(8879),LocKey(8879),"UIIcon.nut_ring")
	--local quickhack = Quickhack.API.CreateQuickhack("QuickhackTemplate",category,interaction,cost,10.00)
	
	local Quickhack = GetMod("CustomHackingSystem")

	local explodeIcon = Quickhack.API.CreateUIIcon("explosive","base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas")
	local forceBrakesIcon = Quickhack.API.CreateUIIcon("GrenadeExplode","base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas")
	local remoteSecurityBreachIcon = Quickhack.API.CreateUIIcon("BreachProtocol","base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas")
	local vehicleDistractionIcon = Quickhack.API.CreateUIIcon("CommunicationCallOut","base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas")

	-- Quickhack Cooldown Template

	local categoryCD = Quickhack.API.CreateQuickhackGameplayCategory("RemoteSecurityBreach",remoteSecurityBreachIcon,LocKey(3652002),LocKey(3652001))
	local costCD = Quickhack.API.CreateQuickhackMemoryStatModifier("RemoteSecurityBreach","BaseCost","Additive",3.00)
	local interactionCD = Quickhack.API.CreateInteractionUI("RemoteSecurityBreach",LocKey(3652001),LocKey(3652002),remoteSecurityBreachIcon)
	local quickhackCD = Quickhack.API.CreateRemoteBreachQuickhack("RemoteSecurityBreach",categoryCD,interactionCD,costCD,15.00)

	local explodeVehicleCategory = Quickhack.API.CreateQuickhackGameplayCategory("ExplodeVehicle",explodeIcon,LocKey(3652008),LocKey(3652007))
	local explodeVehicleCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ExplodeVehicle","BaseCost","Additive",12.00)
	local explodeVehicleInteraction = Quickhack.API.CreateInteractionUI("ExplodeVehicle",LocKey(3652007),LocKey(3652008),explodeIcon)
	local explodeVehicleQuickhack = Quickhack.API.CreateQuickhack("ExplodeVehicle",explodeVehicleCategory,explodeVehicleInteraction,explodeVehicleCost,0.00,5.00)

	local forceVehicleBrakesCategory = Quickhack.API.CreateQuickhackGameplayCategory("ForceBrakes",forceBrakesIcon,LocKey(3652012),LocKey(3652011))
	local forceVehicleBrakesCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ForceBrakes","BaseCost","Additive",4.00)
	local forceVehicleBrakesInteraction = Quickhack.API.CreateInteractionUI("ForceBrakes",LocKey(3652011),LocKey(3652012),forceBrakesIcon)
	local forceVehicleBrakesQuickhack = Quickhack.API.CreateQuickhack("ForceBrakes",forceVehicleBrakesCategory,forceVehicleBrakesInteraction,forceVehicleBrakesCost,0.00,0.75)

	local distractVehicleCategory = Quickhack.API.CreateQuickhackGameplayCategory("VehicleDistraction",vehicleDistractionIcon,LocKey(3652012),LocKey(3652011))
	local distractVehicleCost = Quickhack.API.CreateQuickhackMemoryStatModifier("VehicleDistraction","BaseCost","Additive",4.00)
	--local distractVehicleInteraction = Quickhack.API.CreateInteractionUI("VehicleDistraction",LocKey(3652011),LocKey(3652012),vehicleDistractionIcon)
	local distractVehicleQuickhack = Quickhack.API.CreateQuickhack("VehicleDistraction",distractVehicleCategory,"Interactions.MalfunctionHack",distractVehicleCost,0.00,0.5)
	
	local autoHackBrakesCategory = Quickhack.API.CreateQuickhackGameplayCategory("AutoHack",remoteSecurityBreachIcon,LocKey(3652017),LocKey(3652016))
	local autoHackBrakesCost = Quickhack.API.CreateQuickhackMemoryStatModifier("AutoHack","BaseCost","Additive",8.00)
	local autoHackBrakesInteraction = Quickhack.API.CreateInteractionUI("AutoHack",LocKey(3652016),LocKey(3652017),remoteSecurityBreachIcon)
	local autoHackBrakesQuickhack = Quickhack.API.CreateQuickhack("AutoHack",autoHackBrakesCategory,autoHackBrakesInteraction,autoHackBrakesCost,0.00,4.00)

end

return Quickhack