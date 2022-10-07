@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*

public class UnlockSecurityDeviceAction extends CustomAccessBreach
{
}


public class OverloadVehicleDeviceAction extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"OverloadVehicle";
		this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
	}
}

public class VehicleDistractionDeviceAction extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"VehicleDistraction";
		this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
	}
}

public class VehicleForceBrakesDeviceAction extends ActionBool
{
	public final func SetProperties() -> Void
	{
		this.actionName = n"VehicleForceBrakesDevice";
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
	action.CreateInteraction();

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
private final const func ActionVehicleForceBrakes() -> ref<VehicleForceBrakesDeviceAction> 
{
	let action: ref<VehicleForceBrakesDeviceAction> = new VehicleForceBrakesDeviceAction();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetObjectActionID(t"DeviceAction.ForceBrakes");

	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();
	action.SetDurationValue(10.0);

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
private final const func ActionOverloadVehicle() -> ref<OverloadVehicleDeviceAction> 
{
	let action: ref<OverloadVehicleDeviceAction> = new OverloadVehicleDeviceAction();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetObjectActionID(t"DeviceAction.ExplodeVehicle");
	
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();
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
		this.GetOwnerEntity().ToggleHornForDuration(evt.GetDurationValue());
		let visualDistraction: ref<VehicleDistractionVisual> = new VehicleDistractionVisual();
		this.GetOwnerEntity().QueueEvent(visualDistraction);
		this.GetOwnerEntity().ShowQuickHackDuration(evt);
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
		investigate.attackInstigator = this.GetPlayerMainObject();
		investigate.attackInstigatorPosition = this.GetPlayerMainObject().GetWorldPosition();
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
protected cb func OnActionOverloadVehicle(evt:ref<OverloadVehicleDeviceAction>) -> EntityNotificationType 
{
	//Version to get cops on you
	//this.GetOwnerEntity().GetVehicleComponent().ExplodeVehicle(this.GetOwnerEntity().GetPlayerMainObject());
	this.GetOwnerEntity().GetVehicleComponent().ExplodeVehicle(this.GetOwnerEntity());
	this.SetIsDestroyed(true);
	return EntityNotificationType.DoNotNotifyEntity;
}

@addField(VehicleComponentPS)
public let quickhackForceBrakesExecuted:Bool = false;

//Super important : If you use the ShowQuickHackDuration() it will re queue the event you call on duration end


@addMethod(VehicleComponentPS)
protected cb func OnForceBrakesVehicle(evt:ref<VehicleForceBrakesDeviceAction>) -> EntityNotificationType 
{
	if !this.quickhackForceBrakesExecuted
	{
		LogChannel(n"DEBUG","Hello World");
		this.GetOwnerEntity().ForceBrakesFor(evt.GetDurationValue());
		this.quickhackForceBrakesExecuted = true;
		let endEvt: ref<EndForceBrakes> = new EndForceBrakes();
		this.QueuePSEventWithDelay(this, endEvt, evt.GetDurationValue());
		this.GetOwnerEntity().ShowQuickHackDuration(evt);
	}
	else
	{
		this.quickhackForceBrakesExecuted = false;
	}
	return EntityNotificationType.DoNotNotifyEntity;
}

public class EndForceBrakes extends Event
{

}

@addMethod(VehicleComponentPS)
protected cb func OnEndForceBrakes(evt:ref<EndForceBrakes>) -> Void
{
	this.quickhackForceBrakesExecuted = false;
}

@addField(VehicleComponentPS)
public let quickhackRecklessDrivingExecuted:Bool = false;

@addMethod(VehicleObject)
protected cb func OnRecklessDriving(evt:ref<VehicleRecklessDrivingDeviceAction>) -> EntityNotificationType
{
	if !this.GetVehiclePS().quickhackRecklessDrivingExecuted
	{
		this.GetVehiclePS().quickhackRecklessDrivingExecuted = true;
		this.ShowQuickHackDuration(evt);

		let panicDrive: ref<AIVehiclePanicCommand> = new AIVehiclePanicCommand();
		panicDrive.needDriver = false;
		panicDrive.useKinematic = false;

    	let commandEvent: ref<AICommandEvent> = new AICommandEvent();
    	commandEvent.command = panicDrive;
		commandEvent.timeToLive = evt.GetDurationValue();
    	this.QueueEvent(commandEvent);


		//let command: ref<AIVehicleChaseCommand> = new AIVehicleChaseCommand();
    	//command.target = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    	//command.distanceMin = 5.00;
    	//command.distanceMax = 10.00;
    	//command.forcedStartSpeed = 10.0;
		//command.useKinematic = true;

		//command.needDriver = false;

		//let throttleEvent:ref<VehicleRecklessDrivingDeviceAction> = new VehicleRecklessDrivingDeviceAction();
		//GameInstance.GetDelaySystem(this.GetGame()).DelayEventNextFrame(this, throttleEvent);
		//LogChannel(n"DEBUG","Throttle");
	}
	else
	{
		this.GetVehiclePS().quickhackRecklessDrivingExecuted = false;

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

