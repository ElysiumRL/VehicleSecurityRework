module InteractionExtensions
//TODO: HoldButton doesn't work & refactor this whole thing (It works but holy copy/paste)
//It's a hacky way to add interactions to the UI, but not the best one,best one would be to directly add it to the PS
//TODO: Comments


private func CreateInteractionChoice(action: CName, title: String, opt holdButton : Bool) -> InteractionChoiceData 
{
	let choiceData: InteractionChoiceData;
	choiceData.localizedName = title;
	choiceData.inputAction = action;
	choiceData.isHoldAction = holdButton;
	let choiceType: ChoiceTypeWrapper;
	//ChoiceTypeWrapper.SetType(choiceType, gameinteractionsChoiceType.Inactive);
	ChoiceTypeWrapper.SetType(choiceType, gameinteractionsChoiceType.Blueline);
	choiceData.type = choiceType;
	return choiceData;
}

private func CreateLockedInteractionChoice(action: CName, title: String, opt holdButton : Bool) -> InteractionChoiceData 
{
	let choiceData: InteractionChoiceData;
	choiceData.localizedName = title;
	choiceData.inputAction = action;
	choiceData.isHoldAction = holdButton;
	let choiceType: ChoiceTypeWrapper;
	ChoiceTypeWrapper.SetType(choiceType, gameinteractionsChoiceType.Inactive);
	//ChoiceTypeWrapper.SetType(choiceType, gameinteractionsChoiceType.Blueline);
	choiceData.type = choiceType;
	return choiceData;
}

private func GenerateVisualizersInfo(choiceHubData: InteractionChoiceHubData) -> VisualizersInfo 
{
	let visualizersInfo: VisualizersInfo;
	visualizersInfo.activeVisId = choiceHubData.id;
	visualizersInfo.visIds = [choiceHubData.id];
	return visualizersInfo;
}

//Adds interaction to the UI
public static func AddInteraction(gameInstance:GameInstance,title:String,action:CName, opt holdButton: Bool) -> Bool
{
	let blackboardDefinitions = GetAllBlackboardDefs();
	let interactionBlackBoard = GameInstance.GetBlackboardSystem(gameInstance).Get(blackboardDefinitions.UIInteractions);
	let interactionChoiceHub: InteractionChoiceHubData = FromVariant(interactionBlackBoard.GetVariant(blackboardDefinitions.UIInteractions.InteractionChoiceHub));
	if (!interactionChoiceHub.active)
	{
		ArrayClear(interactionChoiceHub.choices);
		interactionChoiceHub.active = true;
	}
	let interactionAlreadyExists: Bool = false;
	for interaction in interactionChoiceHub.choices
	{
		if(Equals(interaction.localizedName,title) && Equals(interaction.inputAction,action) && Equals(interaction.isHoldAction, holdButton))
		{
			interactionAlreadyExists = true;
		}
	}
	if(!interactionAlreadyExists)
	{
		ArrayPush(interactionChoiceHub.choices, CreateInteractionChoice(action, title));
		let visualizersInfo = GenerateVisualizersInfo(interactionChoiceHub);
		interactionBlackBoard.SetVariant(blackboardDefinitions.UIInteractions.InteractionChoiceHub, ToVariant(interactionChoiceHub), true);
		interactionBlackBoard.SetVariant(blackboardDefinitions.UIInteractions.VisualizersInfo, ToVariant(visualizersInfo), true);
		return true;
	}
	return false;
}

//Adds interaction to the UI

public static func AddLockedInteraction(gameInstance:GameInstance,title:String,action:CName, opt holdButton: Bool) -> Bool
{
	let blackboardDefinitions = GetAllBlackboardDefs();
	let interactionBlackBoard = GameInstance.GetBlackboardSystem(gameInstance).Get(blackboardDefinitions.UIInteractions);
	let interactionChoiceHub: InteractionChoiceHubData = FromVariant(interactionBlackBoard.GetVariant(blackboardDefinitions.UIInteractions.InteractionChoiceHub));
	if (!interactionChoiceHub.active)
	{
		ArrayClear(interactionChoiceHub.choices);
		interactionChoiceHub.active = true;
	}
	let interactionAlreadyExists: Bool = false;
	for interaction in interactionChoiceHub.choices
	{
		if(Equals(interaction.localizedName,title) && Equals(interaction.inputAction,action) && Equals(interaction.isHoldAction, holdButton))
		{
			interactionAlreadyExists = true;
		}
	}
	if(!interactionAlreadyExists)
	{
		ArrayPush(interactionChoiceHub.choices, CreateLockedInteractionChoice(action, title));
		let visualizersInfo = GenerateVisualizersInfo(interactionChoiceHub);
		interactionBlackBoard.SetVariant(blackboardDefinitions.UIInteractions.InteractionChoiceHub, ToVariant(interactionChoiceHub), true);
		interactionBlackBoard.SetVariant(blackboardDefinitions.UIInteractions.VisualizersInfo, ToVariant(visualizersInfo), true);
		return true;
	}
	return false;
}

//Removes Interaction from UI (only if interaction exists)
public static func RemoveInteraction(gameInstance:GameInstance,title:String,action:CName,opt holdButton:Bool) -> Bool
{
	let blackboardDefinitions = GetAllBlackboardDefs();
	let interactionBlackBoard = GameInstance.GetBlackboardSystem(gameInstance).Get(blackboardDefinitions.UIInteractions);
	let interactionChoiceHub: InteractionChoiceHubData = FromVariant(interactionBlackBoard.GetVariant(blackboardDefinitions.UIInteractions.InteractionChoiceHub));
	let interactionToRemove:InteractionChoiceData;
	let canRemoveInteraction:Bool = false;
	for interactionChoice in interactionChoiceHub.choices
	{
		if(Equals(interactionChoice.localizedName,title) && Equals(interactionChoice.inputAction,action) && Equals(interactionChoice.isHoldAction, holdButton))
		{
			interactionToRemove = interactionChoice;
			canRemoveInteraction = true;
		}
	}
	if(canRemoveInteraction)
	{
		ArrayRemove(interactionChoiceHub.choices,interactionToRemove);
		let visualizersInfo = GenerateVisualizersInfo(interactionChoiceHub);
		interactionBlackBoard.SetVariant(blackboardDefinitions.UIInteractions.InteractionChoiceHub, ToVariant(interactionChoiceHub), true);
		interactionBlackBoard.SetVariant(blackboardDefinitions.UIInteractions.VisualizersInfo, ToVariant(visualizersInfo), true);
		return true;
	}
	return false;
}
