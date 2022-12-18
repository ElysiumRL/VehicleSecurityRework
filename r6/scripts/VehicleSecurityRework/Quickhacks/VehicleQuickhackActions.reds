module VehicleSecurityRework.Base
import VehicleSecurityRework.Hack.*
import VehicleSecurityRework.Vehicles.*
import VehicleSecurityRework.Settings.*


@if(ModuleExists("LetThereBeFlight"))
import LetThereBeFlight.*

@if(ModuleExists("LetThereBeFlight.Compatibility"))
import LetThereBeFlight.Compatibility.*

//Get all quickhacks for the vehicle - VehicleSecurityRework version
@if(!ModuleExists("LetThereBeFlight"))
@replaceMethod(VehicleComponentPS)
protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void 
{
    let action: ref<ScriptableDeviceAction>;
    
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let params:ref<VehicleSecurityRework> = container.Get(n"VehicleSecurityRework.Settings.VehicleSecurityRework") as VehicleSecurityRework;

    //Remote Breach
    action = this.ActionUnlockSecurity(this.GetVehicleHackDBDifficulty());
    if (this.IsVehicleSecurityHardened())
    {
        action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
    }
    else 
    {
        if (this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
        }
    }
    ArrayPush(actions,action);
    
    //Auto Hack
    action = this.ActionVehicleAutoHack();
    if (this.IsVehicleSecurityHardened())
    {
        action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
    }
    else 
    {
        if (this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
        }
    }
    ArrayPush(actions,action);

    //Explode
    if (params.explodeHack)
    {
        action = this.ActionOverloadVehicle();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        ArrayPush(actions,action);
    }

    //Distract
    if(params.distractHack)
    {
        action = this.ActionVehicleDistraction();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if (this.m_distractExecuted)
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }	
        ArrayPush(actions,action);
    }

    //Force Brakes
    if(params.forceBrakesHack)
    {
        action = this.ActionVehicleForceBrakes();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if (this.quickhackForceBrakesExecuted)
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }
        ArrayPush(actions,action);
    }

    //Reckless Driving
    if(params.recklessDrivingHack)
    {
        action = this.ActionVehicleRecklessDriving();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }
        if (!this.CanTriggerRecklessDriving)
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-RecklessDrivingDisabled"));
        }
        ArrayPush(actions,action);
    }


    if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
    {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7004");	
    }	

    //Remove hacks if it is not a vehicle or a bike (fix for Quest AVs still being hackable)
    if (!(IsDefined(this.GetOwnerEntity() as CarObject) || IsDefined(this.GetOwnerEntity() as BikeObject)))
    {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
    }


    //Block hacks if it is player owned
    if (this.GetIsPlayerVehicle())
    {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, LocKeyToString(n"VehicleSecurityRework-Quickhack-PlayerOwnedPanelInfo"));	
    }

    this.FinalizeGetQuickHackActions(actions, context);
}


//Get all quickhacks for the vehicle - VehicleSecurityRework x LTBF (hybrid) version
@if(ModuleExists("LetThereBeFlight"))
@replaceMethod(VehicleComponentPS)
protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void 
{
    let action: ref<ScriptableDeviceAction>;
    
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let params:ref<VehicleSecurityRework> = container.Get(n"VehicleSecurityRework.Settings.VehicleSecurityRework") as VehicleSecurityRework;


    //Remote Breach
    action = this.ActionUnlockSecurity(this.GetVehicleHackDBDifficulty());
    if (this.IsVehicleSecurityHardened())
    {
        action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
    }
    else 
    {
        if (this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
        }
    }
    ArrayPush(actions,action);
    
    //Auto Hack
    action = this.ActionVehicleAutoHack();
    if (this.IsVehicleSecurityHardened())
    {
        action.SetInactiveWithReason(false,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
    }
    else 
    {
        if (this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityDisabledPanelInfo"));
        }
    }
    ArrayPush(actions,action);

    //Explode
    if(params.explodeHack)
    {
        action = this.ActionOverloadVehicle();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        ArrayPush(actions,action);
    }

    //Distract
    if(params.distractHack)
    {
        action = this.ActionVehicleDistraction();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if (this.m_distractExecuted)
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }	
        ArrayPush(actions,action);
    }

    //Force Brakes
    if(params.forceBrakesHack)
    {
        action = this.ActionVehicleForceBrakes();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if (this.quickhackForceBrakesExecuted)
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }
        ArrayPush(actions,action);
    }

    //Reckless Driving
    if (params.recklessDrivingHack)
    {
        action = this.ActionVehicleRecklessDriving();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if (!this.CanTriggerRecklessDriving)
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-RecklessDrivingDisabled"));
        }    
        if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }
        ArrayPush(actions,action);
    }

    /* Let There Be Flight Quickhacks */

    //Toggle FlightMode
    if(params.toggleFlightHack)
    {
        if (this.GetOwnerEntity().m_flightComponent.active)
        {
            action = this.ActionVehicleToggleFlightOFF();
        }
        else
        {
            action = this.ActionVehicleToggleFlightON();
        }

        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }
        ArrayPush(actions,action);
    }

    //Toggle Gravity
    if(params.toggleGravityHack)
    {
        if (this.GetOwnerEntity().HasGravity())
        {
            action = this.ActionVehicleToggleGravityOFF();
        }
        else
        {
            action = this.ActionVehicleToggleGravityON();
        }

        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        if this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted
        {
            action.SetInactiveWithReason(false, "LocKey#7004");	
        }
        ArrayPush(actions,action);
    }

    //Liftoff
    if(params.liftoffHack)
    {
        action = this.ActionVehicleLiftoff();
        if (!this.IsVehicleSecurityBreached())
        {
            action.SetInactiveWithReason(false, LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityEnabledPanelInfo"));
        }
        ArrayPush(actions,action);
    }
    /* Let There Be Flight Quickhacks End */


    if (this.quickhackRecklessDrivingExecuted || this.m_isGlitching || this.quickhackForceBrakesExecuted)
    {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7004");	
    }

    //Remove hacks if it is not a vehicle or a bike (fix for Quest AVs still being hackable)
    if(!(IsDefined(this.GetOwnerEntity() as CarObject) || IsDefined(this.GetOwnerEntity() as BikeObject)))
    {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions,LocKeyToString(n"VehicleSecurityRework-Quickhack-SecurityHardenedPanelInfo"));
    }
    //Block hacks if it is player owned
    if this.GetIsPlayerVehicle()
    {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, LocKeyToString(n"VehicleSecurityRework-Quickhack-PlayerOwnedPanelInfo"));	
    }

    this.FinalizeGetQuickHackActions(actions, context);
}