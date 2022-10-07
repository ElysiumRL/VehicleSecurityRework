module VehicleSecurityRework.Base
import VehicleSecurityRework.Hack.*

//Get all quickhacks for the vehicle
@replaceMethod(VehicleComponentPS)
protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void 
{
	let action: ref<ScriptableDeviceAction>;
	
	//Remote Breach
	action = this.ActionUnlockSecurity(GetVehicleHackDBDifficulty(this));
	if IsVehicleSecurityHardened(this)
	{
		action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
	}
	else 
	{
		if IsVehicleSecurityBreached(this)
		{
			action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
		}
	}
	ArrayPush(actions,action);
	
	//Auto Hack
	action = this.ActionVehicleAutoHack();
	if IsVehicleSecurityHardened(this)
	{
		action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
	}
	else 
	{
		if IsVehicleSecurityBreached(this)
		{
			action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
		}
	}
	ArrayPush(actions,action);

	//Explode
	action = this.ActionOverloadVehicle();
	if !IsVehicleSecurityBreached(this)
	{
		action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
	}
	ArrayPush(actions,action);

	//Distract
	action = this.ActionVehicleDistraction();
	if !IsVehicleSecurityBreached(this)
	{
		action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
	}
	if this.m_distractExecuted
	{
		action.SetInactiveWithReason(false, "LocKey#7004");	
	}	
	ArrayPush(actions,action);

	//Force Brakes
	action = this.ActionVehicleForceBrakes();
	if !IsVehicleSecurityBreached(this)
	{
		action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
	}
	if this.quickhackForceBrakesExecuted
	{
		action.SetInactiveWithReason(false, "LocKey#7004");	
	}
	ArrayPush(actions,action);
	
	//Force Throttle
	action = this.ActionVehicleRecklessDriving();
	if !IsVehicleSecurityBreached(this)
	{
		action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
	}
	if this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted
	{
		action.SetInactiveWithReason(false, "LocKey#7004");	
	}
	ArrayPush(actions,action);


	if this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted
	{
		ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7004");	
	}

	//Block hacks if it is player owned
	if this.GetIsPlayerVehicle()
	{
		ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, LocKeyToString(n"VehicleSecurityRework-Quickhack-PlayerOwnedPanelInfo"));	
	}

	this.FinalizeGetQuickHackActions(actions, context);
}