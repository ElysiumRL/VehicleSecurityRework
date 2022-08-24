Hack = {}

--For more informations on how this works, see CustomHackingSystem

function Hack.Generate()

	local CustomHackingSystem = GetMod("CustomHackingSystem")

	local customHackingType = CustomHackingSystem.API.CreateHackingMinigameCategory("Custom")
	local customRewardType = CustomHackingSystem.API.CreateProgramActionType("CustomRewards")

	local unlockVehicleUIIcon = CustomHackingSystem.API.CreateUIIcon("icon_minigame_data2","base\\gameplay\\gui\\common\\icons\\item_icons.inkatlas")
	local unlockVehicleUI = CustomHackingSystem.API.CreateProgramActionUI("unlockVehicleUI",LocKey(3652001),LocKey(3652002),unlockVehicleUIIcon)
	local unlockVehicleProgramAction = CustomHackingSystem.API.CreateProgramAction("UnlockVehicle",customRewardType,customHackingType,unlockVehicleUI,-50)

	local unlockVehicleProgramEasy = CustomHackingSystem.API.CreateProgram("unlockVehicleEasy",unlockVehicleProgramAction,3)
	local unlockVehicleProgramMedium = CustomHackingSystem.API.CreateProgram("unlockVehicleMedium",unlockVehicleProgramAction,4)
	local unlockVehicleProgramHard = CustomHackingSystem.API.CreateProgram("unlockVehicleHard",unlockVehicleProgramAction,5)
	local unlockVehicleProgramImpossible = CustomHackingSystem.API.CreateProgram("unlockVehicleImpossible",unlockVehicleProgramAction,8)

	local unlockVehicleHackEasy ={unlockVehicleProgramEasy}
	local unlockVehicleHackMedium ={unlockVehicleProgramMedium}
	local unlockVehicleHackHard ={unlockVehicleProgramHard}
	local unlockVehicleHackImpossible ={unlockVehicleProgramImpossible}

	local unlockVehiclehackingMinigameEasy = CustomHackingSystem.API.CreateHackingMinigame("UnlockVehicleEasy",10.00,5,-40,6,unlockVehicleHackEasy,{})
	local unlockVehiclehackingMinigameMedium = CustomHackingSystem.API.CreateHackingMinigame("UnlockVehicleMedium",20.00,5,0,7,unlockVehicleHackMedium,{})
	local unlockVehiclehackingMinigameHard = CustomHackingSystem.API.CreateHackingMinigame("UnlockVehicleHard",30.00,6,20,9,unlockVehicleHackHard,{})
	local unlockVehiclehackingMinigameImpossible = CustomHackingSystem.API.CreateHackingMinigame("UnlockVehicleImpossible",40.00,9,40,12,unlockVehicleHackImpossible,{})

end

return Hack
