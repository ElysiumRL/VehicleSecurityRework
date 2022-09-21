module VehicleSecurityRework.Hack

//Make sure that the "HackingExtensions" and "HackingExtensions.Programs" do exist
//This means the CustomHackingSystem mod is (or is not) in your redscript folder

@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*

@if(ModuleExists("HackingExtensions.Programs"))
import HackingExtensions.Programs.*

import VehicleSecurityRework.Base.*

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

		//This count is used for knowing if a vehicle hack has been failed multiple times
		//It's part of an "Improved" security restricting the amount of hacks possible especially on a high-end car
		vehiclePS.m_hackAttemptsOnVehicle += 1;
		let lockDifficulty: String = vehiclePS.GetVehicleCrackLockDifficulty();
		CheckToLockSecurity(vehiclePS,lockDifficulty);
		//So here we want to call the police
		//Police spawn is handled by the PreventionSystem (and PreventionSpawnSystem)
		//But since we can't get it in the GameInstance, we have to get it with the Scriptable System Container
		let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.gameInstance);
		let preventionSystem:ref<PreventionSystem> = container.Get(n"PreventionSystem") as PreventionSystem;

		//To Call the police and increase police heat, we need the PreventionCrimeWitnessRequest event
		//events for scriptable systems are called ScriptableSystemRequest
		let crimeWitness:ref<PreventionCrimeWitnessRequest> = new PreventionCrimeWitnessRequest();
				
		//We fill the position (vector4) of the crime (so player position)
		crimeWitness.criminalPosition = this.GetPlayer().GetWorldPosition();
		
		//And then we queue the "event" to the prevention system
		preventionSystem.QueueRequest(crimeWitness);
		
		let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.gameInstance);
		let params:ref<VehicleSecurityRework> = container.Get(n"VehicleSecurityRework.Base.VehicleSecurityRework") as VehicleSecurityRework;

		if params.vehicleCombatCompatibility
		{
			let preventionRequest:ref<PreventionDelayedSpawnRequest> = new PreventionDelayedSpawnRequest();
			preventionRequest.heatStage = EPreventionHeatStage.Heat_1;
			preventionSystem.QueueRequest(preventionRequest);

			//let i:Int32 = 0;
			//while (i < 5)
			//{
			//	GameInstance.GetDelaySystem(this.gameInstance).QueueTask(this,null,n"PreventionSystem.CreateVCDamageRequest",gameScriptTaskExecutionStage.Any);
			//	//PreventionSystem.CreateVCDamageRequest(this.gameInstance, GetPlayer(this.gameInstance), 1.75, "");
			//	i+=1;
			//}

		}

		//and poof you get the police triggered at you (the same as if you were killing a civilian)
		
		//+ an additional warning message (even if there is already the police message)
		if IsVehicleSecurityHardened(vehiclePS)
		{
			this.GetPlayer().SetWarningMessage(LocKeyToString(n"VehicleSecurityRework-UnlockVehicleHack-ProgramLock"));
		}
		else
		{
			this.GetPlayer().SetWarningMessage(LocKeyToString(n"VehicleSecurityRework-UnlockVehicleHack-ProgramFailure"));
		}

		
		//You can toggle the horn with the VehicleObject class very easily
		let vehicleObject:ref<VehicleObject> = vehiclePS.GetOwnerEntity();

		//Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk Honk
		vehicleObject.ToggleHornForDuration(7.50);
		let action:ref<VehicleDistractionDeviceAction> = vehiclePS.ActionVehicleDistraction();
		vehiclePS.OnActionVehicleDistraction(action);

	}

	//Opens the vehicle (yeah forreal)
	private func OpenVehicle() -> Void
	{
		//We get the object reference passed in the StartHacking function
		//Note: you can also use the AdditionalData field in the hackInstanceSettings struct to pass random things to your hacks
		//and use FromVariant() & ToVariant() function to retrieve/send those "things"
		let vehicle:ref<VehicleComponentPS> = this.hackInstanceSettings.hackedTarget as VehicleComponentPS;
		
		//Check if vehicle still exists and if it is a VehicleComponentPS
		if IsDefined(vehicle)
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
			if !this.hackInstanceSettings.isQuickhack
			{
				vehicle.QueuePSEvent(vehicle,toggleVehicle);
				vehicle.QueuePSEvent(vehicle,openMainDoor);
			}

			//LogChannel(n"DEBUG","Vehicle Security Unlocked");
		}
		else
		{
			//LogChannel(n"DEBUG","[Custom Hacking System] Vehicle Not Found");
		}
	}
}