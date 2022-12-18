module VehicleSecurityRework.Settings

//Scriptable System used by the lua part of the mod to find if redscript files are installed (at least this one file) or not
//This class is also now used to store mod settings
public class VehicleSecurityRework extends ScriptableSystem
{
    //Settings

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
    
    // Quickhacks (Default)

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Default")
    @runtimeProperty("ModSettings.displayName","Distraction")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack")
    public let distractHack:Bool = true;
    
    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Default")
    @runtimeProperty("ModSettings.displayName","Force Brakes")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack")
    public let forceBrakesHack:Bool = true;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Default")
    @runtimeProperty("ModSettings.displayName","Reckless Driving")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack")
    public let recklessDrivingHack:Bool = true;
    
    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Default")
    @runtimeProperty("ModSettings.displayName","Explode")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack")
    public let explodeHack:Bool = true;

    // Quickhacks (LTBF)

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Let There Be Flight")
    @runtimeProperty("ModSettings.displayName","Toggle Flight Mode")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack (Requires Let There Be Flight mod)")
    public let toggleFlightHack:Bool = true;
    
    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Let There Be Flight")
    @runtimeProperty("ModSettings.displayName","Toggle Gravity")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack (Requires Let There Be Flight mod)")
    public let toggleGravityHack:Bool = true;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Let There Be Flight")
    @runtimeProperty("ModSettings.displayName","Liftoff!")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack (Requires Let There Be Flight mod)")
    public let liftoffHack:Bool = true;

    //Called by the game when the scriptable system is created
    //private func OnAttach() -> Void
    //{
    //    LogChannel(n"DEBUG","[VehicleSecurityRework] Scriptable System Attached");
    //}

    //Called by the game when the scriptable system is removed
    //private func OnDetach() -> Void
    //{
    //    LogChannel(n"DEBUG","[VehicleSecurityRework] Scriptable System Detached");
    //}
}
