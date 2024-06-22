module VehicleSecurityRework.Settings

import VehicleSecurityRework.Vehicles.*
import CustomHackingSystem.Tools.*

// Main Singleton of this mod
// It's partially used to check for mod dependencies, easy lua accessor, mod settings container, and a bit of data storage
public class VehicleSecurityRework extends ScriptableSystem
{
    // Data

    public let vehicleAffiliations: ref<StringIScriptableDictionary>;
    
    // Mod Compatibility

    private let enableArchiveXLDebugLog: Bool = false;

    // Settings

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","General")
    @runtimeProperty("ModSettings.displayName","Auto Unlock Security")
    @runtimeProperty("ModSettings.description","If you only want vehicle quickhacks (Requires Game Restart)")
    public let forceSecurityUnlock:Bool = false;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","General")
    @runtimeProperty("ModSettings.displayName","Flag Vehicle as Stolen")
    @runtimeProperty("ModSettings.description","Enable this to flag the hacked vehicle as Stolen - Fixes an issue with Auto Drive mod (you should leave this as false unless you know what you are doing)")
    public let flagVehiclesAsStolen:Bool = false;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Visibility")
    @runtimeProperty("ModSettings.displayName","Toggle Car scanning Highlights")
    @runtimeProperty("ModSettings.description","Toggles scan/quickhacks highlight effect if you want it disabled")
    public let enableHighlights:Bool = true;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Hacks")
    @runtimeProperty("ModSettings.displayName","Toggle Personal Car Quickhacks")
    @runtimeProperty("ModSettings.description","Toggles the ability to quickhack your own vehicles (Requires Game Restart)")
    public let enablePersonalCarQuickhack:Bool = false;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Hacks")
    @runtimeProperty("ModSettings.displayName","Toggle ALL Car Quickhacks")
    @runtimeProperty("ModSettings.description","Toggles the ability to quickhack ANY (including quest) vehicles (USE THIS AT YOUR OWN RISKS!)")
    public let enableQuestCarQuickhack:Bool = false;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Prevention System")
    @runtimeProperty("ModSettings.displayName","Police Star Level (Easy Hack)")
    @runtimeProperty("ModSettings.description","Sets the amount of stars to raise in case of hack failure")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5")
    public let basePoliceStarLevelEasy:Int32 = 1;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Prevention System")
    @runtimeProperty("ModSettings.displayName","Police Star Level (Medium Hack)")
    @runtimeProperty("ModSettings.description","Sets the amount of stars to raise in case of hack failure")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5")
    public let basePoliceStarLevelMedium:Int32 = 2;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Prevention System")
    @runtimeProperty("ModSettings.displayName","Police Star Level (Hard Hack)")
    @runtimeProperty("ModSettings.description","Sets the amount of stars to raise in case of hack failure")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5")
    public let basePoliceStarLevelHard:Int32 = 2;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Prevention System")
    @runtimeProperty("ModSettings.displayName","Police Star Level (Very Hard Hack)")
    @runtimeProperty("ModSettings.description","Sets the amount of stars to raise in case of hack failure")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5")
    public let basePoliceStarLevelVeryHard:Int32 = 3;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Prevention System")
    @runtimeProperty("ModSettings.displayName","Police Star Level (Security Hardened)")
    @runtimeProperty("ModSettings.description","Sets the amount of stars to raise if the hardened security is being triggered on a vehicle")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5")
    public let basePoliceStarLevelSecurityHardened:Int32 = 2;  

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Prevention System")
    @runtimeProperty("ModSettings.displayName","Maximum Police Star Level")
    @runtimeProperty("ModSettings.description","If your police star level is higher (or equal) to this, no additional star level will be added in case of hack failure")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5")
    public let maximumPoliceStarLevel:Int32 = 4;  

    // Quickhacks (Default)

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Default")
    @runtimeProperty("ModSettings.displayName","Distraction")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack")
    public let distractHack:Bool = true;

    @runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    @runtimeProperty("ModSettings.category","Quickhacks - Default")
    @runtimeProperty("ModSettings.displayName","Pop Random Tire")
    @runtimeProperty("ModSettings.description","Click to toggle this Quickhack")
    public let popRandomTireHack:Bool = true;

