module VehicleSecurityRework.Base
import VehicleSecurityRework.Hack.*

import InteractionExtensions.*
import TargetingExtensions.*

//Requires CustomHackingSystem

@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*
@if(ModuleExists("HackingExtensions.Programs"))
import HackingExtensions.Programs.*
@if(ModuleExists("CustomHackingSystem.Tools"))
import CustomHackingSystem.Tools.*


//TODO: Comments (maybe later) 
//(if you need help to understand how I done that pls just ping me on discord glhf)


//Scriptable System used by the lua part of the mod to find if redscript files are installed (at least this one) or not
public class VehicleSecurityRework extends ScriptableSystem
{
	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","General")
	@runtimeProperty("ModSettings.displayName","Auto Unlock Security")
	@runtimeProperty("ModSettings.description","If you only want vehicle quickhacks (Requires Game Restart)")
	public let forceSecurityUnlock:Bool = false;

	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","Compatibility")
	@runtimeProperty("ModSettings.displayName","Vehicle Combat Compatibility")
	@runtimeProperty("ModSettings.description","Enables compatibility for Vehicle Combat by changing prvention spawns when failing hack")
	public let vehicleCombatCompatibility:Bool = false;

	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","Vehicle Combat Compatibility")
	@runtimeProperty("ModSettings.displayName","Prevention Minimum Reaction Time")
	@runtimeProperty("ModSettings.description","Sets the minimum amount of time before prevention kicks in")
	@runtimeProperty("ModSettings.step", "0.1")
  	@runtimeProperty("ModSettings.min", "0")
  	@runtimeProperty("ModSettings.max", "10")
	public let preventionReactionTimeMin:Float = 0.4;
	
	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","Vehicle Combat Compatibility")
	@runtimeProperty("ModSettings.displayName","Prevention Maximum Reaction Time")
	@runtimeProperty("ModSettings.description","Sets the maximum amount of time before prevention kicks in")
	@runtimeProperty("ModSettings.step", "0.1")
  	@runtimeProperty("ModSettings.min", "0")
  	@runtimeProperty("ModSettings.max", "10")
	public let preventionReactionTimeMax:Float = 1.0;

	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","Vehicle Combat Compatibility")
	@runtimeProperty("ModSettings.displayName","Vehicles To Spawn (Easy Hack)")
	@runtimeProperty("ModSettings.description","Sets the number of vehicles to spawn in case of hack failure")
	@runtimeProperty("ModSettings.step", "1")
  	@runtimeProperty("ModSettings.min", "0")
  	@runtimeProperty("ModSettings.max", "5")
	public let vehiclesToSpawnEasy:Int32 = 1;

	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","Vehicle Combat Compatibility")
	@runtimeProperty("ModSettings.displayName","Vehicles To Spawn (Medium Hack)")
	@runtimeProperty("ModSettings.description","Sets the number of vehicles to spawn in case of hack failure")
	@runtimeProperty("ModSettings.step", "1")
  	@runtimeProperty("ModSettings.min", "0")
  	@runtimeProperty("ModSettings.max", "5")
	public let vehiclesToSpawnMedium:Int32 = 2;


	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","Vehicle Combat Compatibility")
	@runtimeProperty("ModSettings.displayName","Vehicles To Spawn (Hard Hack)")
	@runtimeProperty("ModSettings.description","Sets the number of vehicles to spawn in case of hack failure")
	@runtimeProperty("ModSettings.step", "1")
  	@runtimeProperty("ModSettings.min", "0")
  	@runtimeProperty("ModSettings.max", "5")
	public let vehiclesToSpawnHard:Int32 = 2;

	@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
	@runtimeProperty("ModSettings.category","Vehicle Combat Compatibility")
	@runtimeProperty("ModSettings.displayName","Vehicles To Spawn (Very Hard Hack)")
	@runtimeProperty("ModSettings.description","Sets the number of vehicles to spawn in case of hack failure")
	@runtimeProperty("ModSettings.step", "1")
  	@runtimeProperty("ModSettings.min", "0")
  	@runtimeProperty("ModSettings.max", "5")
	public let vehiclesToSpawnVeryHard:Int32 = 3;

