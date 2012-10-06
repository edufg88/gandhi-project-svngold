class GPPatrolZone extends Actor placeable
	HideCategories(Attachment,Collision, Debug, Physics, Advanced, Object);

var(PatrolPoints) editinline instanced array< GPPatrolPoint > PatrolPoints;
var(PatrolPoints) editinline instanced int index;
var(Droids) array <GPEnemyDroidPawn> Droids;

function Vector GetNextLocation()
{
	index++;
	if (index ==  PatrolPoints.Length)
		index = 0;
	return PatrolPoints[index].Location;
}

function Vector GetCurrentLocation()
{
	return PatrolPoints[index].Location;
}

DefaultProperties
{
	// Sprite para mostrar la zona
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Miscelanea.Texture.T_PatrolZone'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(Sprite)

	index = 0;
}
