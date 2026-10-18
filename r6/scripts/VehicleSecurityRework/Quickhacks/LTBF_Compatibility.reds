
@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*

@if(ModuleExists("CustomHackingSystem.Tools"))
import CustomHackingSystem.Tools.*

public class VehicleSecurityRework_LTBF_Compatibility
{
    // Global method used to know if Let There Be Flight mod is present during compiling
    // This is used in the init.lua method to bypass a call to OnQuickSlotCommandUsed (which would trigger a double quickhack call)
    @if(ModuleExists("LetThereBeFlight"))
    public static func IsLTBFPresent() -> Bool
    {
        return true;
    }

    @if(!ModuleExists("LetThereBeFlight"))
    public static func IsLTBFPresent() -> Bool
    {
        return false;
    }
}

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
public final func ActionVehicleToggleFlightON() -> ref<LTBF_ToggleFlightON> 
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
    this.GetOwnerEntity().ForceEnablePhysics();
    this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().ToggleFlightComponent(true);
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
public final func ActionVehicleToggleGravityON() -> ref<LTBF_ToggleGravityON> 
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
public final func ActionVehicleToggleFlightOFF() -> ref<LTBF_ToggleFlightOFF> 
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
    this.GetOwnerEntity().ForceEnablePhysics();
    this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().ToggleFlightComponent(false);
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
public final func ActionVehicleToggleGravityOFF() -> ref<LTBF_ToggleGravityOFF> 
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
    this.GetOwnerEntity().ForceEnablePhysics();
    this.GetOwnerEntity().EndActions();
    this.GetOwnerEntity().EnableGravity(false);
    return EntityNotificationType.DoNotNotifyEntity;
}

public class LTBF_FlightMalfunction extends ActionBool
{
    public final func SetProperties() -> Void
    {
        this.actionName = n"LTBF_FlightMalfunction";
        this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    }
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
public final func ActionVehicleFlightMalfunction() -> ref<LTBF_FlightMalfunction>
{
    let action: ref<LTBF_FlightMalfunction> = new LTBF_FlightMalfunction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.LTBF_FlightMalfunction");
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);
    action.CreateInteraction();
    return action;
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
protected cb func OnActionVehicleFlightMalfunction(evt:ref<LTBF_FlightMalfunction>) -> EntityNotificationType 
{
    if IsDefined(this.GetOwnerEntity()) && this.GetOwnerEntity().CanEnterFlight()
    {
        this.GetOwnerEntity().ForceEnablePhysics();
        this.GetOwnerEntity().EndActions();
        this.GetOwnerEntity().ToggleFlightComponent(true);
        this.GetOwnerEntity().GetFlightComponent().lift = 5.0;
    }

    return EntityNotificationType.DoNotNotifyEntity;
}


public class LTBF_Funhouse extends ActionBool
{
    public final func SetProperties() -> Void
    {
        this.actionName = n"LTBF_Funhouse";
        this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    }
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
public final func ActionVehicleFunhouse() -> ref<LTBF_Funhouse>
{
    let action: ref<LTBF_Funhouse> = new LTBF_Funhouse();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.LTBF_Funhouse");
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);
    action.CreateInteraction();    
    return action;
}

@if(ModuleExists("LetThereBeFlight"))
@addMethod(VehicleComponentPS)
protected cb func OnActionVehicleFunhouse(evt:ref<LTBF_Funhouse>) -> EntityNotificationType 
{
    if IsDefined(this.GetOwnerEntity()) && this.GetOwnerEntity().CanEnterFlight()
    {
        this.GetOwnerEntity().bouncy = true;
        this.GetOwnerEntity().ignoreImpulses = false;
        this.GetOwnerEntity().ForceEnablePhysics();
        this.GetOwnerEntity().EndActions();
        this.GetOwnerEntity().GetFlightComponent().FireVerticalImpulse(0);

        LogChannel(n"DEBUG", "called ?");
    }

    return EntityNotificationType.DoNotNotifyEntity;
}