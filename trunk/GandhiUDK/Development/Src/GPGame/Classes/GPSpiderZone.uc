class GPSpiderZone extends Actor placeable
	HideCategories(Attachment,Collision, Debug, Physics, Advanced, Object);

var(SpiderPoints) editinline instanced array<GPSpiderPoint> SpiderPoints;
var(SpiderPoints) editinline instanced int index;
var(Spiders) array <GPEnemySpiderPawn> Spiders;

function Vector GetNextLocation()
{
	index++;
	if (index ==  SpiderPoints.Length)
		index = 0;
	return SpiderPoints[index].Location;
}

function Vector GetCurrentLocation()
{
	return SpiderPoints[index].Location;
}

DefaultProperties
{
	// Sprite para mostrar la zona
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Miscelanea.Texture.T_SpiderZone'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(Sprite)

	index = 0;
}