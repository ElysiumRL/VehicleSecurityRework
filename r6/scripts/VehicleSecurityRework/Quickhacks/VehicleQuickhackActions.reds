module VehicleSecurityRework.Base
import VehicleSecurityRework.Hack.*
import VehicleSecurityRework.Vehicles.*
import VehicleSecurityRework.Settings.*


@if(ModuleExists("LetThereBeFlight"))
import LetThereBeFlight.*

@if(ModuleExists("LetThereBeFlight.Compatibility"))
import LetThereBeFlight.Compatibility.*

//Get all quickhacks for the vehicle - VehicleSecurityRework version
//@if(!ModuleExists("LetThereBeFlight"))
//@replaceMethod(VehicleComponentPS)
//protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void 
//{
//    let action: ref<ScriptableDeviceAction>;
//    
//    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
//    let params:ref<VehicleSecurityRework> = container.Get(n"VehicleSecurityRework.Settings.VehicleSecurityRework") as VehicleSecurityRework;
//
//    //Remote Breach
//    action = this.ActionUnlockSecurity(this.GetVehicleHackDBDifficulty());
//    if (this.IsVehicleSecurityHardened())
//    {
//        action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
//    }
//    else 
//    {
//        if (this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
//        }
//    }
//    ArrayPush(actions,action);
//    
//    //Auto Hack
//    action = this.ActionVehicleAutoHack();
//    if (this.IsVehicleSecurityHardened())
//    {
//        action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
//    }
//    else 
//    {
//        if (this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
//        }
//    }
//    ArrayPush(actions,action);
//
//    //Explode
//    if (params.explodeHack)
//    {
//        action = this.ActionOverloadVehicle();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        ArrayPush(actions,action);
//    }
//
//    //Distract
//    if(params.distractHack)
//    {
//        action = this.ActionVehicleDistraction();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if (this.m_distractExecuted)
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }	
//        ArrayPush(actions,action);
//    }
//
//    //Force Brakes
//    if(params.forceBrakesHack)
//    {
//        action = this.ActionVehicleForceBrakes();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if (this.quickhackForceBrakesExecuted)
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }
//        ArrayPush(actions,action);
//    }
//
//    //Reckless Driving
//    if(params.recklessDrivingHack)
//    {
//        action = this.ActionVehicleRecklessDriving();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }
//        if (!this.CanTriggerRecklessDriving)
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-RecklessDrivingDisabled"));
//        }
//        ArrayPush(actions,action);
//    }
//
//
//    if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
//    {
//        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7004");	
//    }	
//
//    //Remove hacks if it is not a vehicle or a bike (fix for Quest AVs still being hackable)
//    if (!(IsDefined(this.GetOwnerEntity() as CarObject) || IsDefined(this.GetOwnerEntity() as BikeObject)))
//    {
//        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
//    }
//
//
//    //Block hacks if it is player owned
//    if (this.GetIsPlayerVehicle())
//    {
//        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, LocKeyToString(n"VehicleSecurityRework-Quickhack-PlayerOwnedPanelInfo"));	
//    }
//
//    this.FinalizeGetQuickHackActions(actions, context);
//}


