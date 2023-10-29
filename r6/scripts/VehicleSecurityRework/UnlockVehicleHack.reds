module VehicleSecurityRework.Hack
import VehicleSecurityRework.Vehicles.*
import VehicleSecurityRework.Settings.*

//Make sure that the "HackingExtensions" and "HackingExtensions.Programs" do exist
//This means the CustomHackingSystem mod is (or is not) in your redscript folder

@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*

@if(ModuleExists("HackingExtensions.Programs"))
import HackingExtensions.Programs.*

///////////////////////////////////////////////////////////////////////////

//Unlocks vehicle when hacked
public class UnlockVehicleProgramAction extends HackProgramAction
{
	//This function is called by the Custom Hacking system when you finish the hack
	protected func ExecuteProgramSuccess() -> Void
	{
		this.OpenVehicle();
	}

	//This function is called by the Custom Hacking system when you fail to get the hack
	protected func ExecuteProgramFailure() -> Void
	{	
		//Retrieve the vehicle PS (we are going to need it a lot)
		let vehiclePS:ref<VehicleComponentPS> = this.hackInstanceSettings.hackedTarget as VehicleComponentPS;
		let vehicleObject:ref<VehicleObject> = vehiclePS.GetOwnerEntity();
		let hasAlreadyBeenHacked:Bool = vehiclePS.m_hackAttemptsOnVehicle > 1;
		//This count is used for knowing if a vehicle hack has been failed multiple times
		//It's part of an "Improved" security restricting the amount of hacks possible especially on a high-end car
		vehiclePS.m_hackAttemptsOnVehicle += 1;
		let lockDifficulty: String = vehiclePS.GetVehicleCrackLockDifficulty();
		vehiclePS.TryToForceVehicleSecurity(lockDifficulty);

		let request: ref<PreventionDamage> = new PreventionDamage();
		request.target = vehicleObject;
		request.attackTime = 5.0;
		request.attackType = gamedataAttackType.Hack;
		request.damageDealtPercent = 100.0;
		request.isTargetKilled = true;
		
		let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(this.gameInstance).Get(n"PreventionSystem") as PreventionSystem;
		
		//Create base prevention request (used to raise a star)
	  	let preventionSystemRequest = new PreventionDamageRequest();
		preventionSystemRequest.targetID = vehicleObject.GetEntityID();
		preventionSystemRequest.targetPosition = vehicleObject.GetWorldPosition();
		preventionSystemRequest.isTargetPrevention = vehicleObject.IsPrevention();
		preventionSystemRequest.isTargetVehicle = true;
		preventionSystemRequest.isTargetKilled = true;
		preventionSystemRequest.telemetryInfo = request.GetTelemetryDescription();
	  	preventionSystemRequest.attackType = gamedataAttackType.Hack;
	  	preventionSystemRequest.damageDealtPercentValue = 100.0;

		if(!hasAlreadyBeenHacked)
		{
			let preventionDifficulty:Int32 = vehicleObject.GetPreventionResponseDifficulty();
			let i = 0;
			while(i < preventionDifficulty - 1)
			{
				//Raises 1 star level for each call
	  			preventionSystem.ProcessPreventionDamageRequest(preventionSystemRequest);
	  			i += 1;
			}
		}
		else
		{
			if(vehiclePS.IsVehicleSecurityHardened())
			{
				let i = 0;
				while(i < vehicleObject.VehicleSecurityReworkSingleton.basePoliceStarLevelSecurityHardened)
				{
					preventionSystem.ProcessPreventionDamageRequest(preventionSystemRequest);
					i+=1;
				}
			}
		}
		//By default, sending these methods too will automatically raise a star
		vehiclePS.SendStimsOnVehicleQuickhack(true,false);
      	preventionSystem.HeatPipeline("PlayerStoleVehicle");
		PreventionSystem.SetSpawnCodeRedReinforcement(this.gameInstance,true);

		//+ an additional warning message
		if (vehiclePS.IsVehicleSecurityHardened())
		{
			PreventionSystem.ShowMessage(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-UnlockVehicleHack-ProgramLock"),5.0);
		}
		else
		{
			PreventionSystem.ShowMessage(this.gameInstance,LocKeyToString(n"VehicleSecurityRework-UnlockVehicleHack-ProgramFailure"),5.0);
		}

		let action:ref<VehicleDistractionDeviceAction> = vehiclePS.ActionVehicleDistraction();
		vehiclePS.OnActionVehicleDistraction(action);
		vehicleObject.GetVehicleComponent().PlayHonkForDuration(7.50);
	}

	//Opens the vehicle (yeah forreal)
	private func OpenVehicle(opt noDoorOpen:Bool) -> Void
	{
		//We get the object reference passed in the StartHacking function
		//Note: you can also use the AdditionalData field in the hackInstanceSettings struct to pass random things to your hacks
		//and use FromVariant() & ToVariant() function to retrieve/send those "things"
		let vehicle:ref<VehicleComponentPS> = this.hackInstanceSettings.hackedTarget as VehicleComponentPS;
		
		//Check if vehicle still exists and if it is a VehicleComponentPS
		if (IsDefined(vehicle))
		{
			//Our boolean to check if we hacked the vehicle
			vehicle.m_isVehicleHacked = true;
			
			//This is added for saves, since the boolean is not saved with the persistent state,
			//we use this value (isStolen) as a way to know if the vehicle was hacked
			//that way, you won't have to re-hack vehicle on reloading a save 
			vehicle.SetIsStolen(true);
			
			//Optional, you don't "really" need it
			vehicle.UnlockAllVehDoors();
			
			//Event used to turn on/off unlocked vehicle
			let toggleVehicle:ref<ToggleVehicle> = new ToggleVehicle();
			//Most events in the game have to be set up by SetProperties and/or SetUp functions
			toggleVehicle.SetProperties(true);

			//Event used to open a door 
			let openMainDoor:ref<VehicleDoorOpen> = new VehicleDoorOpen();
			//the string referencing the door you want to open can be found on EVehicleDoor
			openMainDoor.SetProperties("seat_front_left");

			//Queue all events to the vehicle persistent state and let the game handle it for you
			if (!this.hackInstanceSettings.isQuickhack || noDoorOpen)
			{
				vehicle.QueuePSEvent(vehicle,toggleVehicle);
				vehicle.QueuePSEvent(vehicle,openMainDoor);
			}

			//LogChannel(n"DEBUG","Vehicle Security Unlocked");
		}
		//else
		//{
		//	LogChannel(n"DEBUG","[Custom Hacking System] Vehicle Not Found");
		//}
	}
}