module VehicleSecurityRework.Base
import VehicleSecurityRework.Hack.*
import VehicleSecurityRework.Vehicles.*
import VehicleSecurityRework.Settings.*

@if(ModuleExists("LetThereBeFlight"))
import LetThereBeFlight.*

@if(ModuleExists("LetThereBeFlight.Compatibility"))
import LetThereBeFlight.Compatibility.*

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
			// CDPR - Take Control
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
			// CDPR - Force Brakes (the VehicleSecurityRework is no longer needed)
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

			// CDPR - Explode (the VehicleSecurityRework is no longer needed)
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
			// CDPR - Full Acceleration
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

			// VehicleSecurityRework - Distract
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

			// VehicleSecurityRework - Pop Random Tire
			if(params.popRandomTireHack)
			{
			    currentAction = this.ActionVehiclePopTire();
			    if (!this.IsVehicleSecurityBreached())
			    {
			        currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
			    }
				else if ((this.GetOwnerEntity() as WheeledObject).AreAllTiresPunctured())
				{
			        currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-AllTiresPoppedPanelInfo"));
				}

			    ArrayPush(outActions, currentAction);
			}

			// VehicleSecurityRework - Repair All Tires
			// Set as a placeholder here but right now it's not working. I don't think there is a trivial way to auto repair a broken tire
//			if(params.repairAllTiresHack)
//			{
//			    currentAction = this.ActionVehicleRepairTires();
//			    if (!this.IsVehicleSecurityBreached())
//			    {
//			        currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
//			    }
//				else if (!(this.GetOwnerEntity() as WheeledObject).AreAllTiresPunctured())
//				{
//			        currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-AllTiresFinePanelInfo"));
//				}
//
//			    ArrayPush(outActions, currentAction);
//			}

			// VehicleSecurityRework - Remote Breach
			currentAction = this.ActionUnlockSecurity(this.GetVehicleHackDBDifficulty());
			if (this.IsVehicleSecurityBreached())
			{
			    currentAction.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
			}

			ArrayPush(outActions,currentAction);

			// VehicleSecurityRework - Auto Hack
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

		// Remove hacks if it is not a vehicle or a bike (fix for Quest AVs still being hackable)
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