//Get all quickhacks for the vehicle - VehicleSecurityRework x LTBF (hybrid) version
//@if(ModuleExists("LetThereBeFlight"))
//@replaceMethod(VehicleComponentPS)
//protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void 
//{
//    let action: ref<ScriptableDeviceAction>;
//    
//    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
//    let params:ref<VehicleSecurityRework> = container.Get(n"VehicleSecurityRework.Settings.VehicleSecurityRework") as VehicleSecurityRework;
//
//
//    //Remote Breach
//    action = this.ActionUnlockSecurity(this.GetVehicleHackDBDifficulty());
//    if (this.IsVehicleSecurityHardened())
//    {
//        action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
//    }
//    else 
//    {
//        if (this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
//        }
//    }
//    ArrayPush(actions,action);
//    
//    //Auto Hack
//    action = this.ActionVehicleAutoHack();
//    if (this.IsVehicleSecurityHardened())
//    {
//        action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
//    }
//    else 
//    {
//        if (this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
//        }
//    }
//    ArrayPush(actions,action);
//
//    //Explode
//    if(params.explodeHack)
//    {
//        action = this.ActionOverloadVehicle();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        ArrayPush(actions,action);
//    }
//
//    //Distract
//    if(params.distractHack)
//    {
//        action = this.ActionVehicleDistraction();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if (this.m_distractExecuted)
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }	
//        ArrayPush(actions,action);
//    }
//
//    //Force Brakes
//    if(params.forceBrakesHack)
//    {
//        action = this.ActionVehicleForceBrakes();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if (this.quickhackForceBrakesExecuted)
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }
//        ArrayPush(actions,action);
//    }
//
//    //Reckless Driving
//    if (params.recklessDrivingHack)
//    {
//        action = this.ActionVehicleRecklessDriving();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if (!this.CanTriggerRecklessDriving)
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-RecklessDrivingDisabled"));
//        }    
//        if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }
//        ArrayPush(actions,action);
//    }
//
//    /* Let There Be Flight Quickhacks */
//
//    //Toggle FlightMode
//    if(params.toggleFlightHack)
//    {
//        if (this.GetOwnerEntity().m_flightComponent.active)
//        {
//            action = this.ActionVehicleToggleFlightOFF();
//        }
//        else
//        {
//            action = this.ActionVehicleToggleFlightON();
//        }
//
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }
//        ArrayPush(actions,action);
//    }
//
//    //Toggle Gravity
//    if(params.toggleGravityHack)
//    {
//        if (this.GetOwnerEntity().HasGravity())
//        {
//            action = this.ActionVehicleToggleGravityOFF();
//        }
//        else
//        {
//            action = this.ActionVehicleToggleGravityON();
//        }
//
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        if this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted
//        {
//            action.SetInactiveWithReason(false, "LocKey#7004");	
//        }
//        ArrayPush(actions,action);
//    }
//
//    //Liftoff
//    if(params.liftoffHack)
//    {
//        action = this.ActionVehicleLiftoff();
//        if (!this.IsVehicleSecurityBreached())
//        {
//            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//        }
//        ArrayPush(actions,action);
//    }
//    /* Let There Be Flight Quickhacks End */
//
//
//    if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
//    {
//        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7004");	
//    }
//
//    //Remove hacks if it is not a vehicle or a bike (fix for Quest AVs still being hackable)
//    if(!(IsDefined(this.GetOwnerEntity() as CarObject) || IsDefined(this.GetOwnerEntity() as BikeObject)))
//    {
//        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
//    }
//    //Block hacks if it is player owned
//    if this.GetIsPlayerVehicle()
//    {
//        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, LocKeyToString(n"VehicleSecurityRework-Quickhack-PlayerOwnedPanelInfo"));	
//    }
//
//    this.FinalizeGetQuickHackActions(actions, context);
//}


