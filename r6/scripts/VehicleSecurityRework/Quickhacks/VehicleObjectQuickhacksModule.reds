module VehicleSecurityRework.Quickhack

import HackingExtensions.*
import CustomHackingSystem.Tools.*

/*
	Module used to setup the quickhack functionalities for vehicles

	99.99% of these functions have been a stupid copy/paste from Device/InteractiveDevice/VendingMachineControllerPS/VendingMachine (and many more)
	Some of these functions are not needed (and can be removed) but i forgot which one to remove ...
*/

@wrapMethod(ScriptedPuppet)
protected const func ShouldRegisterToHUD() -> Bool
{
	if this.IsVehicle()
	{
		return true;
	}
	return wrappedMethod();
}

@replaceMethod(VehicleObject)
public const func CanRevealRemoteActionsWheel() -> Bool
{
	return true;
}

@replaceMethod(VehicleObject)
public const func IsQuickHackAble() -> Bool
{
	return true;
}

@replaceMethod(VehicleObject)
public const func IsQuickHacksExposed() -> Bool
{
	return true;
}

@replaceMethod(VehicleComponent)
private final func RegisterToHUDManager(shouldRegister: Bool) -> Void {
  let hudManager: ref<HUDManager>;
  let registration: ref<HUDManagerRegistrationRequest>;	
  //this fixes an issue with quickhack panel getting permanently disabled if you were mounting a vehicle
  //Surely this should not cause some issues right ... ???
  shouldRegister = true;
  //Enables the crowd vehicles to be registered in the HUD manager (therefore enables remote wheel)
  //if this.GetVehicle().IsCrowdVehicle() && !this.GetVehicle().ShouldForceRegisterInHUDManager() {
  //  return;
  //};
  hudManager = GameInstance.GetScriptableSystemsContainer(this.GetVehicle().GetGame()).Get(n"HUDManager") as HUDManager;
  if IsDefined(hudManager) {
    registration = new HUDManagerRegistrationRequest();
    registration.SetProperties(this.GetVehicle(), shouldRegister);
    hudManager.QueueRequest(registration);
  };
}

@addMethod(VehicleObject)
protected func ExecuteBaseActionOperation(actionClassName: CName) -> Void
{
	let ps: ref<ScriptableDeviceComponentPS> = this.GetVehiclePS();
	if ps.GetDeviceOperationsContainer() != null
	{
		ps.GetDeviceOperationsContainer().EvaluateDeviceActionTriggers(actionClassName, this);
	};
}
@addMethod(VehicleObject)
  public const func HasActiveQuickHackUpload() -> Bool {
    if IsDefined(this.m_gameplayRoleComponent) {
      return this.m_gameplayRoleComponent.HasActiveMappin(gamedataMappinVariant.QuickHackVariant);
    };
    return false;
  }

@addMethod(VehicleObject)
protected cb func OnPerformedAction(evt: ref<PerformedAction>) -> Bool 
{
	let action: ref<ScriptableDeviceAction>;
  	let sequenceQuickHacks: ref<ForwardAction>;
  	this.SetScannerDirty(true);
  	action = evt.m_action as ScriptableDeviceAction;
  	this.ExecuteBaseActionOperation(evt.m_action.GetClassName());
  	if action.CanTriggerStim() {
  	  this.TriggerAreaEffectDistractionByAction(action);
  	};
  	if IsDefined(action) && action.IsIllegal() && !action.IsQuickHack() {
  	  this.ResolveIllegalAction(action.GetExecutor(), action.GetDurationValue());
  	};
  	if this.IsConnectedToActionsSequencer() && !this.IsLockedViaSequencer() {
  	  sequenceQuickHacks = new ForwardAction();
  	  sequenceQuickHacks.requester = this.GetVehiclePS().GetID();
  	  sequenceQuickHacks.actionToForward = action;
  	  GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetVehiclePS().GetActionsSequencer().GetID(), this.GetVehiclePS().GetActionsSequencer().GetClassName(), sequenceQuickHacks);
  	};
  	this.ResolveQuestImportanceOnPerformedAction(action);
}

@addMethod(VehicleObject)
protected cb func OnQuickHackPanelStateChanged(evt: ref<QuickHackPanelStateEvent>) -> Bool {
  this.DetermineInteractionStateByTask();
}


@addMethod(VehicleObject)
private final func ResolveRemoteActions(state: Bool) -> Void {
  let context: GetActionsContext = this.GetVehiclePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
  if state {
	this.GetVehiclePS().AddActiveContext(gamedeviceRequestType.Remote);
	this.NotifyConnectionHighlightSystem(true, false);
  } else {
	if !this.IsCurrentTarget() && !this.IsCurrentlyScanned() {
	  this.GetVehiclePS().RemoveActiveContext(gamedeviceRequestType.Remote);
	} else {
	  return;
	};
  };
  this.DetermineInteractionStateByTask(context);
}


