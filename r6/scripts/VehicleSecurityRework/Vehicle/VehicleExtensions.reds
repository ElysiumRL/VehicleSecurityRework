module VehicleSecurityRework.Vehicles
import VehicleSecurityRework.Settings.*

import InteractionExtensions.*
import TargetingExtensions.*


//Requires CustomHackingSystem
@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*
@if(ModuleExists("HackingExtensions.Programs"))
import HackingExtensions.Programs.*
@if(ModuleExists("CustomHackingSystem.Tools"))
import CustomHackingSystem.Tools.*

// Small tuple used to store the affiliation data in the CName dictionary (in the class VehicleSecurityRework)
// This will then be used to fill the affiliation data to the vehicles when being created
public class VehicleAffiliationTuple extends IScriptable
{
    public let affiliationTweakDBID : TweakDBID;
    public let affiliationString: String;

    public static func Build(tweakDBID : TweakDBID,string : String) -> ref<VehicleAffiliationTuple>
    {
        let instance: ref<VehicleAffiliationTuple> = new VehicleAffiliationTuple();
        instance.affiliationTweakDBID = tweakDBID;
        instance.affiliationString = string;
        return instance;
    }
}

//TweakXL : Add (as much as possible) factions to all vehicle records
public class AddVehicleAffiliation extends ScriptableTweak
{
    //Strings of all factions in the game
    let affiliationList: ref<CNameIScriptableDictionary>;

    //Finds all existing Affiliations (factions) and store their names (as String)
    public func GenerateAffiliations() -> Void
    {
        if(!IsDefined(this.affiliationList))
        {
            this.affiliationList = new CNameIScriptableDictionary();
        }
        //Get all factions
        for affiliation in TweakDBInterface.GetRecords(n"Affiliation")
        {
            //Get their names
            let name: CName = TweakDBInterface.GetAffiliationRecord(affiliation.GetID()).EnumName();
            //Insert their names to the "dictionary"
            this.affiliationList.Insert(name,affiliation);
        }
        //Extra insert because CDPR made some spelling mistakes on some records
        this.affiliationList.Insert(n"Aldecados",TweakDBInterface.GetAffiliationRecord(t"Factions.Aldecaldos"));
    }
    
    public func ApplyAffiliationsToVehicles() -> Void
    {
        //Get all Vehicle records
        for vehicleRecord in TweakDBInterface.GetRecords(n"Vehicle")
        {
            //Find the "VisualTags", this flat often stores faction as CNames
            let vehicleVisualTags:array<CName> = TweakDBInterface.GetVehicleRecord(vehicleRecord.GetID()).VisualTags();
            if ArraySize(vehicleVisualTags) > 0
            {
                //Returns the first visual tag (hope that they didn't include more than 2 tags)
                let vehicleVisualTag:CName = vehicleVisualTags[0];
                
                //Look if the visual tag matches one of the factions
                if (this.affiliationList.KeyExists(vehicleVisualTag))
                {
                    //Apply faction to vehicle
                    let affiliationToApply:ref<Affiliation_Record> = this.affiliationList.Get(vehicleVisualTag) as Affiliation_Record;
                    TweakDBManager.SetFlat(vehicleRecord.GetID() + t".affiliation",affiliationToApply.GetID());
                }
            }
        }
    }

    //Apply TweakDB modifications
    protected cb func OnApply() -> Void
    {
        this.GenerateAffiliations();
        this.ApplyAffiliationsToVehicles();
    }
}


