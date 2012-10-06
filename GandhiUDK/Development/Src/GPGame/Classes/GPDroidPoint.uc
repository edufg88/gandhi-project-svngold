class GPDroidPoint extends Actor placeable;

var (DroidPoint) GPEnemyDroidPawn Droid;

DefaultProperties
{
	// Sprite para mostrar la zona
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Miscelanea.Texture.T_DroidPoint'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(Sprite)
}