@addMethod(VehicleObject)
protected func NotifyConnectionHighlightSystem(IsHighlightON: Bool, IsNotifiedByMasterDevice: Bool) -> Bool {
  let hightlightSystemRequest: ref<HighlightConnectionsRequest>;
  let highlightTargets: array<NodeRef> = this.GetVehiclePS().GetConnectionHighlightObjects();
  if ArraySize(highlightTargets) <= 0 {
	return false;
  };
  hightlightSystemRequest = new HighlightConnectionsRequest();
  hightlightSystemRequest.shouldHighlight = IsHighlightON;
  hightlightSystemRequest.isTriggeredByMasterDevice = IsNotifiedByMasterDevice;
  hightlightSystemRequest.highlightTargets = highlightTargets;
  hightlightSystemRequest.requestingDevice = this.GetEntityID();
  this.GetDeviceConnectionsHighlightSystem().QueueRequest(hightlightSystemRequest);
  return true;
}

@addMethod(VehicleObject)
private final func GetDeviceConnectionsHighlightSystem() -> ref<DeviceConnectionsHighlightSystem> {
  return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DeviceConnectionsHighlightSystem") as DeviceConnectionsHighlightSystem;
}

@addMethod(VehicleObject)
protected final func DetermineInteractionStateByTask(opt context: GetActionsContext) -> Void {
  let taskData: ref<DetermineInteractionStateTaskData>;
  if NotEquals(context.requestType, gamedeviceRequestType.None) {
	taskData = new DetermineInteractionStateTaskData();
	taskData.context = context;
  };
  GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, taskData, n"DetermineInteractionStateTask", gameScriptTaskExecutionStage.Any);
}


@addMethod(VehicleObject)
protected cb func OnQuickSlotCommandUsed(evt: ref<QuickSlotCommandUsed>) -> Bool {
  this.ExecuteAction(evt.action, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject());
}
@addMethod(VehicleObject)
protected final const func ExecuteAction(action: ref<DeviceAction>, opt executor: wref<GameObject>) -> Bool {
  let sAction: ref<ScriptableDeviceAction> = action as ScriptableDeviceAction;
  if sAction != null {
	sAction.RegisterAsRequester(this.GetEntityID());
	if executor != null {
	  sAction.SetExecutor(executor);
	};
	sAction.ProcessRPGAction(this.GetGame());
	return true;
  };
  return false;
}



@addMethod(VehicleObject)
  private final func ResolveQuestImportanceOnPerformedAction(action: ref<ScriptableDeviceAction>) -> Void {
	let authOffAction: ref<SetAuthorizationModuleOFF>;
	let skillcheckAction: ref<ActionSkillCheck>;
	if !this.GetVehiclePS().IsAutoTogglingQuestMark() {
	  return;
	};
	skillcheckAction = action as ActionSkillCheck;
	authOffAction = action as SetAuthorizationModuleOFF;
	if IsDefined(authOffAction) {
	  this.ToggleQuestImportance(false);
	} else {
	  if !this.HasAnySkillCheckActive() {
		if Equals(action.GetRequestType(), gamedeviceRequestType.Remote) || Equals(action.GetRequestType(), gamedeviceRequestType.Direct) {
		  this.ToggleQuestImportance(false);
		};
	  } else {
		if IsDefined(skillcheckAction) {
		  if skillcheckAction.IsCompleted() {
			this.ToggleQuestImportance(false);
		  };
		};
	  };
	};
  }
@addMethod(VehicleObject)
  public final const func HasAnySkillCheckActive() -> Bool {
	return this.GetVehiclePS().IsHackingSkillCheckActive() || this.GetVehiclePS().IsDemolitionSkillCheckActive() || this.GetVehiclePS().IsEngineeringSkillCheckActive();
  }


@addMethod(VehicleObject)
  protected func ResolveIllegalAction(executor: ref<GameObject>, duration: Float) -> Void {
	let broadcaster: ref<StimBroadcasterComponent>;
	let stimData: stimInvestigateData;
	if IsDefined(executor) {
	  broadcaster = executor.GetStimBroadcasterComponent();
	  if IsDefined(broadcaster) {
		stimData.fearPhase = -1;
		broadcaster.TriggerSingleBroadcast(this, gamedataStimType.IllegalAction, 15.00, stimData);
	  };
	};
  }

@addMethod(VehicleObject)
  protected final const func IsConnectedToActionsSequencer() -> Bool {
	return this.GetVehiclePS().IsConnectedToActionsSequencer();
  }

@addMethod(VehicleObject)
  protected final const func IsLockedViaSequencer() -> Bool {
	return this.GetVehiclePS().IsLockedViaSequencer();
  }


@addMethod(VehicleObject)
  protected final func TriggerAreaEffectDistractionByAction(action: ref<ScriptableDeviceAction>) -> Void {
	let effectData: ref<AreaEffectData>;
	let quickHackIndex: Int32;
	if IsDefined(this.GetFxResourceMapper()) {
	  quickHackIndex = this.GetFxResourceMapper().GetAreaEffectDataIndexByAction(action);
	  if quickHackIndex >= 0 {
		effectData = this.GetFxResourceMapper().GetAreaEffectDataByIndex(quickHackIndex);
		effectData.stimLifetime = action.GetDurationValue();
		this.TriggerArreaEffectDistraction(effectData);
	  };
	};
  }

