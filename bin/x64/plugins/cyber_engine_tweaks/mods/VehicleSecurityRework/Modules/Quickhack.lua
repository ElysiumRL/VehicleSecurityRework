Quickhack = {}

function Quickhack.Generate()

	--Quickhack Module
	local Quickhack = GetMod("CustomHackingSystem")

	--#region VehicleSecurityRework default Quickhacks

	local explodeIcon = Quickhack.API.CreateUIIcon("explosive","base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas")
	local forceBrakesIcon = Quickhack.API.CreateUIIcon("GrenadeExplode","base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas")
	local recklessDrivingIcon = Quickhack.API.CreateUIIcon("OverLoadDevice","base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas")
	local remoteSecurityBreachIcon = Quickhack.API.CreateUIIcon("BreachProtocol","base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas")

	local quickhackCategory = Quickhack.API.CreateQuickhackGameplayCategory("VehicleSecurity",remoteSecurityBreachIcon,LocKey(0000),LocKey(0000))

	local remoteBreachInteraction = Quickhack.API.CreateInteractionUI("RemoteSecurityBreach",LocKey(3652001),LocKey(3652002),remoteSecurityBreachIcon)
	local remoteBreachCost = Quickhack.API.CreateQuickhackMemoryStatModifier("RemoteSecurityBreach","BaseCost","Additive",3.00)
	local remoteBreachQuickhack = Quickhack.API.CreateRemoteBreachQuickhack("RemoteSecurityBreach",quickhackCategory,remoteBreachInteraction,remoteBreachCost,8.00)

	local explodeVehicleInteraction = Quickhack.API.CreateInteractionUI("ExplodeVehicle",LocKey(3652007),LocKey(3652008),explodeIcon)
	local explodeVehicleCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ExplodeVehicle","BaseCost","Additive",12.00)
	local explodeVehicleQuickhack = Quickhack.API.CreateQuickhack("ExplodeVehicle",quickhackCategory,explodeVehicleInteraction,explodeVehicleCost,0.00,5.00)

	local forceVehicleBrakesInteraction = Quickhack.API.CreateInteractionUI("ForceBrakes",LocKey(3652011),LocKey(3652012),forceBrakesIcon)
	local forceVehicleBrakesCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ForceBrakes","BaseCost","Additive",4.00)
	local forceVehicleBrakesQuickhack = Quickhack.API.CreateQuickhack("ForceBrakes",quickhackCategory,forceVehicleBrakesInteraction,forceVehicleBrakesCost,0.00,0.75)

	local recklessDrivingInteraction = Quickhack.API.CreateInteractionUI("RecklessDriving",LocKey(3652018),LocKey(3652019),recklessDrivingIcon)
	local recklessDrivingCost = Quickhack.API.CreateQuickhackMemoryStatModifier("RecklessDriving","BaseCost","Additive",4.00)
	local recklessDrivingQuickhack = Quickhack.API.CreateQuickhack("RecklessDriving",quickhackCategory,recklessDrivingInteraction,recklessDrivingCost,0.00,0.75)

	local distractVehicleCost = Quickhack.API.CreateQuickhackMemoryStatModifier("VehicleDistraction","BaseCost","Additive",4.00)
	local distractVehicleQuickhack = Quickhack.API.CreateQuickhack("VehicleDistraction",quickhackCategory,"Interactions.MalfunctionHack",distractVehicleCost,0.00,0.5)

	local autoHackInteraction = Quickhack.API.CreateInteractionUI("AutoHack",LocKey(3652016),LocKey(3652017),remoteSecurityBreachIcon)
	local autoHackCost = Quickhack.API.CreateQuickhackMemoryStatModifier("AutoHack","BaseCost","Additive",24.00)
	local autoHackQuickhack = Quickhack.API.CreateQuickhack("AutoHack",quickhackCategory,autoHackInteraction,autoHackCost,0.00,4.00)

	--#endregion

	--#region Let There Be Flight Compatibility

	local liftoffIcon = Quickhack.API.CreateUIIcon("skill_annihilation","base\\gameplay\\gui\\common\\icons\\attributes_icons.inkatlas")
	local toggleOFFIcon = Quickhack.API.CreateUIIcon("Off","base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas")
	local toggleONIcon = Quickhack.API.CreateUIIcon("icon_compare","base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas")
	local toggleGravityONIcon = Quickhack.API.CreateUIIcon("icon_compare_lower","base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas")

	local toggleFlightONInteraction = Quickhack.API.CreateInteractionUI("ToggleFlightON",LocKey(3652026),LocKey(3652027),toggleONIcon)
	local toggleFlightONCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ToggleFlightON","BaseCost","Additive",1.00)
	local toggleFlightONQuickhack = Quickhack.API.CreateQuickhack("ToggleFlightON",quickhackCategory,toggleFlightONInteraction,toggleFlightONCost,5.00,0.25)

	local toggleFlightOFFInteraction = Quickhack.API.CreateInteractionUI("ToggleFlightOFF",LocKey(3652028),LocKey(3652029),toggleOFFIcon)
	local toggleFlightOFFCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ToggleFlightOFF","BaseCost","Additive",1.00)
	local toggleFlightOFFQuickhack = Quickhack.API.CreateQuickhack("ToggleFlightOFF",quickhackCategory,toggleFlightOFFInteraction,toggleFlightOFFCost,5.00,0.25)

	local toggleGravityONInteraction = Quickhack.API.CreateInteractionUI("ToggleGravityON",LocKey(3652020),LocKey(3652021),toggleGravityONIcon)
	local toggleGravityONCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ToggleGravityON","BaseCost","Additive",1.00)
	local toggleGravityONQuickhack = Quickhack.API.CreateQuickhack("ToggleGravityON",quickhackCategory,toggleGravityONInteraction,toggleGravityONCost,5.00,0.25)

	local toggleGravityOFFInteraction = Quickhack.API.CreateInteractionUI("ToggleGravityOFF",LocKey(3652022),LocKey(3652023),toggleOFFIcon)
	local toggleGravityOFFCost = Quickhack.API.CreateQuickhackMemoryStatModifier("ToggleGravityOFF","BaseCost","Additive",1.00)
	local toggleGravityOFFQuickhack = Quickhack.API.CreateQuickhack("ToggleGravityOFF",quickhackCategory,toggleGravityOFFInteraction,toggleGravityOFFCost,5.00,0.25)

	local liftoffInteraction = Quickhack.API.CreateInteractionUI("Liftoff",LocKey(3652024),LocKey(3652025),liftoffIcon)
	local liftoffCost = Quickhack.API.CreateQuickhackMemoryStatModifier("Liftoff","BaseCost","Additive",12.00)
	local liftoffQuickhack = Quickhack.API.CreateQuickhack("Liftoff",quickhackCategory,liftoffInteraction,liftoffCost,0.00,7.00)

	--#endregion

end

return Quickhack