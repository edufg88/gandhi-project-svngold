class GPCutsceneTrigger extends Trigger;

DefaultProperties
{
	// Sprite para mosttrar la zona
	Begin Object Name=Sprite
		Sprite=Texture2D'Miscelanea.Texture.T_CutScene'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(Sprite)
}
