module VehicleSecurityRework.Base
import VehicleSecurityRework.Hack.*
import VehicleSecurityRework.Vehicles.*
import VehicleSecurityRework.Settings.*

@if(ModuleExists("InteractionExtensions"))
import InteractionExtensions.*

@if(ModuleExists("TargetingExtensions"))
import TargetingExtensions.*

//Requires CustomHackingSystem

@if(ModuleExists("HackingExtensions"))
import HackingExtensions.*
@if(ModuleExists("HackingExtensions.Programs"))
import HackingExtensions.Programs.*
@if(ModuleExists("CustomHackingSystem.Tools"))
import CustomHackingSystem.Tools.*


// Hack level of a given vehicle, extracted from the following TweakDBID strings: ("EASY","MEDIUM","HARD","IMPOSSIBLE")
// with "None" added in case we don't want any hack on vehicles
public enum EVehicleHackLevel
{
    None = 0,
    Easy = 1,
    Medium = 2,
    Hard = 3,
    VeryHard = 4
}

//Class used for keybind events
public class GlobalInputListener
{
    let gameInstance: GameInstance;

    let customHackSystem:ref<CustomHackingSystem>;

    let vehiclePS:ref<VehicleComponentPS>;
        
    protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool 
    {
        
        //Debug function to get all action names, Usually you are looking for Choice1 (Primary Interaction) or Choice2 (Secondary Interaction : Distract/Sell in Access Points)
        //LogChannel(n"DEBUG",NameToString(ListenerAction.GetName(action)));

        //Check if the vehicle can be hacked
        if(CanHackTargetedVehicle(this.gameInstance,this.vehiclePS) && (IsDefined(this.vehiclePS.GetOwnerEntity() as CarObject) || IsDefined(this.vehiclePS.GetOwnerEntity() as BikeObject)))
        {
            //Check if button has been released
            if Equals(ListenerAction.GetName(action), n"AttemptUnlockSecurity") && ListenerAction.IsButtonJustReleased(action)
            {
                //Get Custom Hacking System (in order to start hacks)
                let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.gameInstance);
                this.customHackSystem = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;

                //Get the TweakDB record of the hack we want to use (aka: the difficulty)
                let hackToUse:TweakDBID = this.vehiclePS.GetVehicleHackDBDifficulty();
                if !this.vehiclePS.IsVehicleSecurityHardened()
                {
                    //Start the hack
                    this.customHackSystem.StartNewHackInstance("Unlock Vehicle", hackToUse, this.vehiclePS);
                }
            }
        }
    }
}

//Class handling the visual interaction you see when approaching the car
public class InteractionUpdate
{
    let gameInstance: GameInstance;
    let vehiclePS:ref<VehicleComponentPS>;
    
    //Function called every tick
    public func Update() -> Void
    {
        if(CanHackTargetedVehicle(this.gameInstance,this.vehiclePS) 
        && (
            IsDefined(this.vehiclePS.GetOwnerEntity() as CarObject) 
            || IsDefined(this.vehiclePS.GetOwnerEntity() as BikeObject)))
        {
            //Hardened Security (Locks the car for good)
            if (this.vehiclePS.IsVehicleSecurityHardened())
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

//Event called every tick (or "frame" if you prefer)
public class TickUpdate extends Event 
{
}


//Player Puppet overrides

@addField(PlayerPuppet)
private let m_VehicleSecurityInputListener: ref<GlobalInputListener>;

@addField(PlayerPuppet)
private let m_VehicleSecurityInteractionUpdater: ref<InteractionUpdate>;

//Called when the player is spawned to the game
//Usually the place where you register/create references into the player/the game in general
@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool 
{
    wrappedMethod();

    //Setup Input listener
    this.m_VehicleSecurityInputListener = new GlobalInputListener();
    this.m_VehicleSecurityInputListener.gameInstance = this.GetGame();
    this.RegisterInputListener(this.m_VehicleSecurityInputListener);

    //Setup Interaction listener
    this.m_VehicleSecurityInteractionUpdater = new InteractionUpdate();
    this.m_VehicleSecurityInteractionUpdater.gameInstance = this.GetGame();

    //Setup minigame program in CustomHackingSystem
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGame());
    let hackSystem:ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
    hackSystem.AddProgramAction(t"MinigameProgramAction.UnlockVehicle", new UnlockVehicleProgramAction());
    
    if (!this.IsReplacer())
    {	
        //Begin tick update
        let tickEvent:ref<TickUpdate> = new TickUpdate();
        GameInstance.GetDelaySystem(this.GetGame()).DelayEventNextFrame(this, tickEvent);
    }
}

//Called when the player is usually despawned from the game
//Usually the place where you unregister/destroy what you registered in the OnAttach
@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool 
{
    wrappedMethod();

    this.UnregisterInputListener(this.m_VehicleSecurityInputListener);
    this.m_VehicleSecurityInputListener = null;
    this.m_VehicleSecurityInteractionUpdater = null;
}

//This function is called every tick (or "frame" if you prefer)
@addMethod(PlayerPuppet)
protected cb func OnTickUpdate(evt: ref<TickUpdate>) -> Void 
{
    //Execute the interaction update
    this.m_VehicleSecurityInteractionUpdater.Update();
    //Create another tick event
    let tickEvent:ref<TickUpdate> = new TickUpdate();
    //Then queue it for next tick
    //this way this function is called every tick on to the player
    //if there is a better way (or simply a native "tick/update" function it would be a bit more optimized than doing this)
    GameInstance.GetDelaySystem(this.GetGame()).DelayEventNextFrame(this, tickEvent);
}