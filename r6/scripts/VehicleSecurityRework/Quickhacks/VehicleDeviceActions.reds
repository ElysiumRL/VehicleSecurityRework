@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*
import VehicleSecurityRework.Vehicles.*

public class UnlockSecurityDeviceAction extends CustomAccessBreach
{
}

public class VehicleDistractionDeviceAction extends ActionBool
{
    public final func SetProperties() -> Void
    {
        this.actionName = n"VehicleDistraction";
        this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    }
}

public class AutoHackVehicleDeviceAction extends ActionBool
{
    public final func SetProperties() -> Void
    {
        this.actionName = n"AutoHack";
        this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    }
}

public class PopTireVehicleDeviceAction extends ActionBool
{
    public final func SetProperties() -> Void
    {
        this.actionName = n"PopTire";
        this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    }
}

public class RepairVehicleTiresDeviceAction extends ActionBool
{
    public final func SetProperties() -> Void
    {
        this.actionName = n"RepairTires";
        this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    }
}

@addMethod(VehicleComponentPS)
private final const func ActionUnlockSecurity(minigameDef:TweakDBID) -> ref<UnlockSecurityDeviceAction> 
{

    let action: ref<UnlockSecurityDeviceAction> = new UnlockSecurityDeviceAction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.GetDeviceName() + EntityID.ToDebugString(this.GetOwnerEntity().GetEntityID()), 1, -1, true, false,minigameDef,this);
    action.AddDeviceName(EntityID.ToDebugString(this.GetOwnerEntity().GetEntityID()));
    action.SetObjectActionID(t"DeviceAction.RemoteSecurityBreach");
    
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);


    return action;
}

@addMethod(VehicleComponentPS)
private final const func ActionVehicleDistraction() -> ref<VehicleDistractionDeviceAction> 
{
    let action: ref<VehicleDistractionDeviceAction> = new VehicleDistractionDeviceAction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetCanTriggerStim(true);

    action.SetObjectActionID(t"DeviceAction.VehicleDistraction");
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);
    action.CreateInteraction();
    action.SetDurationValue(25.0);

    return action;
}

@addMethod(VehicleComponentPS)
private final const func ActionVehicleAutoHack() -> ref<AutoHackVehicleDeviceAction> 
{
    let action: ref<AutoHackVehicleDeviceAction> = new AutoHackVehicleDeviceAction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.AutoHack");
    action.SetDurationValue(0.0);

    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);
    action.CreateInteraction();

    return action;
}

@addMethod(VehicleComponentPS)
private final const func ActionVehiclePopTire() -> ref<PopTireVehicleDeviceAction> 
{
    let action: ref<PopTireVehicleDeviceAction> = new PopTireVehicleDeviceAction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.VehiclePopTire");

    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);
    action.CreateInteraction();

    return action;
}

@addMethod(VehicleComponentPS)
private final const func ActionVehicleRepairTires() -> ref<RepairVehicleTiresDeviceAction> 
{
    let action: ref<RepairVehicleTiresDeviceAction> = new RepairVehicleTiresDeviceAction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.RepairTires");

    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);
    action.CreateInteraction();

    return action;
}

@addMethod(VehicleComponentPS)
protected cb func OnVehiclePopTire(evt:ref<PopTireVehicleDeviceAction>) -> EntityNotificationType 
{
    let wheeledObject : ref<WheeledObject> = (this.GetOwnerEntity() as WheeledObject);
    if (!IsDefined(wheeledObject))
    {
        return EntityNotificationType.DoNotNotifyEntity;
    }
    let wheelCount : Uint32 = wheeledObject.GetWheelCount();
    
    let i:Uint32 = 0u;
    while (i < wheelCount)
    {
        if(!wheeledObject.IsTirePunctured(i))
        {
            if(VehicleComponent.HasActiveDriver(this.GetGameInstance(), this.GetOwnerEntity(), this.GetOwnerEntity().GetEntityID()))
            {         
        		let trafficCommand:ref<AIVehiclePanicCommand> = new AIVehiclePanicCommand();
        		trafficCommand.needDriver = true;
        		trafficCommand.useKinematic = true;
                trafficCommand.ignoreTickets = false;
                trafficCommand.allowSimplifiedMovement = false;
                trafficCommand.tryDriveAwayFromPlayer = true;

        		let commandExecuter:ref<AICommandEvent> = new AICommandEvent();
        		commandExecuter.command = trafficCommand;
        		commandExecuter.timeToLive = 8.0;
            	this.GetOwnerEntity().QueueEvent(commandExecuter);
            }
            else
            {
                this.GetOwnerEntity().GetAIComponent().Toggle(false);
                this.GetOwnerEntity().GetAIComponent().EnableCollider();

                let worldImpulseLocation: Vector4 = this.GetOwnerEntity().GetWorldPosition();
                let worldImpulseSide : Float = 1.0;
                if(Cast<Int32>(i) % 2 != 0)
                {
                    worldImpulseSide = -1.0;
                }
                let physicalImpulseEvent: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
                physicalImpulseEvent.radius = 5.00;
                physicalImpulseEvent.worldPosition.X = worldImpulseLocation.X + 10.0 * worldImpulseSide;
                physicalImpulseEvent.worldPosition.Y = worldImpulseLocation.Y;
                physicalImpulseEvent.worldPosition.Z = worldImpulseLocation.Z + 0.50;
                
                let worldImpulse: Vector4 = this.GetOwnerEntity().GetWorldPosition();
                worldImpulse = WorldTransform.GetRight(this.GetOwnerEntity().GetWorldTransform());
                worldImpulse *= this.GetOwnerEntity().GetTotalMass() * 0.75;
                physicalImpulseEvent.worldImpulse = Vector4.Vector4To3(worldImpulse);

                this.GetOwnerEntity().QueueEvent(physicalImpulseEvent);
            }
            
            let event : ref<VehicleToggleBrokenTireEvent> = new VehicleToggleBrokenTireEvent();
            event.tireIndex = i;
            event.toggle = true;
            this.QueuePSEvent(this, event);
            wheeledObject.ToggleBrokenTire(event.tireIndex, event.toggle);
            this.GetOwnerEntity().ActivateTemporaryLossOfControl();

            break;
        }
        i += 1u;
    }
}

