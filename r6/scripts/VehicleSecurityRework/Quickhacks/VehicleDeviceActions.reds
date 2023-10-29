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

public class VehicleRecklessDrivingDeviceAction extends ActionBool
{
    public final func SetProperties() -> Void
    {
        this.actionName = n"VehicleRecklessDriving";
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
private final const func ActionVehicleRecklessDriving() -> ref<VehicleRecklessDrivingDeviceAction> 
{
    let action: ref<VehicleRecklessDrivingDeviceAction> = new VehicleRecklessDrivingDeviceAction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.RecklessDriving");

    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    customHackSystem.RegisterDeviceAction(action);
    action.CreateInteraction();
    action.SetDurationValue(10.0);

    return action;
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

//So I can't fix it for some reason
@addMethod(VehicleObject)
private final func RecklessDrivingBehavior() -> Void 
{
    //this.ResetReactionSequenceOfAllPassengers();
    this.m_drivingTrafficPattern = n"panic";
    this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern);
    //this.ResetTimesSentReactionEvent();
}

//Same for this
@addMethod(VehicleObject)
private final func ResetDrivingBehavior() -> Void 
{
    if Equals(this.m_drivingTrafficPattern, n"stop") 
    {
        this.ResetReactionSequenceOfAllPassengers();
    }
    //else
    //{
    //    this.ResetReactionSequenceOfAllPassengers();
    //}
    this.m_drivingTrafficPattern = n"normal";
    //LogChannel(n"DEBUG",ToString(this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern)));
//	if !(this.m_crowdMemberComponent.ChangeMoveType(this.m_drivingTrafficPattern))
//	{
//		let trafficCommand:ref<AIVehicleJoinTrafficCommand> = new AIVehicleJoinTrafficCommand();
//		trafficCommand.needDriver = false;
//		trafficCommand.useKinematic = true;
//
//		let commandExecuter:ref<AICommandEvent> = new AICommandEvent();
//		commandExecuter.command = trafficCommand;
//		commandExecuter.timeToLive = 5.0;
//    	this.QueueEvent(commandExecuter);
//		this.ResetTimesSentReactionEvent();
//		this.ResendHandleReactionEvent();
//
//	}
//	else
//	{
//		//this.ResetTimesSentReactionEvent();
//		//this.ResendHandleReactionEvent();
//
//	}

    //GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, this.m_reactionTriggerEvent, 0.00);
}

//There are very weird interactions with panic driving and especially this behaviour not acting properly
@addMethod(VehicleObject)
protected cb func OnRecklessDriving(evt:ref<VehicleRecklessDrivingDeviceAction>) -> EntityNotificationType
{
    if !this.GetVehiclePS().quickhackRecklessDrivingExecuted
    {
        let panicDrive: ref<AIVehiclePanicCommand> = new AIVehiclePanicCommand();
        panicDrive.needDriver = false;
        panicDrive.useKinematic = true;
        
        let commandEvent: ref<AICommandEvent> = new AICommandEvent();
        commandEvent.command = panicDrive;
        commandEvent.timeToLive = evt.GetDurationValue();
        this.QueueEvent(commandEvent);

        //this.ShowQuickHackDuration(evt);
        this.RecklessDrivingBehavior();
        this.GetVehiclePS().quickhackRecklessDrivingExecuted = true;
        this.GetVehiclePS().CanTriggerRecklessDriving = false;

    }
    else
    {
        this.GetVehiclePS().quickhackRecklessDrivingExecuted = false;
        //Potential fix for panic driving not ending
        this.ResetDrivingBehavior();
        
        //let trafficCommand:ref<AIVehicleJoinTrafficCommand> = new AIVehicleJoinTrafficCommand();
        //trafficCommand.needDriver = false;
        //trafficCommand.useKinematic = true;

        //let commandExecuter:ref<AICommandEvent> = new AICommandEvent();
        //commandExecuter.command = trafficCommand;
        //commandExecuter.timeToLive = 0.0;
        //this.QueueEvent(commandExecuter);
        
        //this.m_drivingTrafficPattern = n"normal";
        //
        //this.m_fearInside = false;
        //let vehicleReactionEvent = new HandleReactionEvent();
        //vehicleReactionEvent.fearPhase = 0;
        //let fakeStim: ref<StimuliEvent> = new StimuliEvent();
        //vehicleReactionEvent.stimEvent = fakeStim;
        //vehicleReactionEvent.stimEvent.sourceObject = this.GetPlayerMainObject();

        //this.m_reactionTriggerEvent = vehicleReactionEvent;
        //this.m_timesSentReactionEvent = 0;
        //this.ResetDrivingBehavior();

    }
    return EntityNotificationType.DoNotNotifyEntity;
}

@addMethod(VehicleComponentPS)
protected cb func OnRecklessDriving(evt:ref<VehicleRecklessDrivingDeviceAction>) -> EntityNotificationType 
{
    return EntityNotificationType.SendThisEventToEntity;
}


@addMethod(VehicleComponentPS)
protected cb func OnAutoHackVehicle(evt:ref<AutoHackVehicleDeviceAction>) -> EntityNotificationType 
{
    this.m_isVehicleHacked = true;	
    this.SetIsStolen(true);	
    this.UnlockAllVehDoors();
}