	private func OnAttach() -> Void
	{
		//LogChannel(n"DEBUG","[VehicleSecurityRework] Scriptable System Attached");
	}

	//On System Detach
	private func OnDetach() -> Void
	{
		//LogChannel(n"DEBUG","[VehicleSecurityRework] Scriptable System Detached");
	}
}

public class AddVehicleAffiliation extends ScriptableTweak
{
	let affiliationList:ref<StringHashMap>;

	public func GenerateAffiliations() -> Void
	{
		this.affiliationList = new StringHashMap();
		for affiliation in TweakDBInterface.GetRecords(n"Affiliation")
		{
			let name:CName = TweakDBInterface.GetAffiliationRecord(affiliation.GetID()).EnumName();
			this.affiliationList.Insert(NameToString(name),affiliation);
		}
		this.affiliationList.Insert(NameToString(n"Aldecados"),TweakDBInterface.GetAffiliationRecord(t"Factions.Aldecaldos"));
	}
	
	public func ApplyAffiliationsToVehicles() -> Void
	{
		for vehicleRecord in TweakDBInterface.GetRecords(n"Vehicle")
		{
			let vehicleVisualTags:array<CName> = TweakDBInterface.GetVehicleRecord(vehicleRecord.GetID()).VisualTags();
			if ArraySize(vehicleVisualTags) > 0
			{
				//Returns the first visual tag (pray that they didn't include more than 2 tags)
				let vehicleVisualTag:CName = vehicleVisualTags[0];
				if this.affiliationList.KeyExist(NameToString(vehicleVisualTag))
				{
					let affiliationToApply:ref<Affiliation_Record> = this.affiliationList.Get(NameToString((vehicleVisualTag))) as Affiliation_Record;
					TweakDBManager.SetFlat(vehicleRecord.GetID() + t".affiliation",affiliationToApply.GetID());
				}
			}
		}
	}

	protected cb func OnApply() -> Void
	{
		this.GenerateAffiliations();
		this.ApplyAffiliationsToVehicles();
	}
}




public class GlobalInputListener
{
	let gameInstance: GameInstance;
	let customHackSystem:ref<CustomHackingSystem>;
	let vehiclePS:ref<VehicleComponentPS>;
		
	protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool 
	{
		
		//Debug function to get all action names, Usually you are looking for Choice1 (Primary Interaction) or Choice2 (Secondary Interaction : Distract/Sell in Access Points)
		LogChannel(n"DEBUG",NameToString(ListenerAction.GetName(action)));

		//Check if the vehicle can be hacked
		if(CanHackTargetedVehicle(this.gameInstance,this.vehiclePS))
		{
			//Check if button has been released
			if Equals(ListenerAction.GetName(action), n"AttemptUnlockSecurity") && ListenerAction.IsButtonJustReleased(action)
			{
				let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.gameInstance);
				this.customHackSystem = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;

				let hackToUse:TweakDBID = GetVehicleHackDBDifficulty(this.vehiclePS);
				if !IsVehicleSecurityHardened(this.vehiclePS)
				{
					this.customHackSystem.StartNewHackInstance("Unlock Vehicle",hackToUse,this.vehiclePS);
				}
			}
		}
	}
}

//Returns the tweakDBID path of the minigame used to unlock the vehicle
public func GetVehicleHackDBDifficulty(vehiclePS:ref<VehicleComponentPS>) -> TweakDBID
{
	let hackToUse:TweakDBID = t"CustomHackingSystemMinigame.UnlockVehicleEasy";
	
	let crackLockDifficulty:String = vehiclePS.GetVehicleCrackLockDifficulty();
	if(Equals(crackLockDifficulty,"MEDIUM"))
	{
		hackToUse = t"CustomHackingSystemMinigame.UnlockVehicleMedium";
	}
	if(Equals(crackLockDifficulty,"HARD"))
	{
		hackToUse = t"CustomHackingSystemMinigame.UnlockVehicleHard";
		
	}
	if(Equals(crackLockDifficulty,"IMPOSSIBLE"))
	{
		hackToUse = t"CustomHackingSystemMinigame.UnlockVehicleImpossible";
	}
	return hackToUse;
}


