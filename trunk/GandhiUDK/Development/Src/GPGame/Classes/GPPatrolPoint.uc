class GPPatrolPoint extends Actor placeable;

DefaultProperties
{
	// Sprite para mosttrar la zona
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Miscelanea.Texture.T_PatrolPoint'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(Sprite)

}