@addMethod(VehicleObject)
  protected final func TriggerArreaEffectDistraction(effectData: ref<AreaEffectData>, opt executor: ref<GameObject>) -> Void {
	let broadcaster: ref<StimBroadcasterComponent>;
	let districtStimMultiplier: Float;
	let i: Int32;
	let investigateData: stimInvestigateData;
	let stimType: gamedataStimType = Device.MapStimType(effectData.stimType);
	let stimLifetime: Float = effectData.stimLifetime;
	let target: ref<GameObject> = this.GetEntityFromNode(effectData.stimSource) as GameObject;
	if target == null {
	  target = this.GetStimTarget();
	} else {
	  investigateData.mainDeviceEntity = this.GetStimTarget();
	};
	if effectData.investigateController {
	  investigateData.controllerEntity = this.GetDistractionControllerSource(effectData);
	  if IsDefined(investigateData.controllerEntity) {
		investigateData.investigateController = true;
	  };
	};
	investigateData.distrationPoint = this.GetDistractionPointPosition(target);
	investigateData.investigationSpots = this.GetNodePosition(effectData.investigateSpot);
	if IsDefined(executor) {
	  investigateData.attackInstigator = executor;
	} else {
	  if IsDefined(effectData.action.GetExecutor()) {
		investigateData.attackInstigator = effectData.action.GetExecutor();
	  };
	};
	broadcaster = target.GetStimBroadcasterComponent();
	if IsDefined(broadcaster) {
	  if Equals(stimType, gamedataStimType.DeviceExplosion) {
		districtStimMultiplier = (GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet).GetExplosionRange();
		broadcaster.SetSingleActiveStimuli(this, stimType, stimLifetime, effectData.stimRange * districtStimMultiplier, investigateData);
	  } else {
		broadcaster.SetSingleActiveStimuli(this, stimType, stimLifetime, effectData.stimRange, investigateData);
	  };
	};
	if ArraySize(effectData.additionaStimSources) > 0 {
	  i = 0;
	  while i < ArraySize(effectData.additionaStimSources) {
		target = this.GetEntityFromNode(effectData.additionaStimSources[i]) as GameObject;
		if IsDefined(target) {
		  broadcaster = target.GetStimBroadcasterComponent();
		  if IsDefined(broadcaster) {
			broadcaster.SetSingleActiveStimuli(this, stimType, stimLifetime, effectData.stimRange);
		  };
		};
		i += 1;
	  };
	};
  }
@addMethod(VehicleObject)
  public final func GetEntityFromNode(nodeRef: NodeRef) -> ref<Entity> {
	let id: EntityID = Cast<EntityID>(ResolveNodeRefWithEntityID(nodeRef, this.GetEntityID()));
	return GameInstance.FindEntityByID(this.GetGame(), id);
  }

@addMethod(VehicleObject)
  public func GetStimTarget() -> ref<GameObject> {
	return this;
  }

@addMethod(VehicleObject)
  public func GetDistractionControllerSource(opt effectData: ref<AreaEffectData>) -> ref<Entity> {
	return this.GetEntityFromNode(effectData.controllerSource);
  }

@addMethod(VehicleObject)
  public final func GetDistractionPointPosition(device: wref<GameObject>) -> Vector4 {
	let objectTransform: WorldTransform;
	if this.GetUISlotComponent().GetSlotTransform(n"distractionPoint", objectTransform) {
	  return WorldPosition.ToVector4(WorldTransform.GetWorldPosition(objectTransform));
	};
	if this.GetUISlotComponent().GetSlotTransform(n"roleMappin", objectTransform) {
	  return WorldPosition.ToVector4(WorldTransform.GetWorldPosition(objectTransform));
	};
	return device.GetWorldPosition();
  }

@addField(VehicleObject)
public let m_effectVisualization:ref<AreaEffectVisualizationComponent>;

@addField(VehicleObject)
public let m_resourceLibraryComponent:ref<ResourceLibraryComponent>;

@addField(VehicleObject)
protected let m_gameplayRoleComponent: ref<GameplayRoleComponent>;

@addField(VehicleObject)
protected let m_interaction: ref<InteractionComponent>;

@wrapMethod(VehicleObject)
protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool
{
	this.m_fxResourceMapper = EntityResolveComponentsInterface.GetComponent(ri, n"FxResourceMapper") as FxResourceMapperComponent;
	this.m_slotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"main_slot") as SlotComponent;
    this.m_effectVisualization = EntityResolveComponentsInterface.GetComponent(ri, n"AreaEffectVisualization") as AreaEffectVisualizationComponent;
    this.m_resourceLibraryComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ResourceLibrary") as ResourceLibraryComponent;
    this.m_gameplayRoleComponent = EntityResolveComponentsInterface.GetComponent(ri, n"GameplayRole") as GameplayRoleComponent;
    this.m_scanningComponent = EntityResolveComponentsInterface.GetComponent(ri, n"scanning") as ScanningComponent;
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;


	wrappedMethod(ri);

}