@addMethod(VehicleComponentPS)
protected cb func OnVehicleRepairTires(evt:ref<RepairVehicleTiresDeviceAction>) -> EntityNotificationType 
{
    let wheeledObject : ref<WheeledObject> = (this.GetOwnerEntity() as WheeledObject);
    if(!IsDefined(wheeledObject))
    {
        return EntityNotificationType.DoNotNotifyEntity;
    }
    let wheelCount : Uint32 = wheeledObject.GetWheelCount();
    
    let i:Uint32 = 0u;
    while(i < wheelCount)
    {
        let event : ref<VehicleToggleBrokenTireEvent> = new VehicleToggleBrokenTireEvent();
        event.tireIndex = i;
        event.toggle = false;
        this.QueuePSEvent(this, event);
        wheeledObject.ToggleBrokenTire(event.tireIndex, event.toggle);
        i += 1u;
    }
}

@addMethod(VehicleComponentPS)
protected cb func OnActionVehicleDistraction(evt:ref<VehicleDistractionDeviceAction>) -> EntityNotificationType 
{
    if (!this.m_distractExecuted)
    {
        this.m_distractExecuted = true;
        this.m_isGlitching = true;
        this.m_distractionTimeCompleted = false;
        evt.SetCanTriggerStim(true);
        //evt.SetObjectActionID(t"DeviceAction.EndMalfunction");
        //this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
        this.GetOwnerEntity().Distract();
        this.GetOwnerEntity().GetVehicleComponent().PlayHonkForDuration(evt.GetDurationValue());
        let visualDistraction: ref<VehicleDistractionVisual> = new VehicleDistractionVisual();
        this.GetOwnerEntity().QueueEvent(visualDistraction);

        //Here
        //this.GetOwnerEntity().ShowQuickHackDuration(evt);
    }
    else
    {
        this.m_distractionTimeCompleted = true;
        this.m_distractExecuted = false;
        this.m_isGlitching = false;
        evt.SetCanTriggerStim(false);
    }
    return EntityNotificationType.DoNotNotifyEntity;
}

@addMethod(VehicleObject)
protected final func Distract() -> Void 
{
    let broadcaster: ref<StimBroadcasterComponent>;
    broadcaster = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster)
    {
        let investigate: stimInvestigateData;
        investigate.distrationPoint = this.GetWorldPosition();
        investigate.controllerEntity = this;
        investigate.illegalAction = true;
        investigate.investigateController = true;
        investigate.mainDeviceEntity = this;
        investigate.revealsInstigatorPosition = false;
        //investigate.attackInstigator = this.GetPlayerMainObject();
        //investigate.attackInstigatorPosition = this.GetPlayerMainObject().GetWorldPosition();
        broadcaster.TriggerSingleBroadcast(this, gamedataStimType.Distract,20.00,investigate);
        broadcaster.TriggerSingleBroadcast(this, gamedataStimType.Alarm,20.00,investigate);
        broadcaster.TriggerSingleBroadcast(this, gamedataStimType.SoundDistraction,20.00,investigate);
        broadcaster.TriggerSingleBroadcast(this, gamedataStimType.VisualDistract,20.00,investigate);
        
        let distractionLogic:ref<VehicleDistractionLogic> = new VehicleDistractionLogic();
        GameInstance.GetDelaySystem(this.GetGame()).DelayEventNextFrame(this, distractionLogic);
    }
}

public class VehicleDistractionLogic extends Event
{
}


public class VehicleDistractionVisual extends Event
{
}

@addMethod(VehicleObject)
protected cb func OnDistractionLogic(evt:ref<VehicleDistractionLogic>) -> Bool 
{
    if this.GetVehiclePS().m_isGlitching
    {
        this.Distract();
    }
}

@addMethod(VehicleObject)
protected cb func OnDistractionVisual(evt:ref<VehicleDistractionVisual>) -> Bool 
{
    if this.GetVehiclePS().m_isGlitching
    {
        if RandRange(0,100) >= 25
        {
            this.GetVehicleComponent().GetVehicleController().ToggleLights(false);
        }
        else
        {
            this.GetVehicleComponent().GetVehicleController().ToggleLights(true);
        }
        let visualDistraction:ref<VehicleDistractionVisual> = new VehicleDistractionVisual();
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, visualDistraction, RandRangeF(0.15,0.75), true);
    }
}

@addMethod(VehicleComponentPS)
protected cb func OnAutoHackVehicle(evt:ref<AutoHackVehicleDeviceAction>) -> EntityNotificationType 
{
    this.m_isVehicleHacked = true;	
    this.SetIsStolen(true);	
    this.UnlockAllVehDoors();
}