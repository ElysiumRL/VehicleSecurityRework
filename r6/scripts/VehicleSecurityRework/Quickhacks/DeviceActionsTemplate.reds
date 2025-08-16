import HackingExtensions.*
//Base Template to make custom quickhacks using Redscript

//You first need an ActionBool (or any ScriptableDeviceAction)
public class QuickhackTemplateDevice extends ActionBool
{
    public final func SetProperties() -> Void
    {
        //Action name has to match the actionName you'll create in tweakDB
        this.actionName = n"QuickhackTemplate";
        this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    }
}

//Then add this function in your object persistent state (Replace obviously names & classes references)
//In general you want to override this function for every persistent state that requires your quickhack
@addMethod(VehicleComponentPS)
private final const func ActionQuickhackTemplate() -> ref<QuickhackTemplateDevice> {
    let action: ref<QuickhackTemplateDevice> = new QuickhackTemplateDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    //This is the most disgusting thing i've done in a long time but as long as it works ...
    //Allows you to get a custom interaction in the remote wheel regardless of cyberdecks/programs installed
    let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance());
    let customHackSystem:ref<CustomHackingSystem> = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;

    customHackSystem.RegisterDeviceAction(action);
    /*
    
    ok so this one is a bit tough to explain so ... what the fuck is this and why is it so important to set an "object action ID" ?
    
    the ObjectActionID is used for the remote wheel, it is this thing that controls for instance if a hack should be visible
    (for instance if you don't have a cyberdeck with the malfunction or Ping hack it won't be displayed in the remote Wheel)
    You can override this behavior in the TranslateActionsIntoQuickSlotCommands function, but it isn't recommended
    TranslateActionsIntoQuickSlotCommands will retrieve all the DeviceActions you passed in the GetQuickhackActions (below)
    and will ALSO retrieve the Player Quickhacks installed (+ those on the cyberdeck by default)
    for each player quickhacks available, it will perform a check if the device action hack matches one of the cyberdeck hacks
    this ObjectActionID is the "thing" used to perform that check
    Setting the ObjectActionID to t"DeviceAction.MalfunctionClassHack" for instance will act as a "Distract Enemies" hack in the remote wheel

    Here is a list (with maybe some missing) that you might find useful for the remote wheel
    t"DeviceAction.MalfunctionClassHack" : Distract Enemies
    t"DeviceAction.PingDevice" : Ping
    t"DeviceAction.OverloadClassHack" : Explode
    t"DeviceAction.ToggleStateClassHack" : Toggle On/Off

    Note: This has no effect to the actual hack, it's just for the remote wheel. You can create your own class hack (gamedataObjectAction_Record)
    yet you'll have to find a way to add your object action to either the cyberdeck default programs or a new cyberdeck item (which i tried but miserably failed ...)

    */
    action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    return action;
}

//Finally, you can use it in the GetQuickHackActions function that "should" exist in your persistent state (or any PS)
//Commented out since I am using it in my own mod
/*
@replaceMethod(VehicleComponentPS)
protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void 
{
    //reference you can use to add all your quickhacks
    let currentAction:ref<ScriptableDeviceAction>;
    let shouldDisableQuickhack:Bool = false;

    //Create the Quickhack Action that is going to be handled by the game
    currentAction = this.ActionQuickhackTemplate();
    //+ an option to disable quickhacks (if you have a reason to disable it)
    //Note: the game will automatically block quickhacks if one is currently executed (but if you played the game you should know it)
    if shouldDisableQuickhack
    {
        //Disable your quickhack
        currentAction.SetInactiveWithReason(false,"This message will appear at the top of the remote wheel");
        //Or use it with a LocKey, probably better than a random string right ?
        currentAction.SetInactiveWithReason(false, "LocKey#7003");
    }
    //Push it to the actions array
    ArrayPush(actions,currentAction);
    


    //DO NOT REMOVE THIS 
    //DONT DO IT I SWEAR
    this.FinalizeGetQuickHackActions(actions, context);
}
*/

//Finally you have to add your new DeviceAction event to your Persistent State

/*
Overriding the Ping quickhack
@addMethod(VehicleComponentPS)
protected cb func OnActionPing(evt:ref<PingDevice>) -> EntityNotificationType
{
    LogChannel(n"DEBUG","Pong!");
    return EntityNotificationType.DoNotNotifyEntity;
}
*/

//Custom quickhacks are sent by a QueuePSDeviceEvent
//you HAVE to use this signature : protected cb func *name*(*arg*:ref<*your DeviceAction Class*>) -> EntityNotificationType
//You can then either choose to send a notification to the entity (so that in our case the VehicleObject && VehicleComponent also can get the event)
//Or you don't notify,nothing happens afterwards, and everyone is happy (or should be happy (((if it works obviously))))

@addMethod(VehicleComponentPS)
protected cb func OnActionQuickhackTemplateDevice(evt:ref<QuickhackTemplateDevice>) -> EntityNotificationType 
{
    //this.GetOwnerEntity().GetVehicleComponent().ExplodeVehicle(this.GetOwnerEntity().GetPlayerMainObject());
    return EntityNotificationType.DoNotNotifyEntity;
}