//Returns true if the vehicle can be hacked
//It also retruns the vehicle PS if you can hack the vehicle (or null if vehicle can't be hacked)
public func CanHackTargetedVehicle(gameInstance:GameInstance,out ps:ref<VehicleComponentPS>) -> Bool
{
    let objectTarget: ref<GameObject> = LookAtGameObject(gameInstance, 4.0);
    if(objectTarget != null)
    {
        if (objectTarget.IsVehicle())
        {
            let vehiclePS: ref<VehicleComponentPS> = (objectTarget as VehicleObject).GetVehicleComponent().GetPS();
            let player = GetPlayer(gameInstance);
            let isDriving : Bool = player.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle);
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

@addField(VehicleComponentPS)
protected persistent let m_puncturedTires: array<Uint32>;

@addField(VehicleComponentPS)
protected persistent let isSecurityHardened: Bool = false;

@addField(VehicleComponentPS)
protected persistent let m_isVehicleHacked: Bool = false;

@addField(VehicleComponentPS)
protected persistent let m_hackAttemptsOnVehicle: Int32 = 0;

@addField(VehicleComponentPS)
public let quickhackForceBrakesExecuted:Bool = false;

@addField(VehicleComponentPS)
public let quickhackRecklessDrivingExecuted:Bool = false;

@addField(VehicleComponentPS)
public let CanTriggerRecklessDriving:Bool = true;

@addField(VehicleComponentPS)
public let VehicleSecurityReworkSingleton: ref<VehicleSecurityRework>;

@addField(VehicleObject)
public let AffiliationOverride: TweakDBID = t"";

@addField(VehicleObject)
public let AffiliationOverrideString: String = "";

@addField(VehicleObject)
public let VehicleSecurityReworkSingleton: ref<VehicleSecurityRework>;


//Returns the tweakDBID path of the minigame used to unlock the vehicle
@addMethod(VehicleComponentPS)
public func GetVehicleHackDBDifficulty() -> TweakDBID
{	
    let crackLockDifficulty : String = this.GetVehicleCrackLockDifficulty();

    if(Equals(crackLockDifficulty, "MEDIUM"))
    {
        return t"CustomHackingSystemMinigame.UnlockVehicleMedium";
    }
    if(Equals(crackLockDifficulty, "HARD"))
    {
        return t"CustomHackingSystemMinigame.UnlockVehicleHard";
    }
    if(Equals(crackLockDifficulty, "IMPOSSIBLE"))
    {
        return t"CustomHackingSystemMinigame.UnlockVehicleImpossible";
    }

    return t"CustomHackingSystemMinigame.UnlockVehicleEasy";
}

@addMethod(VehicleObject)
public func GetPreventionResponseDifficulty() -> Int32
{	
    let crackLockDifficulty : String = this.GetVehiclePS().GetVehicleCrackLockDifficulty();

    if(Equals(crackLockDifficulty, "MEDIUM"))
    {
        return this.VehicleSecurityReworkSingleton.basePoliceStarLevelMedium;
    }
    if(Equals(crackLockDifficulty, "HARD"))
    {
        return this.VehicleSecurityReworkSingleton.basePoliceStarLevelHard;
    }
    if(Equals(crackLockDifficulty, "IMPOSSIBLE"))
    {
        return this.VehicleSecurityReworkSingleton.basePoliceStarLevelVeryHard;
    }

    return this.VehicleSecurityReworkSingleton.basePoliceStarLevelEasy;
}

@addMethod(VehicleComponentPS)
public func IsVehicleSecurityBreached() -> Bool
{
    return this.m_isVehicleHacked;
}

@addMethod(VehicleComponentPS)
public func IsVehicleSecurityHardened() -> Bool
{
    return this.isSecurityHardened;
}

@addMethod(VehicleComponentPS)
public func GetCurrentHackAttempts() -> Int32
{
    return this.m_hackAttemptsOnVehicle;
}

@addMethod(VehicleComponentPS)
public func TryToForceVehicleSecurity(lockDifficulty : String)
{
    this.isSecurityHardened = ((Equals(lockDifficulty,"HARD") || Equals(lockDifficulty,"IMPOSSIBLE")) && this.m_hackAttemptsOnVehicle >= 2);
}

//Returns the difficulty ("EASY","MEDIUM","HARD","IMPOSSIBLE") from the Cracklock flat in the TweakDB Record
@addMethod(VehicleComponentPS)
public func GetVehicleCrackLockDifficulty() -> String
{
    //Get the record of the vehicle
    let record: TweakDBID = this.GetOwnerEntity().GetRecord().GetID();
    //Get the flat ("variable") that corresponds to the cracklock difficulty
    let crackLockDifficulty:Variant = TweakDBInterface.GetFlat(record + t".crackLockDifficulty");

    return ToString(crackLockDifficulty);
}

//Returns the difficulty ("EASY","MEDIUM","HARD","IMPOSSIBLE") from the Hijack flat in the TweakDB Record
@addMethod(VehicleComponentPS)
public func GetVehicleHijackDifficulty() -> String
{
    //Get the record of the vehicle
    let record: TweakDBID = this.GetOwnerEntity().GetRecord().GetID();
    //Get the flat ("variable") that corresponds to the hijack difficulty
    let hijackDifficulty:Variant = TweakDBInterface.GetFlat(record + t".hijackDifficulty");

    return ToString(hijackDifficulty);
}

//Unlocks the vehicle (also marks it as stolen)
@addMethod(VehicleComponentPS)
public final func UnlockHackedVehicle() -> Void
{
    this.m_isVehicleHacked = true;
    this.SetIsStolen(true);
}

//Force unlock the vehicle (without flagging it as stolen)
@addMethod(VehicleComponentPS)
public final func UnlockHackedVehicleNoSave() -> Void
{
    this.m_isVehicleHacked = true;
}

//we probably don't want to hack quest marked vehicles (but still get quickhacks for them)
@wrapMethod(VehicleComponentPS)
public func SetIsMarkedAsQuest(isQuest: Bool) -> Void
{
    if (isQuest)
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
    if (set)
    {
        this.UnlockHackedVehicle();
    }
    wrappedMethod(set);
}

//Called when the vehicle is spawned in the world
@wrapMethod(VehicleComponentPS)
protected func GameAttached() -> Void 
{
    wrappedMethod();

    //Add quickhack vunerabilities (in the details scanner panel)
    //This is cosmetic, it doesn't influence available quichacks
    this.InitializeQuickHackVulnerabilities();
    ArrayClear(this.m_quickHackVulnerabilties);

    this.AddQuickHackVulnerability(t"DeviceAction.RemoteSecurityBreach");
    this.AddQuickHackVulnerability(t"DeviceAction.ExplodeVehicle");
    this.AddQuickHackVulnerability(t"DeviceAction.MalfunctionClassHack");
    this.AddQuickHackVulnerability(t"DeviceAction.ForceBrakes");
    this.AddQuickHackVulnerability(t"DeviceAction.RecklessDriving");

    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    this.VehicleSecurityReworkSingleton = container.Get(n"VehicleSecurityRework.Settings.VehicleSecurityRework") as VehicleSecurityRework;
    //Ignore the hack part if it's not needed (or already hacked previously)
    if 
    (
        this.GetIsPlayerVehicle() 
        || this.GetIsStolen() 
        || this.IsMarkedAsQuest() 
        || this.m_isVehicleHacked
        || this.VehicleSecurityReworkSingleton.forceSecurityUnlock)
    {
        this.UnlockHackedVehicle();
    }
}


@wrapMethod(VehicleObject)
protected cb func OnGameAttached() -> Bool 
{
    wrappedMethod();

    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGame());
    this.VehicleSecurityReworkSingleton = container.Get(n"VehicleSecurityRework.Settings.VehicleSecurityRework") as VehicleSecurityRework;

    //Force the affiliation based on appearance name
    //So sadly since tweakDB editing isn't enough (because some vehicles with the faction appearance aren't registered)
    //I have to search inside the appearance name if it's tied to a faction
    //Since the majority of the vehicles aren't tied to a faction (and because theres a lot of string search), it's a bit not optimized...
    if Equals(this.GetRecord().Affiliation().Type(),gamedataAffiliation.Unaffiliated)
    {
        this.SetVehicleAffiliationFromAppearance(this.GetCurrentAppearanceName());
    }
    return true;
}

@addMethod(VehicleObject)
public func SetVehicleAffiliationFromAppearance(appearanceName : CName) -> Void
{
    let appearanceNameAsString: String = NameToString(appearanceName);
    let allDefinedKeys: array<String> = this.VehicleSecurityReworkSingleton.vehicleAffiliations.GetKeys();

    let i:Int32 = 0;
    while(i < ArraySize(allDefinedKeys))
    {
        if(StrContains(appearanceNameAsString,allDefinedKeys[i]))
        {
            let affiliationData : ref<VehicleAffiliationTuple> = (this.VehicleSecurityReworkSingleton.vehicleAffiliations.Get(allDefinedKeys[i])) as VehicleAffiliationTuple;
            if(IsDefined(affiliationData))
            {
                this.AffiliationOverride = affiliationData.affiliationTweakDBID;
                this.AffiliationOverrideString = affiliationData.affiliationString;
                return;
            }
        }
        i += 1;
    }
}



//Add the vulnerabilities & vehicle faction to the scanner
@wrapMethod(VehicleObject)
public const func CompileScannerChunks() -> Bool 
{
    //Remove non-vehicle objects (it shouldn't be executed but who knows)
    if(!(this == (this as CarObject) || this == (this as BikeObject)))
    {
        return wrappedMethod();
    }
    //Add previously created vulnerabilities to the vehicle
    //Again, it's purely cosmetic, it doesn't change anything related to gameplay

    let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);
    let vulnerabilityChunk:ref<ScannerVulnerabilities> = new ScannerVulnerabilities();
    let vehiclePS:ref<VehicleComponentPS> = this.GetVehicleComponent().GetPS();
    if !vehiclePS.GetIsPlayerVehicle()
    {
        for vulnerabilityTDBID in this.m_vehicleComponent.GetPS().m_quickHackVulnerabilties
        {
            let vulRecord:ref<ObjectAction_Record> = TweakDBInterface.GetObjectActionRecord(vulnerabilityTDBID);
            let isVulnerabilityActive: Bool = vehiclePS.IsVehicleSecurityBreached();
            if (Equals(t"DeviceAction.RemoteSecurityBreach",vulnerabilityTDBID))
            {
                if(!vehiclePS.IsVehicleSecurityHardened() 
                && !vehiclePS.IsVehicleSecurityBreached())
                {
                    isVulnerabilityActive = true;
                }
                else
                {
                    isVulnerabilityActive = false;
                }
            }

            if (Equals(t"DeviceAction.RecklessDriving",vulnerabilityTDBID))
            {
                if(!vehiclePS.IsVehicleSecurityHardened() 
                && vehiclePS.IsVehicleSecurityBreached()
                && vehiclePS.CanTriggerRecklessDriving)
                {
                    isVulnerabilityActive = true;
                }
                else
                {
                    isVulnerabilityActive = false;
                }
            }

            if (vehiclePS.GetIsDestroyed() || vehiclePS.GetIsSubmerged())
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
    if (this.AffiliationOverride != t"")
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
    
    //if this.GetIsDestroyed() 
    //{
    //    this.PushActionsToInteractionComponent(interaction, choices, context);
    //    return;
    //}

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
    let actionsToRemove : array<wref<ObjectAction_Record>>;
    
    while i < ArraySize(actionRecords) 
    {
        let actionName : CName = actionRecords[i].ActionName();
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
        i += 1;
    }
    i = 0;

    this.GetValidChoices(actionRecords, this.ChangeToActionContext(context), objectActionsCallbackController, choices, isAutoRefresh);
    this.FinalizeGetActions(actions);
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
            //(actions[i] as ScriptableDeviceAction).SetIllegal(true);
        }
        ArrayPush(choices, actionToExtractChoices.GetInteractionChoice());
        i += 1;
    }
    i = 0;
    if (!isAutoRefresh)
    {
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
    i = 0;

    this.PushActionsToInteractionComponent(interaction, choices, context);
}

@replaceMethod(VehicleObject)
public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData>
{
    if this.IsDestroyed() || this.IsPlayerMounted()
	{
    	return null;
    }

    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked()
	{
    	return null;
    }

    let highlight: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlight.outlineType = this.GetCurrentOutline(); 
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();

	if Equals(highlight.outlineType, EFocusOutlineType.INVALID)
	{
    	return null;
    }
    if Equals(highlight.outlineType, EFocusOutlineType.QUEST)
	{
    	highlight.highlightType = EFocusForcedHighlightType.QUEST;
    }
	else
	{
    	if (Equals(highlight.outlineType, EFocusOutlineType.HACKABLE))
		{
    		highlight.highlightType = EFocusForcedHighlightType.HACKABLE;
    	}
		if (Equals(highlight.outlineType, EFocusOutlineType.HOSTILE))
		{
    		highlight.highlightType = EFocusForcedHighlightType.HOSTILE;
    	}
    }
    if (highlight != null)
	{
    	if (this.IsNetrunner())
		{
    		highlight.patternType = VisionModePatternType.Netrunner;
    	}
		else
		{
    		highlight.patternType = VisionModePatternType.Default;
    	}
    }

    return highlight;
}

@replaceMethod(VehicleObject)
public const func GetCurrentOutline() -> EFocusOutlineType
{
	let outlineType: EFocusOutlineType;

	if (this.IsDestroyed())
	{
		return EFocusOutlineType.INVALID;
	}
	if (this.IsQuest())
	{
		outlineType = EFocusOutlineType.QUEST;
	}
	else
	{
		if (this.VehicleSecurityReworkSingleton.enableHighlights)
		{
			if (this.GetVehiclePS().isSecurityHardened || !(IsDefined(this as CarObject) || IsDefined(this as BikeObject)) || this.GetVehiclePS().m_playerVehicle)
			{
				//Hostile = red highlight
				outlineType = EFocusOutlineType.HOSTILE;
			}
			else
			{
				//Hackable = green highlight
				outlineType = EFocusOutlineType.HACKABLE;
			}
		}
		else
		{
			outlineType = EFocusOutlineType.INVALID;
		}
	}
	return outlineType;
}

@addMethod(WheeledObject)
public const func GetWheelCount() -> Uint32
{
    let wheelSetup : ref<VehicleWheelDrivingSetup_Record> = TweakDBInterface.GetVehicleRecord(this.GetRecordID()).VehDriveModelData().WheelSetup();
    
    if(wheelSetup.IsExactlyA(n"gamedataVehicleWheelDrivingSetup_2_Record"))
    {
        return 2u;
    }

    if(wheelSetup.IsExactlyA(n"gamedataVehicleWheelDrivingSetup_4_Record"))
    {
        return 4u;
    }

    // This should not happen
    // (unless CDPR adds a "6/8/12" wheel setup, but considering how they already handle vehicles with more than 4 wheels, it's not going to happen anytime soon)
    return 0u;
}

@wrapMethod(VehicleComponent)
protected cb func OnToggleBrokenTireEvent(evt: ref<VehicleToggleBrokenTireEvent>) -> Bool
{
    if (evt.toggle)
    {
        if(!ArrayContains(this.GetPS().m_puncturedTires,evt.tireIndex))
        {
            ArrayPush(this.GetPS().m_puncturedTires, evt.tireIndex);
        }
    }
    else
    {
        if (ArrayContains(this.GetPS().m_puncturedTires, evt.tireIndex))
        {
            ArrayRemove(this.GetPS().m_puncturedTires, evt.tireIndex);
        }
    }
    wrappedMethod(evt);
  }

@addMethod(WheeledObject)
public func IsTirePunctured(tireIndex : Uint32) -> Bool
{
    return ArrayContains(this.GetVehiclePS().m_puncturedTires,tireIndex);
}

@addMethod(WheeledObject)
public func AreAllTiresPunctured() -> Bool
{
    return Cast<Uint32>(ArraySize(this.GetVehiclePS().m_puncturedTires)) == this.GetWheelCount();
}