@wrapMethod(VehicleObject)
  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"FxResourceMapper", n"FxResourceMapperComponent", true);
	EntityRequestComponentsInterface.RequestComponent(ri, n"AreaEffectVisualization", n"AreaEffectVisualizationComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ResourceLibrary", n"ResourceLibraryComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"main_slot", n"SlotComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"GameplayRole", n"GameplayRoleComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"gameinteractionsComponent", true);

	wrappedMethod(ri);
  }


@addField(VehicleObject)
protected let m_fxResourceMapper: ref<FxResourceMapperComponent>;

@addMethod(VehicleObject)
  public final const func GetFxResourceMapper() -> ref<FxResourceMapperComponent> {
	return this.m_fxResourceMapper;
  }

@addField(VehicleObject)
private let m_slotComponent: ref<SlotComponent>;


@addMethod(VehicleObject)
  public final const func GetNodePosition(opt nodeRef: NodeRef) -> array<Vector4> {
	let globalRef: GlobalNodeRef;
	let i: Int32;
	let navQuerryForward: Vector4;
	let nodeTransform: Transform;
	let pointResults: NavigationFindPointResult;
	let position: Vector4;
	let positionsArray: array<Vector4>;
	let setPositionsEvt: ref<SetInvestigationPositionsArrayEvent>;
	let slotName: CName;
	let slotOffsetMult: Float;
	let slotPosition: Vector4;
	let sourcePos: Vector4;
	let transform: WorldTransform;
	globalRef = ResolveNodeRefWithEntityID(nodeRef, this.GetEntityID());
	if GlobalNodeRef.IsDefined(globalRef) {
	  GameInstance.GetNodeTransform(this.GetGame(), globalRef, nodeTransform);
	  position = Transform.GetPosition(nodeTransform);
	  if !Vector4.IsZero(position) {
		pointResults = GameInstance.GetNavigationSystem(this.GetGame()).FindPointInSphereOnlyHumanNavmesh(position, 0.50, NavGenAgentSize.Human, false);
	  } else {
		pointResults.status = worldNavigationRequestStatus.OtherError;
	  };
	};
	if Equals(pointResults.status, worldNavigationRequestStatus.OK) {
	  position = pointResults.point;
	  ArrayPush(positionsArray, position);
	} else {
	  if this.GetSlotComponent().GetSlotTransform(n"navQuery", transform) {
		slotName = n"navQuery";
	  } else {
		slotName = n"navQuery0";
	  };
	  slotOffsetMult = this.GetFxResourceMapper().GetInvestigationSlotOffset();
	  if slotOffsetMult <= 0.00 {
		slotOffsetMult = 1.00;
	  };
	  sourcePos = this.GetWorldPosition();
	  while this.GetSlotComponent().GetSlotTransform(slotName, transform) {
		slotPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform));
		slotPosition.Z = sourcePos.Z;
		navQuerryForward = slotPosition - sourcePos;
		navQuerryForward = Transform.TransformVector(WorldTransform._ToXForm(WorldTransform.GetInverse(this.GetWorldTransform())), navQuerryForward);
		if AbsF(navQuerryForward.X) > AbsF(navQuerryForward.Y) {
		  navQuerryForward.Y = 0.00;
		} else {
		  navQuerryForward.X = 0.00;
		};
		navQuerryForward = Vector4.Normalize(navQuerryForward) * slotOffsetMult;
		navQuerryForward = Transform.TransformVector(WorldTransform._ToXForm(this.GetWorldTransform()), navQuerryForward);
		slotPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform)) + navQuerryForward;
		WorldTransform.SetPosition(transform, slotPosition);
		position = GameInstance.GetNavigationSystem(this.GetGame()).GetNearestNavmeshPointBelowOnlyHumanNavmesh(this.CheckQueryStartPoint(transform), 1.00, 5);
		if !Vector4.IsZero(position) {
		  ArrayPush(positionsArray, position);
		};
		i += 1;
		slotName = StringToName("navQuery" + i);
	  };
	};
	if ArraySize(positionsArray) > 0 {
	  setPositionsEvt = new SetInvestigationPositionsArrayEvent();
	  setPositionsEvt.investigationPositionsArray = positionsArray;
	  GameInstance.GetPersistencySystem(this.GetGame()).QueueEntityEvent(this.GetEntityID(), setPositionsEvt);
	};
	return positionsArray;
  }

@addMethod(VehicleObject)
  public const func CheckQueryStartPoint(transform: WorldTransform) -> Vector4 {
	let point: Vector4 = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform));
	if Vector4.IsZero(point) {
	  point = this.GetWorldPosition();
	};
	return point;
  }



@addMethod(VehicleObject)
  public final const func GetSlotComponent() -> ref<SlotComponent> {
	return this.m_slotComponent;
  }