//Class handling the visual interaction you see when approaching the car
public class InteractionUpdate
{
	let gameInstance: GameInstance;
	let vehiclePS:ref<VehicleComponentPS>;
	public func Update() -> Void
	{
		if(CanHackTargetedVehicle(this.gameInstance,this.vehiclePS))
		{
			//let difficulty:String =	this.vehiclePS.GetVehicleCrackLockDifficulty();
			//Hardened Security (Locks the car for good)
			if (IsVehicleSecurityHardened(this.vehiclePS))
			{
				AddLockedInteraction(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-Vehicle-SecurityHardened"), n"AttemptUnlockSecurity");
				RemoveInteraction(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-UnlockVehicleHack-ProgramName"), n"AttemptUnlockSecurity");
			}
			else
			{
				AddInteraction(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-UnlockVehicleHack-ProgramName"), n"AttemptUnlockSecurity");
				RemoveInteraction(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-Vehicle-SecurityHardened"), n"AttemptUnlockSecurity");
			}
		}
		else
		{
			RemoveInteraction(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-UnlockVehicleHack-ProgramName"), n"AttemptUnlockSecurity");
			RemoveInteraction(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-Vehicle-SecurityHardened"), n"AttemptUnlockSecurity");
		}
	}
}

//Event called every frame
public class TickUpdate extends Event 
{
}

//Function used to allow target to be hacked or not
//It also retruns the vehicle component persistent state if you can hack the vehicle
public func CanHackTargetedVehicle(gameInstance:GameInstance,out ps:ref<VehicleComponentPS>) -> Bool
{
	let objectTarget:ref<GameObject> = LookAtGameObject(gameInstance, 4.0);
	if(objectTarget != null)
	{
		if (objectTarget.IsVehicle())
		{
			
			let vehiclePS: ref<VehicleComponentPS> = (objectTarget as VehicleObject).GetVehicleComponent().GetPS();
			let player = GetPlayer(gameInstance);
			let isDriving:Bool = player.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle);
			if(!vehiclePS.GetIsPlayerVehicle() 
			&& !vehiclePS.m_isVehicleHacked 
			&& !vehiclePS.GetIsDestroyed()
			&& !vehiclePS.GetIsSubmerged()
			&& !vehiclePS.IsControlledByThePlayer()
			&& !isDriving)
			{
				ps = vehiclePS;
				return true;
			}
		}
	}
	ps = null;
	return false;
}

public func IsVehicleSecurityBreached(ps:ref<VehicleComponentPS>) -> Bool
{
	return ps.m_isVehicleHacked;
}

public func IsVehicleSecurityHardened(ps:ref<VehicleComponentPS>) -> Bool
{
	return ps.isSecurityHardened;
}

public func CheckToLockSecurity(ps:ref<VehicleComponentPS>,lockDifficulty:String)
{
	ps.isSecurityHardened = ((Equals(lockDifficulty,"HARD") || Equals(lockDifficulty,"IMPOSSIBLE")) && ps.m_hackAttemptsOnVehicle >= 2);
}

//TODO (if possible) : Save Persistence using straight up game save (without GameSession)
@addField(VehicleComponentPS)
public let isSecurityHardened:Bool = false;


@addMethod(VehicleComponentPS)
public func GetVehicleCrackLockDifficulty() -> String
{
	//Get the record of the vehicle
	let record: TweakDBID = this.GetOwnerEntity().GetRecord().GetID();
	//Get the flat ("variable") that corresponds to the cracklock difficulty
	let crackLockDifficulty:Variant = TweakDBInterface.GetFlat(record + t".crackLockDifficulty");

	return ToString(crackLockDifficulty);
}

@addMethod(VehicleComponentPS)
public func GetVehicleHijackDifficulty() -> String
{
	//Get the record of the vehicle
	let record: TweakDBID = this.GetOwnerEntity().GetRecord().GetID();
	//Get the flat ("variable") that corresponds to the cracklock difficulty
	let hijackDifficulty:Variant = TweakDBInterface.GetFlat(record + t".hijackDifficulty");

	return ToString(hijackDifficulty);
}

//VehicleObject overrides

// Affiliation (Faction) override
// Why ? Because some vehicles (like Vehicle.cs_savable_yaiba_kusanagi) simply don't have the Visual Tag that defines them as their faction
// I came to an issue : some spawned vehicles that looked and belonged to Tyger Claws weren't affiliated
// So this is (another) failsafe to try get every vehicles an affiliation when needed
@addField(VehicleObject)
public let AffiliationOverride: TweakDBID = t"";
@addField(VehicleObject)
public let AffiliationOverrideString: String = "";


//Force the affiliation based on appearance name
@wrapMethod(VehicleObject)
protected cb func OnGameAttached() -> Bool 
{
	wrappedMethod();
	if Equals(this.GetRecord().Affiliation().Type(),gamedataAffiliation.Unaffiliated)
	{
		let appearanceName:String = NameToString(this.GetCurrentAppearanceName());
		
		if StrContains(appearanceName,"tyger")
		{
			this.AffiliationOverride = t"Factions.TygerClaws";
			this.AffiliationOverrideString = "Factions.TygerClaws";
			return true;
		}

		if StrContains(appearanceName,"animals")
		{
			this.AffiliationOverride = t"Factions.Animals";
			this.AffiliationOverrideString = "Factions.Animals";
			return true;
		}
		
		if StrContains(appearanceName,"6th")
		{
			this.AffiliationOverride = t"Factions.SixthStreet";
			this.AffiliationOverrideString = "Factions.SixthStreet";
			return true;
		}
		
		if StrContains(appearanceName,"arasaka")
		{
			this.AffiliationOverride = t"Factions.TygerClaws";
			this.AffiliationOverrideString = "Factions.TygerClaws";
			return true;
		}

		if StrContains(appearanceName,"maelstrom")
		{
			this.AffiliationOverride = t"Factions.Maelstrom";
			this.AffiliationOverrideString = "Factions.Maelstrom";
			return true;
		}

		if StrContains(appearanceName,"valentinos")
		{
			this.AffiliationOverride = t"Factions.Valentinos";
			this.AffiliationOverrideString = "Factions.Valentinos";
			return true;
		}

		if StrContains(appearanceName,"aldecaldos") || StrContains(appearanceName,"aldecados")
		{
			this.AffiliationOverride = t"Factions.Aldecaldos";
			this.AffiliationOverrideString = "Factions.Aldecaldos";
			return true;
		}
			
		if StrContains(appearanceName,"netwatch")
		{
			this.AffiliationOverride = t"Factions.NetWatch";
			this.AffiliationOverrideString = "Factions.NetWatch";
			return true;
		}
		
		if StrContains(appearanceName,"militech")
		{
			this.AffiliationOverride = t"Factions.Militech";
			this.AffiliationOverrideString = "Factions.Militech";
			return true;
		}

		if StrContains(appearanceName,"wraiths")
		{
			this.AffiliationOverride = t"Factions.Wraiths";
			this.AffiliationOverrideString = "Factions.Wraiths";
			return true;
		}

		if StrContains(appearanceName,"mox")
		{
			this.AffiliationOverride = t"Factions.TheMox";
			this.AffiliationOverrideString = "Factions.TheMox";
			return true;
		}
		
		//---------

		if StrContains(appearanceName,"trama_team") || StrContains(appearanceName,"trauma")
		{
			this.AffiliationOverride = t"Factions.TraumaTeam";
			this.AffiliationOverrideString = "Factions.TraumaTeam";
			return true;
		}
		
		if StrContains(appearanceName,"ncpd")
		{
			this.AffiliationOverride = t"Factions.NCPD";
			this.AffiliationOverrideString = "Factions.NCPD";
			return true;
		}
		
		if StrContains(appearanceName,"news")
		{
			this.AffiliationOverride = t"Factions.News54";
			this.AffiliationOverrideString = "Factions.News54";
			return true;
		}
		
		if StrContains(appearanceName,"kangtao")
		{
			this.AffiliationOverride = t"Factions.KangTao";
			this.AffiliationOverrideString = "Factions.KangTao";
			return true;
		}
	}
}



////////////////////////////////////////////////////////////////////////

//Player Puppet overrides

@addField(PlayerPuppet)
private let m_VehicleSecurityInputListener: ref<GlobalInputListener>;

@addField(PlayerPuppet)
private let m_VehicleSecurityInteractionUpdater: ref<InteractionUpdate>;


@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool 
{
	wrappedMethod();

	this.m_VehicleSecurityInputListener = new GlobalInputListener();
	this.m_VehicleSecurityInputListener.gameInstance = this.GetGame();

	this.m_VehicleSecurityInteractionUpdater = new InteractionUpdate();
	this.m_VehicleSecurityInteractionUpdater.gameInstance = this.GetGame();

	this.RegisterInputListener(this.m_VehicleSecurityInputListener);
	
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGame());
	let hackSystem:ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
	hackSystem.AddProgramAction(t"MinigameProgramAction.UnlockVehicle", new UnlockVehicleProgramAction());

}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool 
{
	wrappedMethod();

	this.UnregisterInputListener(this.m_VehicleSecurityInputListener);
	this.m_VehicleSecurityInputListener = null;
	this.m_VehicleSecurityInteractionUpdater = null;
}


//Begins tick update
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool 
{
	wrappedMethod();
	if !this.IsReplacer() 
	{	
		let tickEvent:ref<TickUpdate> = new TickUpdate();
		GameInstance.GetDelaySystem(this.GetGame()).DelayEventNextFrame(this, tickEvent);
	}
}

//Tick Update
@addMethod(PlayerPuppet)
protected cb func OnTickUpdate(evt: ref<TickUpdate>) -> Void 
{
	this.m_VehicleSecurityInteractionUpdater.Update();
	let tickEvent:ref<TickUpdate> = new TickUpdate();
	GameInstance.GetDelaySystem(this.GetGame()).DelayEventNextFrame(this, tickEvent);
}


////////////////////////////////////////////////////////////////////////

//VehicleComponentPS overrides

@addField(VehicleComponentPS)
public let m_isVehicleHacked:Bool;

@addField(VehicleComponentPS)
public let m_hackAttemptsOnVehicle:Int32 = 0;

@wrapMethod(VehicleComponentPS)
public final func GetValidChoices(objectActionRecords: array<wref<ObjectAction_Record>>, 
context: GetActionsContext, objectActionsCallbackController: wref<gameObjectActionsCallbackController>, 
out choices: array<InteractionChoice>, isAutoRefresh: Bool) -> Void 
{
	//TODO: remove it (?)
	if (this.GetIsPlayerVehicle() || this.GetIsStolen() || this.IsMarkedAsQuest())
	{
		this.UnlockHackedVehicle();
	}
	wrappedMethod(objectActionRecords,context,objectActionsCallbackController,choices,isAutoRefresh);
}

@addMethod(VehicleComponentPS)
public final func UnlockHackedVehicle() -> Void
{
	this.m_isVehicleHacked = true;
	this.SetIsStolen(true);
}

@addMethod(VehicleComponentPS)
public final func UnlockHackedVehicleNoSave() -> Void
{
	this.m_isVehicleHacked = true;
}

//we probably don't want to hack quest marked vehicles (but still get quickhacks for them)
@wrapMethod(VehicleComponentPS)
public func SetIsMarkedAsQuest(isQuest: Bool) -> Void
{
	if isQuest
	{
		this.UnlockHackedVehicle();
	}
	wrappedMethod(isQuest);
}

//Fixes an issue where quest-marked vehicles wouldn't be unlocked
//Might still not work on some vehicles,but who knows...
@wrapMethod(VehicleComponentPS)
public final func SetHasStateBeenModifiedByQuest(set: Bool) -> Void 
{
	if set
	{
		this.UnlockHackedVehicle();
	}
	wrappedMethod(set);
}



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

	//Block hacks if it is player owned
	if this.GetIsPlayerVehicle()
	{
		ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, LocKeyToString(n"VehicleSecurityRework-Quickhack-PlayerOwnedPanelInfo"));	
	}

	this.FinalizeGetQuickHackActions(actions, context);
}

@wrapMethod(VehicleComponentPS)
protected func GameAttached() -> Void 
{
	wrappedMethod();

	this.m_canHandleAdvancedInteraction = true;
	this.m_forceResolveStateOnAttach = true;
	this.m_exposeQuickHacks = true;
	this.InitializeQuickHackVulnerabilities();
	ArrayClear(this.m_quickHackVulnerabilties);

	this.AddQuickHackVulnerability(t"DeviceAction.RemoteSecurityBreach");
	this.AddQuickHackVulnerability(t"DeviceAction.ExplodeVehicle");
	this.AddQuickHackVulnerability(t"DeviceAction.MalfunctionClassHack");
	this.AddQuickHackVulnerability(t"DeviceAction.ForceBrakes");
	
	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let params:ref<VehicleSecurityRework> = container.Get(n"VehicleSecurityRework.Base.VehicleSecurityRework") as VehicleSecurityRework;

	if (this.GetIsPlayerVehicle() || this.GetIsStolen() || this.IsMarkedAsQuest() || params.forceSecurityUnlock)
	{
		this.UnlockHackedVehicle();
	}
	this.RefreshSkillchecks();
}

//Adds the vulnerabilities & vehicle faction to the scanner
@wrapMethod(VehicleObject)
public const func CompileScannerChunks() -> Bool {
	let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);

	//let quickhackActionsCompletion:array<wref<ObjectActionEffect_Record>>;
	let vulnerabilityChunk:ref<ScannerVulnerabilities> = new ScannerVulnerabilities();
	if !this.m_vehicleComponent.GetPS().GetIsPlayerVehicle()
	{
		for vulnerabilityTDBID in this.m_vehicleComponent.GetPS().m_quickHackVulnerabilties
		{
			let vulRecord:ref<ObjectAction_Record> = TweakDBInterface.GetObjectActionRecord(vulnerabilityTDBID);
			let isVulnerabilityActive: Bool = IsVehicleSecurityBreached(this.m_vehicleComponent.GetPS());
			if(Equals(t"DeviceAction.RemoteSecurityBreach",vulnerabilityTDBID))
			{
				if(!IsVehicleSecurityHardened(this.m_vehicleComponent.GetPS()) && !IsVehicleSecurityBreached(this.m_vehicleComponent.GetPS()))
				{
					isVulnerabilityActive = true;
				}
				else
				{
					isVulnerabilityActive = false;
				}
			}
			
			if this.GetVehicleComponent().GetPS().GetIsDestroyed() || this.GetVehicleComponent().GetPS().GetIsSubmerged()
			{
				isVulnerabilityActive = false;
			}

			let vulnerability:Vulnerability = new Vulnerability(vulRecord.ObjectActionUI().Caption(),vulRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID(),isVulnerabilityActive);
			vulnerabilityChunk.PushBack(vulnerability);
		}
	}
	scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVulnerabilities, ToVariant(vulnerabilityChunk));