@replaceMethod(VehicleComponentPS)
protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, const context: script_ref<GetActionsContext>) -> Void
{
	let areVehicleQuickhacksAvailable: Bool;
	let controllerPS: ref<vehicleControllerPS>;
	let currentAction: ref<ScriptableDeviceAction>;
	let playerMountedVehicle: wref<VehicleObject>;
	let playerPuppet: ref<PlayerPuppet>;
	let vehicleState: vehicleEState;
	let isValidRange: Bool = false;
	let isVehicleRemoteControlled: Bool = this.GetOwnerEntity().IsVehicleRemoteControlled();
	let maxDistance: Float = TweakDBInterface.GetFloat(t"player.vehicleQuickHacks.maxRange", 0.00);

	let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
	let params:ref<VehicleSecurityRework> = container.Get(n"VehicleSecurityRework.Settings.VehicleSecurityRework") as VehicleSecurityRework;

	if this.GetOwnerEntity().GetDistanceToPlayerSquared() < maxDistance * maxDistance
	{
		isValidRange = true;
	}
	playerPuppet = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;

	if PlayerDevelopmentSystem.GetData(playerPuppet).IsNewPerkBoughtAnyLevel(gamedataNewPerkType.Intelligence_Right_Milestone_1)
	{
		controllerPS = this.GetVehicleControllerPS();
		vehicleState = controllerPS.GetState();
		areVehicleQuickhacksAvailable = (this.GetOwnerEntity().IsHackable() && !StatusEffectSystem.ObjectHasStatusEffect(playerPuppet, t"GameplayRestriction.NoWorldInteractions") && !StatusEffectSystem.ObjectHasStatusEffect(playerPuppet, t"GameplayRestriction.VehicleNoSummoning")) || params.enableQuestCarQuickhack;

		if !this.GetIsDestroyed()
		{
			//Take Control
			if !VehicleComponent.GetVehicle(playerPuppet.GetGame(), playerPuppet.GetEntityID(), playerMountedVehicle)
			{
				currentAction = this.ActionToggleTakeOverControl();
				currentAction.SetObjectActionID(t"DeviceAction.TakeControlVehicleClassHack");
				currentAction.SetExecutor(GetPlayer(this.GetGameInstance()));
				currentAction.SetDurationValue(currentAction.GetDurationTime());
				if (!this.IsVehicleSecurityBreached())
				{
				    currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
				}
				ArrayPush(outActions, currentAction);
				if !isValidRange || isVehicleRemoteControlled || Equals(this.GetOwnerEntity().GetVehicleType(), gamedataVehicleType.Bike) && playerPuppet.CheckIsStandingOnVehicle(this.GetOwnerEntity().GetEntityID())
				{
					currentAction.SetInactiveWithReason(false, "LocKey#7003");
			  	};
			};
			//Force Brakes
			currentAction = this.ActionVehicleOverrideForceBrakes();
			currentAction.SetObjectActionID(t"DeviceAction.VehicleForceBrakesClassHack");
			currentAction.SetExecutor(GetPlayer(this.GetGameInstance()));
			currentAction.SetDurationValue(TweakDBInterface.GetFloat(t"player.vehicleQuickHacks.forceBrakesDuration", 0.00));
			if !isValidRange || isVehicleRemoteControlled
			{
				currentAction.SetInactiveWithReason(false, "LocKey#7003");
			}
			else
			{
				if this.GetOwnerEntity().IsVehicleForceBrakesQuickhackActive()
				{
					currentAction.SetInactiveWithReason(false, "LocKey#7004");
				};
			};

			if (!this.IsVehicleSecurityBreached())
			{
			    currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
			}

			ArrayPush(outActions, currentAction);
			//Explode
			currentAction = this.ActionVehicleOverrideExplode();
			currentAction.SetObjectActionID(t"DeviceAction.VehicleExplodeClassHack");
			currentAction.SetExecutor(GetPlayer(this.GetGameInstance()));
			currentAction.SetDurationValue(currentAction.GetDurationTime());
			if (!this.IsVehicleSecurityBreached())
			{
			    currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
			}
			ArrayPush(outActions, currentAction);
			if !isValidRange
			{
				currentAction.SetInactiveWithReason(false, "LocKey#7003");
			};
			//Full Acceleration
			currentAction = this.ActionVehicleOverrideAccelerate();
			currentAction.SetObjectActionID(t"DeviceAction.VehicleAccelerateClassHack");
			currentAction.SetExecutor(GetPlayer(this.GetGameInstance()));
			currentAction.SetDurationValue(TweakDBInterface.GetFloat(t"player.vehicleQuickHacks.accelerateDuration", 0.00));
			if !isValidRange || isVehicleRemoteControlled
			{
				currentAction.SetInactiveWithReason(false, "LocKey#7003");
			}
			else
			{
				if this.GetOwnerEntity().IsVehicleAccelerateQuickhackActive()
				{
					currentAction.SetInactiveWithReason(false, "LocKey#7004");
				};
			};
			
			if (!this.IsVehicleSecurityBreached())
			{
			    currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
			}
			ArrayPush(outActions, currentAction);

			//VehicleSecurityRework - Distract
			if(params.distractHack)
			{
			    currentAction = this.ActionVehicleDistraction();
			    if (!this.IsVehicleSecurityBreached())
			    {
			        currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
			    }
			    if (this.m_distractExecuted)
			    {
			        currentAction.SetInactiveWithReason(false, "LocKey#7004");	
			    }

			    ArrayPush(outActions, currentAction);
			}

			//Remote Breach
			currentAction = this.ActionUnlockSecurity(this.GetVehicleHackDBDifficulty());
			if (this.IsVehicleSecurityBreached())
			{
			    currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
			}

			ArrayPush(outActions,currentAction);

			//Auto Hack
			currentAction = this.ActionVehicleAutoHack();
			if (this.IsVehicleSecurityBreached())
			{
			    currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
			}
			ArrayPush(outActions, currentAction);
		};
		if !areVehicleQuickhacksAvailable || Equals(vehicleState, vehicleEState.Destroyed) || Equals(vehicleState, vehicleEState.Disabled) || this.GetOwnerEntity().IsVehicleInsideInnerAreaOfAreaSpeedLimiter()
		{
			ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#27694");
		};

		//Remove hacks if it is not a vehicle or a bike (fix for Quest AVs still being hackable)
		if(!(IsDefined(this.GetOwnerEntity() as CarObject) || IsDefined(this.GetOwnerEntity() as BikeObject)) || this.IsVehicleSecurityHardened())
		{
		    ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
		}

		// Block hacks if it is player owned (We don't want to hack our own car unless the user has changed it's settings)
		if (this.GetIsPlayerVehicle() && !params.enablePersonalCarQuickhack)
		{
		    ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, LocKeyToString(n"VehicleSecurityRework-Quickhack-PlayerOwnedPanelInfo"));	
		}
	}

	this.FinalizeGetQuickHackActions(outActions, context);
  }