@addMethod(VehicleObject)
  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
	super.OnHUDInstruction(evt);
	
	if Equals(evt.highlightInstructions.GetState(), InstanceState.ON) {
	  this.GetVehiclePS().SetFocusModeData(true);
	  this.ResolveDeviceOperationOnFocusMode(gameVisionModeType.Focus, true);
	} else {
	  if evt.highlightInstructions.WasProcessed() {
		this.GetVehiclePS().SetFocusModeData(false);
		//this.ToggleAreaIndicator(false);
		this.ResolveDeviceOperationOnFocusMode(gameVisionModeType.Default, false);
		//this.NotifyConnectionHighlightSystem(false, false);
	  };
	};
	if evt.quickhackInstruction.ShouldProcess() {
	  this.TryOpenQuickhackMenu(evt.quickhackInstruction.ShouldOpen());
	}
	return true;
  }

@addMethod(VehicleObject)
private final func ResolveDeviceOperationOnFocusMode(visionType: gameVisionModeType, activated: Bool) -> Void {
  let operationType: ETriggerOperationType;
  if Equals(visionType, gameVisionModeType.Focus) {
	if activated {
	  operationType = ETriggerOperationType.ENTER;
	} else {
	  operationType = ETriggerOperationType.EXIT;
	};
	if this.GetVehiclePS().GetDeviceOperationsContainer() != null {
	  this.GetVehiclePS().GetDeviceOperationsContainer().EvaluateFocusModeTriggers(this, operationType);
	};
  };
}

@addMethod(VehicleObject)
public const func CanRevealRemoteActionsWheel() -> Bool
{
	return !this.GetVehiclePS().GetHasExploded();
}

@addMethod(VehicleObject)
public const func GetPlayerMainObject() -> ref<PlayerPuppet>
{
	return GetPlayer(this.GetGame());
}

@addField(VehicleObject)
protected let m_isQhackUploadInProgerss:Bool;

@addMethod(VehicleObject)
protected func SendQuickhackCommands(shouldOpen: Bool) -> Void {
  let actions: array<ref<DeviceAction>>;
  let commands: array<ref<QuickhackData>>;
  let context: GetActionsContext;
  let quickSlotsManagerNotification: ref<RevealInteractionWheel> = new RevealInteractionWheel();
  quickSlotsManagerNotification.lookAtObject = this;
  quickSlotsManagerNotification.shouldReveal = shouldOpen;
  if shouldOpen {
	context = this.GetVehiclePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
	this.GetVehiclePS().GetRemoteActions(actions, context);
	if this.m_isQhackUploadInProgerss {
	  ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7020");
	};
	this.TranslateActionsIntoQuickSlotCommands(actions, commands);
	quickSlotsManagerNotification.commands = commands;

	this.GetVehicleComponent().DetermineInteractionState();
  }
  HUDManager.SetQHDescriptionVisibility(this.GetGame(), shouldOpen);
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(quickSlotsManagerNotification);
}

