class GPDroidZone extends Actor placeable
	HideCategories(Attachment,Collision, Debug, Physics, Advanced, Object);

var (DroidZone) editinline instanced array< GPDroidPoint > DroidPoints;
var (DroidZone) array< GPEnemyDroidPawn > Droids;
var (DroidZone) int PointsIndex;
var (DroidZone) int DroidsIndex;

DefaultProperties
{
	// Sprite para mostrar la zona
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Miscelanea.Texture.T_DroidZone'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(Sprite)
}
