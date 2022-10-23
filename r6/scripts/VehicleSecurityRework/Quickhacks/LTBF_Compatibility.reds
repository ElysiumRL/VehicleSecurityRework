module LetThereBeFlight.Compatibility

import HackingExtensions.*
import CustomHackingSystem.Tools.*

public class LTBF_ToggleFlightON extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"ToggleFlightON";
		this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
	}
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
private final const func ActionVehicleToggleFlightON() -> ref<LTBF_ToggleFlightON> 
{
	let action: ref<LTBF_ToggleFlightON> = new LTBF_ToggleFlightON();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetObjectActionID(t"DeviceAction.ToggleFlightON");
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();
	return action;
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
protected cb func OnActionVehicleToggleFlightON(evt:ref<LTBF_ToggleFlightON>) -> EntityNotificationType 
{
    this.GetOwnerEntity().UnsetPhysicsStates();
    this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().m_flightComponent.Activate(true);
	return EntityNotificationType.DoNotNotifyEntity;
}



public class LTBF_ToggleGravityON extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"ToggleGravityON";
		this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
	}
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
private final const func ActionVehicleToggleGravityON() -> ref<LTBF_ToggleGravityON> 
{
	let action: ref<LTBF_ToggleGravityON> = new LTBF_ToggleGravityON();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetObjectActionID(t"DeviceAction.ToggleGravityON");
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();
	return action;
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
protected cb func OnVehicleToggleGravityON(evt:ref<LTBF_ToggleGravityON>) -> EntityNotificationType 
{
    //this.GetOwnerEntity().UnsetPhysicsStates();
    //this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().EnableGravity(true);
	return EntityNotificationType.DoNotNotifyEntity;
}



public class LTBF_ToggleFlightOFF extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"ToggleFlightOFF";
		this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
	}
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
private final const func ActionVehicleToggleFlightOFF() -> ref<LTBF_ToggleFlightOFF> 
{
	let action: ref<LTBF_ToggleFlightOFF> = new LTBF_ToggleFlightOFF();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetObjectActionID(t"DeviceAction.ToggleFlightOFF");
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();
	return action;
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
protected cb func OnActionVehicleToggleFlightOFF(evt:ref<LTBF_ToggleFlightOFF>) -> EntityNotificationType 
{
    this.GetOwnerEntity().UnsetPhysicsStates();
    this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().m_flightComponent.Deactivate(true);
	return EntityNotificationType.DoNotNotifyEntity;
}



public class LTBF_ToggleGravityOFF extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"ToggleGravityOFF";
		this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
	}
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
private final const func ActionVehicleToggleGravityOFF() -> ref<LTBF_ToggleGravityOFF> 
{
	let action: ref<LTBF_ToggleGravityOFF> = new LTBF_ToggleGravityOFF();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetObjectActionID(t"DeviceAction.ToggleGravityOFF");
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();
	return action;
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
protected cb func OnActionVehicleToggleGravityOFF(evt:ref<LTBF_ToggleGravityOFF>) -> EntityNotificationType 
{
    this.GetOwnerEntity().UnsetPhysicsStates();
    this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().EnableGravity(false);
	return EntityNotificationType.DoNotNotifyEntity;
}




public class LTBF_Liftoff extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"Liftoff";
		this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
	}
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
private final const func ActionVehicleLiftoff() -> ref<LTBF_Liftoff> 
{
	let action: ref<LTBF_Liftoff> = new LTBF_Liftoff();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetObjectActionID(t"DeviceAction.Liftoff");
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();
	return action;
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
protected cb func OnActionVehicleLiftoff(evt:ref<LTBF_Liftoff>) -> EntityNotificationType 
{
    this.GetOwnerEntity().UnsetPhysicsStates();
    this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().EnableGravity(false);
    this.GetOwnerEntity().m_flightComponent.Activate(true);
    this.GetOwnerEntity().m_flightComponent.lift = 5.0;

	return EntityNotificationType.DoNotNotifyEntity;
}