//TODO: HIGHLIGHT
@addMethod(VehicleObject)
  private func TranslateActionsIntoQuickSlotCommands(actions: array<ref<DeviceAction>>, out commands: array<ref<QuickhackData>>) -> Void {
	
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGame());
	let customHackSystem:ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;

	let actionCompletionEffects: array<wref<ObjectActionEffect_Record>>;
	let actionMatchDeck: Bool;
	let actionRecord: wref<ObjectAction_Record>;
	let actionStartEffects: array<wref<ObjectActionEffect_Record>>;
	let choice: InteractionChoice;
	let emptyChoice: InteractionChoice;
	let i: Int32;
	let i1: Int32;
	let newCommand: ref<QuickhackData>;
	let sAction: ref<ScriptableDeviceAction>;
	let statModifiers: array<wref<StatModifier_Record>>;
	let playerRef: ref<PlayerPuppet> = GetPlayer(this.GetGame());
	let iceLVL: Float = 0.0;
	let actionOwnerName: CName = StringToName(this.GetDisplayName());
	let playerQHacksList: array<PlayerQuickhackData> = RPGManager.GetPlayerQuickHackListWithQuality(playerRef);

	let customActionsFound:array<wref<ObjectAction_Record>>;
	if ArraySize(playerQHacksList) == 0 {
	  newCommand = new QuickhackData();
	  newCommand.m_title = "LocKey#42171";
	  newCommand.m_isLocked = true;
	  newCommand.m_actionState = EActionInactivityReson.Invalid;
	  newCommand.m_actionOwnerName = StringToName(this.GetDisplayName());
	  newCommand.m_description = "LocKey#42172";
	  ArrayPush(commands, newCommand);
	}
	else
	{
	  i = 0;
	  while i < ArraySize(playerQHacksList)
	  {
		newCommand = new QuickhackData();
		sAction = null;
		ArrayClear(actionStartEffects);
		actionRecord = playerQHacksList[i].actionRecord;
		if NotEquals(actionRecord.ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack)
		{
		}
		else {
		  actionMatchDeck = false;
		  i1 = 0;
		  while i1 < ArraySize(actions) {
			sAction = actions[i1] as ScriptableDeviceAction;
			//LogChannel(n"DEBUG",NameToString(sAction.actionName));
			if Equals(actionRecord.ActionName(), sAction.GetObjectActionRecord().ActionName()) {
			  //LogChannel(n"DEBUG","Matches Wrong Deck");
			  actionMatchDeck = true;
			  if actionRecord.Priority() >= sAction.GetObjectActionRecord().Priority() {
				sAction.SetObjectActionID(playerQHacksList[i].actionRecord.GetID());
			  } else {
				actionRecord = sAction.GetObjectActionRecord();
			  };
			  newCommand.m_uploadTime = sAction.GetActivationTime();
			  newCommand.m_duration = sAction.GetDurationValue();
			  break;
			};
			//LogChannel(n"DEBUG","	Checking " + NameToString(sAction.actionName));
//TODO AAAAAAAAAAAAAAAAAAAAAAAAA (highlight)
			if customHackSystem.customDeviceActions.KeyExist(NameToString(sAction.actionName)) 
			&& !ArrayContains(customActionsFound,sAction.GetObjectActionRecord())
			{
			  //LogChannel(n"DEBUG","Matches Deck");
			  actionMatchDeck = true;
			  actionRecord = sAction.GetObjectActionRecord();
			  newCommand.m_uploadTime = sAction.GetActivationTime();
			  newCommand.m_duration = sAction.GetDurationValue();
			  ArrayPush(customActionsFound,sAction.GetObjectActionRecord());
			  break;
			};

			i1 += 1;
		  };
		  newCommand.m_actionOwnerName = actionOwnerName;
		  newCommand.m_title = LocKeyToString(actionRecord.ObjectActionUI().Caption());
		  newCommand.m_description = LocKeyToString(actionRecord.ObjectActionUI().Description());
		  newCommand.m_icon = actionRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID();
		  newCommand.m_iconCategory = actionRecord.GameplayCategory().IconName();
		  newCommand.m_type = actionRecord.ObjectActionType().Type();
		  newCommand.m_actionOwner = this.GetEntityID();
		  newCommand.m_isInstant = false;
		  newCommand.m_ICELevel = iceLVL;
		  newCommand.m_ICELevelVisible = false;
		  newCommand.m_vulnerabilities = this.GetVehiclePS().GetActiveQuickHackVulnerabilities();
		  newCommand.m_actionState = EActionInactivityReson.Locked;
		  newCommand.m_quality = playerQHacksList[i].quality;
		  newCommand.m_costRaw = BaseScriptableAction.GetBaseCostStatic(playerRef, actionRecord);
		  newCommand.m_category = actionRecord.HackCategory();
		  ArrayClear(actionCompletionEffects);
		  actionRecord.CompletionEffects(actionCompletionEffects);
		  newCommand.m_actionCompletionEffects = actionCompletionEffects;
		  actionRecord.StartEffects(actionStartEffects);
		  i1 = 0;
		  while i1 < ArraySize(actionStartEffects) {
			if Equals(actionStartEffects[i1].StatusEffect().StatusEffectType().Type(), gamedataStatusEffectType.PlayerCooldown) {
			  actionStartEffects[i1].StatusEffect().Duration().StatModifiers(statModifiers);
			  newCommand.m_cooldown = RPGManager.CalculateStatModifiers(statModifiers, this.GetGame(), playerRef, Cast<StatsObjectID>(playerRef.GetEntityID()), Cast<StatsObjectID>(playerRef.GetEntityID()));
			  newCommand.m_cooldownTweak = actionStartEffects[i1].StatusEffect().GetID();
			  ArrayClear(statModifiers);
			};
			if newCommand.m_cooldown != 0.00 {
			  break;
			};
			i1 += 1;
		  };
		  if actionMatchDeck {
			if !IsDefined(this as GenericDevice) {
			  choice = emptyChoice;
			  choice = sAction.GetInteractionChoice();
			  if TDBID.IsValid(choice.choiceMetaData.tweakDBID) {
				newCommand.m_titleAlternative = LocKeyToString(TweakDBInterface.GetInteractionBaseRecord(choice.choiceMetaData.tweakDBID).Caption());
			  };
			};
			newCommand.m_cost = sAction.GetCost();
			if sAction.IsInactive() {
			  newCommand.m_isLocked = true;
			  newCommand.m_inactiveReason = sAction.GetInactiveReason();
			  if this.HasActiveQuickHackUpload() {
				newCommand.m_action = sAction;
			  };
			} else {
			  if !sAction.CanPayCost() {
				newCommand.m_actionState = EActionInactivityReson.OutOfMemory;
				newCommand.m_isLocked = true;
				newCommand.m_inactiveReason = "LocKey#27398";
			  };
			  if GameInstance.GetStatPoolsSystem(this.GetGame()).HasActiveStatPool(Cast<StatsObjectID>(this.GetEntityID()), gamedataStatPoolType.QuickHackUpload) {
				newCommand.m_isLocked = true;
				newCommand.m_inactiveReason = "LocKey#27398";
			  };
			  if !sAction.IsInactive() || this.HasActiveQuickHackUpload() {
				newCommand.m_action = sAction;
			  };
			};
		  } else {
			newCommand.m_isLocked = true;
			newCommand.m_inactiveReason = "LocKey#10943";
		  };
		  newCommand.m_actionMatchesTarget = actionMatchDeck;
		  if !newCommand.m_isLocked {
			newCommand.m_actionState = EActionInactivityReson.Ready;
		  };
		  ArrayPush(commands, newCommand);
		};
		i += 1;
	  };
	};
	i = 0;
	while i < ArraySize(commands) {
	  if commands[i].m_isLocked && IsDefined(commands[i].m_action) {
		(commands[i].m_action as ScriptableDeviceAction).SetInactiveWithReason(false, commands[i].m_inactiveReason);
	  };
	  i += 1;
	};
	QuickhackModule.SortCommandPriority(commands, this.GetGame());
}


