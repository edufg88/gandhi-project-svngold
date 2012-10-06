class GPSoundZone extends Actor placeable
	HideCategories(Attachment,Collision, Debug, Physics, Advanced, Object);

var (SoundZone) array< GPEnemyPawn > Enemies;
var (SoundZone) SoundCue TensionSound;
var (SoundZone) AudioComponent TensionAudio;
var (SoundZone) int numberEnemies;

function PlayTension()
{
	TensionAudio.Play();
}

function StopTension()
{
	TensionAudio.Stop();
}

DefaultProperties
{
	// Sprite para mostrar la zona
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Miscelanea.Texture.T_SoundZone'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(Sprite)

	numberEnemies = 0;
	
	TensionSound = SoundCue'Music.Ambient.Tension02_Cue'; 

	Begin Object Class=AudioComponent Name=TAComp
		SoundCue=SoundCue'Music.Ambient.Tension02_Cue';    

	End Object
	TensionAudio = TAComp
}