    // Disabled until there is an easy way to repair a punctured tire
    //@runtimeProperty("ModSettings.mod","Vehicle Security Rework")
    //@runtimeProperty("ModSettings.category","Quickhacks - Default")
    //@runtimeProperty("ModSettings.displayName","Repair All Tires")
    //@runtimeProperty("ModSettings.description","Click to toggle this Quickhack")
    //public let repairAllTiresHack:Bool = true;

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
    private func OnAttach() -> Void
    {
        this.vehicleAffiliations = new StringIScriptableDictionary();
        this.BuildAllVehicleAffiliations();

        //This is used to detect if ArchiveXL is installed
        //If it isn't, it will simply crash, then get detected by the userHints
        let archiveXLVersion: String = ArchiveXL.Version();
        if(this.enableArchiveXLDebugLog && StrLen(archiveXLVersion) > 0)
        {
            //LogChannel(n"DEBUG","[VehicleSecurityRework] ArchiveXL Version : " + archiveXLVersion);
        }
    }

    //Called by the game when the scriptable system is removed
    private func OnDetach() -> Void
    {
        //LogChannel(n"DEBUG","[VehicleSecurityRework] Scriptable System Detached");
        this.vehicleAffiliations.Clear();
    }

    // Builds the affiliation list based on the vehicle's Appearance Name
    private func BuildAllVehicleAffiliations() -> Void
    {
        this.vehicleAffiliations.Insert("tyger",VehicleAffiliationTuple.Build(t"Factions.TygerClaws","Factions.TygerClaws"));
        this.vehicleAffiliations.Insert("animals",VehicleAffiliationTuple.Build(t"Factions.Animals","Factions.Animals"));
        this.vehicleAffiliations.Insert("6th",VehicleAffiliationTuple.Build(t"Factions.SixthStreet","Factions.SixthStreet"));
        this.vehicleAffiliations.Insert("arasaka",VehicleAffiliationTuple.Build(t"Factions.Arasaka","Factions.Arasaka"));
        this.vehicleAffiliations.Insert("maelstrom",VehicleAffiliationTuple.Build(t"Factions.Maelstrom","Factions.Maelstrom"));
        this.vehicleAffiliations.Insert("valentinos",VehicleAffiliationTuple.Build(t"Factions.Valentinos","Factions.Valentinos"));
        this.vehicleAffiliations.Insert("aldecaldos",VehicleAffiliationTuple.Build(t"Factions.Aldecaldos","Factions.Aldecaldos"));
        this.vehicleAffiliations.Insert("aldecados",VehicleAffiliationTuple.Build(t"Factions.Aldecaldos","Factions.Aldecaldos"));
        this.vehicleAffiliations.Insert("netwatch",VehicleAffiliationTuple.Build(t"Factions.NetWatch","Factions.NetWatch"));
        this.vehicleAffiliations.Insert("militech",VehicleAffiliationTuple.Build(t"Factions.Militech","Factions.Militech"));
        this.vehicleAffiliations.Insert("wraiths",VehicleAffiliationTuple.Build(t"Factions.Wraiths","Factions.Wraiths"));
        this.vehicleAffiliations.Insert("mox",VehicleAffiliationTuple.Build(t"Factions.TheMox","Factions.TheMox"));
        this.vehicleAffiliations.Insert("trama_team",VehicleAffiliationTuple.Build(t"Factions.TraumaTeam","Factions.TraumaTeam"));
        this.vehicleAffiliations.Insert("trauma",VehicleAffiliationTuple.Build(t"Factions.TraumaTeam","Factions.TraumaTeam"));
        this.vehicleAffiliations.Insert("ncpd",VehicleAffiliationTuple.Build(t"Factions.NCPD","Factions.NCPD"));
        this.vehicleAffiliations.Insert("news",VehicleAffiliationTuple.Build(t"Factions.News54","Factions.News54"));
        this.vehicleAffiliations.Insert("kangtao",VehicleAffiliationTuple.Build(t"Factions.KangTao","Factions.KangTao"));
    }
}