@addMethod(VehicleObject)
  protected cb func OnUploadProgressStateChanged(evt: ref<UploadProgramProgressEvent>) -> Bool {
    if Equals(evt.progressBarContext, EProgressBarContext.QuickHack) {
      if Equals(evt.progressBarType, EProgressBarType.UPLOAD) {
        if Equals(evt.state, EUploadProgramState.STARTED) {
          this.m_isQhackUploadInProgerss = true;
        } else {
          if Equals(evt.state, EUploadProgramState.COMPLETED) {
            this.m_isQhackUploadInProgerss = false;
          };
        };
      };
    };
  }

@addMethod(VehicleObject)
public const func DeterminGameplayRoleMappinVisuaState(data: SDeviceMappinData) -> EMappinVisualState {
    let hasAnyQuickHacksVoulnerabilities: Bool;
    let hasQuickHacksExposed: Bool;
    if this.GetVehiclePS().IsDisabled() {
      return EMappinVisualState.Inactive;
    };
    if this.IsActiveBackdoor() {
      if !this.IsHackingSkillCheckActive() || this.IsHackingSkillCheckActive() && this.CanPassHackingSkillCheck() {
        return EMappinVisualState.Available;
      };
      return EMappinVisualState.Unavailable;
    };
    //if this.HasAnySkillCheckActive() && this.CanPassAnySkillCheck() {
    //  return EMappinVisualState.Available;
    //};
    hasQuickHacksExposed = this.GetNetworkSystem().QuickHacksExposedByDefault() || this.IsConnectedToBackdoorDevice() && this.GetVehiclePS().IsQuickHacksExposed();
    if hasQuickHacksExposed {
      hasAnyQuickHacksVoulnerabilities = this.GetVehiclePS().HasAnyActiveQuickHackVulnerabilities();
    };
    if hasQuickHacksExposed && hasAnyQuickHacksVoulnerabilities {
      return EMappinVisualState.Available;
    };
    //if this.HasAnySkillCheckActive() && !this.CanPassAnySkillCheck() {
    //  return EMappinVisualState.Unavailable;
    //};
    if !this.HasAnySkillCheckActive() && !hasQuickHacksExposed {
      return EMappinVisualState.Unavailable;
    };
    if hasQuickHacksExposed && !hasAnyQuickHacksVoulnerabilities {
      return EMappinVisualState.Unavailable;
    };
    return this.DeterminGameplayRoleMappinVisuaState(data);
}

@addMethod(VehicleObject)
protected const func GetDistractionRange(type: DeviceStimType) -> Float
{
    if IsDefined(this.GetFxResourceMapper()) 
	{
    	return this.GetFxResourceMapper().GetDistractionRange(type);
    };
    return 15.00;
}

@addMethod(VehicleObject)
public const func DeterminGameplayRoleMappinRange(data: SDeviceMappinData) -> Float 
{
    let range: Float;
    if NotEquals(data.gameplayRole, EGameplayRole.None) {
      switch data.gameplayRole {
        case EGameplayRole.Distract:
          if this.IsAnyPlaystyleValid() {
            range = this.GetDistractionRange(DeviceStimType.Distract);
          };
          break;
        case EGameplayRole.DistractVendingMachine:
          if this.IsAnyPlaystyleValid() {
            range = this.GetDistractionRange(DeviceStimType.Distract);
          };
          break;
        case EGameplayRole.ExplodeLethal:
          range = this.GetDistractionRange(DeviceStimType.Explosion);
          break;
        case EGameplayRole.ExplodeNoneLethal:
          range = this.GetDistractionRange(DeviceStimType.Explosion);
          break;
        case EGameplayRole.SpreadGas:
          range = this.GetDistractionRange(DeviceStimType.VentilationAreaEffect);
          break;
        default:
          if this.IsNetrunner() {
            range = this.GetDistractionRange(DeviceStimType.Distract);
          } else {
            range = 0.00;
          };
      };
    };
    return range;
}

@addMethod(VehicleObject)
public final func GetDistractionPointPosition(device: wref<GameObject>) -> Vector4 
{
    let objectTransform: WorldTransform;
    if this.GetUISlotComponent().GetSlotTransform(n"distractionPoint", objectTransform) {
      return WorldPosition.ToVector4(WorldTransform.GetWorldPosition(objectTransform));
    };
    if this.GetUISlotComponent().GetSlotTransform(n"roleMappin", objectTransform) {
      return WorldPosition.ToVector4(WorldTransform.GetWorldPosition(objectTransform));
    };
    return device.GetWorldPosition();
}

