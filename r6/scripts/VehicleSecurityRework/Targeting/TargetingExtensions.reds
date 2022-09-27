module TargetingExtensions

public static func LookAtGameObject(gameInstance: GameInstance,opt useLineOfSight:Bool,opt ignoreTransparency:Bool) -> ref<GameObject>
{
	let player = GetPlayer(gameInstance);
	let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
	let targetObject: ref<GameObject> = targetingSystem.GetLookAtObject(player, useLineOfSight, ignoreTransparency);
	return targetObject;
}

public static func LookAtGameObject(gameInstance: GameInstance, maxDistance: Float,opt useLineOfSight:Bool,opt ignoreTransparency:Bool) -> ref<GameObject> 
{
	let player = GetPlayer(gameInstance);
	let targetObject: ref<GameObject> = LookAtGameObject(gameInstance,useLineOfSight,ignoreTransparency);

	if(targetObject != null)
	{
		if(Vector4.Distance(player.GetWorldPosition(),targetObject.GetWorldPosition()) < maxDistance)
		{
			return targetObject;
		}
	}

	return null;
}