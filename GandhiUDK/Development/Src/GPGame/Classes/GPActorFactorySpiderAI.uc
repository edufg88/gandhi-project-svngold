class GPActorFactorySpiderAI extends ActorFactoryAI;

var() array<GPSpiderZone> SpiderZones;
var() array< class<GPInventory> > DropItems;

var() array <GPSoundZone> SoundZones;

simulated event PostCreateActor(Actor NewActor, optional const SeqAct_ActorFactory ActorFactoryData)
{
	// Zonas de patrulla	
	if(SpiderZones.Length > 0) {
		GPEnemySpiderPawn(NewActor).SpiderZ = SpiderZones[ActorFactoryData.CurrentSpawnIdx % SpiderZones.Length];
		GPEnemySpiderPawn(NewActor).SZIndex = Rand(GPEnemySpiderPawn(NewActor).SpiderZ.SpiderPoints.Length);
		GPEnemySpiderPawn(NewActor).SpiderZ.Spiders.AddItem(GPEnemySpiderPawn(NewActor));
	}

	// Zonas de sonido
	if(SoundZones.Length > 0) {
		GPEnemySpiderPawn(NewActor).SoundZ = SoundZones[ActorFactoryData.CurrentSpawnIdx % SoundZones.Length];
		GPEnemySpiderPawn(NewActor).SoundZ.Enemies.AddItem(GPEnemySpiderPawn(NewActor));
		GPEnemySpiderPawn(NewActor).SoundZ.numberEnemies++;
	}

	//Item a cagar
	if(DropItems.Length > 0) GPEnemySpiderPawn(NewActor).DropClass = DropItems[ActorFactoryData.CurrentSpawnIdx % DropItems.Length];
}

DefaultProperties
{
	ControllerClass=class'GPEnemySpiderController';
	PawnClass=class'GPEnemySpiderPawn';
}