@addMethod(VehicleObject)
private final func ShowQuickHackDuration(action: ref<ScriptableDeviceAction>) -> Void 
{
    let actionDurationListener: ref<QuickHackDurationListener>;
    let statMod: ref<gameStatModifierData>;
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    GameInstance.GetStatsSystem(this.GetGame()).RemoveAllModifiers(Cast<StatsObjectID>(this.GetEntityID()), gamedataStatType.QuickHackDuration, true);
    statMod = RPGManager.CreateStatModifier(gamedataStatType.QuickHackDuration, gameStatModifierType.Additive, 1.00);
    GameInstance.GetStatsSystem(this.GetGame()).RemoveAllModifiers(Cast<StatsObjectID>(this.GetEntityID()), gamedataStatType.QuickHackDuration);
    GameInstance.GetStatsSystem(this.GetGame()).AddModifier(Cast<StatsObjectID>(this.GetEntityID()), statMod);
    actionDurationListener = new QuickHackDurationListener();
    actionDurationListener.m_action = action;
    actionDurationListener.m_gameInstance = this.GetGame();
    statPoolSys.RequestRegisteringListener(Cast<StatsObjectID>(this.GetEntityID()), gamedataStatPoolType.QuickHackDuration, actionDurationListener);
    statPoolSys.RequestAddingStatPool(Cast<StatsObjectID>(this.GetEntityID()), t"BaseStatPools.QuickHackDuration", true);
}


@addField(VehicleObject)
public let m_activeStatusEffects:array<wref<StatusEffect_Record>>;

@addField(VehicleObject)
protected let m_activeStatusEffect: TweakDBID;

@addField(VehicleObject)
protected let m_activeProgramToUploadOnNPC: TweakDBID;

@addMethod(VehicleObject)
protected func ApplyActiveStatusEffect(target: EntityID, statusEffect: TweakDBID) -> Void 
{
    if this.IsActiveStatusEffectValid() && this.GetVehiclePS().IsGlitching()
	{
    	GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(target, statusEffect);
    }
}

@addMethod(VehicleObject)
protected final const func IsActiveStatusEffectValid() -> Bool
{
    return TDBID.IsValid(this.m_activeStatusEffect);
}

@addMethod(VehicleObject)
protected func UploadActiveProgramOnNPC(targetID: EntityID) -> Void 
{
    let evt: ref<ExecutePuppetActionEvent>;
    if this.IsActiveProgramToUploadOnNPCValid() && this.GetVehiclePS().IsGlitching() {
      evt = new ExecutePuppetActionEvent();
      evt.actionID = this.GetActiveProgramToUploadOnNPC();
      this.QueueEventForEntityID(targetID, evt);
    };
}

@addMethod(VehicleObject)
protected final const func IsActiveProgramToUploadOnNPCValid() -> Bool 
{
	return TDBID.IsValid(this.m_activeProgramToUploadOnNPC);
}

@addMethod(VehicleObject)
protected final const func GetActiveProgramToUploadOnNPC() -> TweakDBID 
{
    return this.m_activeProgramToUploadOnNPC;
}

@addMethod(VehicleObject)
protected final func CheckDistractionAchievemnt() -> Void 
{
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    let request: ref<ModifyTelemetryVariable> = new ModifyTelemetryVariable();
    request.dataTrackingFact = ETelemetryData.QuickHacksMade;
    dataTrackingSystem.QueueRequest(request);
}

@addMethod(VehicleComponentPS)
  public func DetermineQuickhackInteractionState(interactionComponent: ref<InteractionComponent>, context: GetActionsContext) -> Void {
	let actions: array<ref<DeviceAction>>;
	let activeChoices: array<InteractionChoice>;
	let allChoices: array<InteractionChoice>;
	if this.m_isLockedViaSequencer {
	  return;
	};
	if !(Equals(context.requestType, gamedeviceRequestType.Direct) || Equals(context.requestType, gamedeviceRequestType.Remote)) {
	  return;
	};
	if this.m_isInteractive && !this.GetHudManager().IsQuickHackPanelOpened() {
	  if this.HasActiveContext(gamedeviceRequestType.Remote) {
		if !this.m_disableQuickHacks && (this.IsQuickHacksExposed() || this.m_debugExposeQuickHacks) {
		  if this.IsPowered() {
			this.GetQuickHackActions(actions, context);
			this.UpdateAvailAbleQuickHacks(actions);
		  };
		};
	  };
	  if this.HasActiveContext(gamedeviceRequestType.Direct) {
		if !this.GetTakeOverControlSystem().IsDeviceControlled() {
		  this.GetActions(actions, context);
		  this.FinalizeGetActions(actions);
		};
	  };
	  BasicInteractionInterpreter.Evaluate(this.IsDeviceSecured(), actions, allChoices, activeChoices);
	  if ArraySize(activeChoices) == 0 && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
		this.PushInactiveInteractionChoice(context, allChoices);
	  };
	};
	this.PushChoicesToInteractionComponent(interactionComponent, context, allChoices);
}
