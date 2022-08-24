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

//Not Working
@addMethod(VehicleComponentPS)
private final const func ActionVehicleDistraction() -> ref<VehicleDistractionDeviceAction> 
{
	let action: ref<VehicleDistractionDeviceAction> = new VehicleDistractionDeviceAction();
	action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
	action.SetUp(this);
	action.SetProperties();
	action.AddDeviceName(this.m_deviceName);
	action.SetCanTriggerStim(true);
	action.SetDurationValue(25.0);

	action.SetObjectActionID(t"DeviceAction.VehicleDistraction");
	
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
	action.SetDurationValue(10.0);

	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let customHackSystem: ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	customHackSystem.RegisterDeviceAction(action);
	action.CreateInteraction();

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
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if evt.IsStarted() 
	{
    	this.m_distractExecuted = true;
    	this.m_isGlitching = true;
    	this.m_distractionTimeCompleted = false;
    	evt.SetCanTriggerStim(true);
    	evt.SetObjectActionID(t"DeviceAction.EndMalfunction");
    	this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
		this.GetOwnerEntity().Distract();
		this.GetOwnerEntity().ToggleHornForDuration(evt.GetDurationValue());
		let visualDistraction: ref<VehicleDistractionVisual> = new VehicleDistractionVisual();
		this.GetOwnerEntity().QueueEvent(visualDistraction);
    } 
	else 
	{
    	this.m_distractionTimeCompleted = true;
    	if this.IsInvestigated() {
    	  return EntityNotificationType.DoNotNotifyEntity;
    	};
    	this.m_distractExecuted = false;
    	this.m_isGlitching = false;
    	evt.SetCanTriggerStim(false);
    };
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;

}
@addMethod(VehicleObject)
  protected final func Distract() -> Void {
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

	}

	let visualDistraction:ref<VehicleDistractionVisual> = new VehicleDistractionVisual();
	GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, visualDistraction, RandRangeF(0.15,0.75), true);

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

@addMethod(VehicleComponentPS)
protected cb func OnForceBrakesVehicle(evt:ref<VehicleForceBrakesDeviceAction>) -> EntityNotificationType 
{
	if this.quickhackForceBrakesExecuted
	{
		this.quickhackForceBrakesExecuted = false;
	}
	else
	{
		this.GetOwnerEntity().ForceBrakesFor(evt.GetDurationValue());
		this.quickhackForceBrakesExecuted = true;
		return EntityNotificationType.DoNotNotifyEntity;
		let endEvt = this.ActionVehicleForceBrakes();
		this.ExecutePSActionWithDelay(endEvt, this, evt.GetDurationValue());
	}
}

@addField(VehicleComponentPS)
public let quickhackForceBrakesExecuted:Bool = false;