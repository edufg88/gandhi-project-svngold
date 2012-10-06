class GPSpawnPoint extends Trigger;

DefaultProperties
{
	Components.Remove(Sprite);
	// Sprite para mostrar la zona
	Begin Object Class=SpriteComponent Name=SpriteTee
		Sprite=Texture2D'Miscelanea.Texture.T_SpawnPoint'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(SpriteTee)
}