	//Vehicle (possible) Affiliation
	//Used in pair with Vehicle Combat to force response of a faction if a vehicle is attempted to be stolen
	let faction:ref<ScannerFaction> = new ScannerFaction();
	let factionName:String = LocKeyToString(this.GetRecord().Affiliation().LocalizedName());
	if this.AffiliationOverride != t""
	{
		factionName = LocKeyToString(TweakDBInterface.GetAffiliationRecord(this.AffiliationOverride).LocalizedName());
	}
	else 
	{
		if(Equals(this.GetRecord().Affiliation().GetID(),t"Factions.Unaffiliated"))
		{
			// Primary Key : 4438 - "No Affiliation"
			// Secondary Key : "Story-base-gameplay-static_data-database-factions-factions-Unaffiliated_localizedName" - "No Affiliation"
			factionName = LocKeyToString(n"Story-base-gameplay-static_data-database-factions-factions-Unaffiliated_localizedName");
		}
		else
		{
			factionName = LocKeyToString(this.GetRecord().Affiliation().LocalizedName());
		}
	}
	faction.Set(factionName);
	scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerFaction, ToVariant(faction),!this.m_vehicleComponent.GetPS().m_isVehicleHacked);

	return wrappedMethod();
}

//Remove all actions if the vehicle is not hacked yet
@replaceMethod(VehicleComponentPS)
public final func DetermineActionsToPush(interaction: ref<InteractionComponent>, context: VehicleActionsContext, objectActionsCallbackController: wref<gameObjectActionsCallbackController>, isAutoRefresh: Bool) -> Void 
{
	let actionRecords: array<wref<ObjectAction_Record>>;
	let actionToExtractChoices: ref<ScriptableDeviceAction>;
	let actions: array<ref<DeviceAction>>;
	let choiceTDBname: String;
	let choices: array<InteractionChoice>;
	let door: EVehicleDoor;
	let doorLayer: CName;
	let i: Int32;
	let vehDataPackage: wref<VehicleDataPackage_Record>;
	VehicleComponent.GetVehicleDataPackage(this.GetGameInstance(), this.GetOwnerEntity(), vehDataPackage);

//Should not be needed since it's on Init now 	
	if this.GetIsDestroyed() 
	{
		this.PushActionsToInteractionComponent(interaction, choices, context);
		return;
	}

	if this.IsDoorLayer(context.interactionLayerTag) 
	{
		doorLayer = context.interactionLayerTag;
		this.GetVehicleDoorEnum(door, doorLayer);
		if Equals(this.GetDoorInteractionState(door), VehicleDoorInteractionState.Disabled)
		{
			return;
		}
		if Equals(this.GetDoorInteractionState(door), VehicleDoorInteractionState.Reserved)
		{
			this.PushActionsToInteractionComponent(interaction, choices, context);
			//return;
		}
		if Equals(this.GetDoorInteractionState(door), VehicleDoorInteractionState.Available)
		{
			//Remove here
			if (!this.m_isVehicleHacked)
			{
				return;
			}
			this.PushActionsToInteractionComponent(interaction, choices, context);
		}
		if Equals(this.GetDoorInteractionState(door), VehicleDoorInteractionState.QuestLocked)
		{
			this.GetQuestLockedActions(actions, context);
		}
	}
	if Equals(context.interactionLayerTag, n"trunk")
	{
		this.GetTrunkActions(actions, context);
	}
	if Equals(context.interactionLayerTag, n"hood")
	{
		this.GetHoodActions(actions, context);
	}
	if Equals(context.interactionLayerTag, n"Mount") 
	{
		return;
	}
	context.requestType = gamedeviceRequestType.Direct;
	this.GetOwnerEntity().GetRecord().ObjectActions(actionRecords);
	
	//this removes the interaction for demo & engineering  actions, but it just won't put the default mount action in game, wtf
	//Needs a fix or a removal from the tweakdb but not tested yet
	let actionsToRemove:array<wref<ObjectAction_Record>>;
	
	while i < ArraySize(actionRecords) 
	{
		let actionName :CName= actionRecords[i].ActionName();
		switch actionName {
            case n"VehicleHijack":
			//ArrayPush(actionsToRemove,actionRecords[i]);
              break;
            case n"VehicleCrackLock":
			ArrayPush(actionsToRemove,actionRecords[i]);
			break;
          };
		i+=1;
	}
	i = 0;
	while i < ArraySize(actionsToRemove) 
	{
		ArrayRemove(actionRecords,actionsToRemove[i]);
		i+=1;
	}

	i=0
	;

	this.GetValidChoices(actionRecords, this.ChangeToActionContext(context), objectActionsCallbackController, choices, isAutoRefresh);
	this.FinalizeGetActions(actions);
	i = 0;
	while i < ArraySize(actions)
	{
		actionToExtractChoices = actions[i] as ScriptableDeviceAction;
		(actions[i] as ScriptableDeviceAction).SetExecutor(context.processInitiatorObject);
		//Set all actions as locked (or red at least)
		if !this.m_isVehicleHacked
		{
			//Set action as red (locked)
			ChoiceTypeWrapper.SetType(actionToExtractChoices.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
			//+ remove actions
			actions[i].actionName = n"";
			(actions[i] as ScriptableDeviceAction).SetInactive();
			(actions[i] as ScriptableDeviceAction).SetIllegal(true);
		}
		ArrayPush(choices, actionToExtractChoices.GetInteractionChoice());
		i += 1;
	}
	if (!isAutoRefresh)
	{
		i = 0;
		while i < ArraySize(choices) 
		{
			choiceTDBname = choices[i].choiceMetaData.tweakDBName;
			switch choiceTDBname 
			{
		  		case "ActionDemolition":
				this.ProcessVehicleHijackTutorial();
				break;
		  		case "ActionEngineering":
				this.ProcessVehicleCrackLockTutorial();
				break;
			}
			i += 1;
	 	}
	}
	this.PushActionsToInteractionComponent(interaction, choices, context);
}