class GPActorFactoryPatrolAI extends ActorFactoryAI;

var() array<GPPatrolZone> PatrolZones;
var() array<GPDroidZone> DroidZones;
var() array< class<GPInventory> > DropItems;

var() array <GPSoundZone> SoundZones;

simulated event PostCreateActor(Actor NewActor, optional const SeqAct_ActorFactory ActorFactoryData)
{
	//// Zonas de patrulla
	////GPEnemyDroidPawn(NewActor).PatrolZ = PatrolZones[ActorFactoryData.CurrentSpawnIdx % PatrolZones.Length];
	////GPEnemyDroidPawn(NewActor).PatrolZ.index = Rand(GPEnemyDroidPawn(NewActor).PatrolZ.PatrolPoints.Length);
	////GPEnemyDroidPawn(NewActor).PatrolZ.Droids.AddItem(GPEnemyDroidPawn(NewActor));

	if(PatrolZones.Length > 0) {
		GPEnemyDroidPawn(NewActor).PatrolZ = PatrolZones[ActorFactoryData.CurrentSpawnIdx % PatrolZones.Length];
		GPEnemyDroidPawn(NewActor).PZindex = Rand(GPEnemyDroidPawn(NewActor).PatrolZ.PatrolPoints.Length);
		GPEnemyDroidPawn(NewActor).PatrolZ.Droids.AddItem(GPEnemyDroidPawn(NewActor));
	}

	// Zonas de cobertura
	if(DroidZones.Length > 0) {
		GPEnemyDroidPawn(NewActor).DroidZ = DroidZones[ActorFactoryData.CurrentSpawnIdx % DroidZones.Length];
		GPEnemyDroidPawn(NewActor).DroidZ.Droids.AddItem(GPEnemyDroidPawn(NewActor));
	}

	// Zonas de sonido
	if(SoundZones.Length > 0) {
		GPEnemyDroidPawn(NewActor).SoundZ = SoundZones[ActorFactoryData.CurrentSpawnIdx % SoundZones.Length];
		GPEnemyDroidPawn(NewActor).SoundZ.Enemies.AddItem(GPEnemyDroidPawn(NewActor));
		GPEnemyDroidPawn(NewActor).SoundZ.numberEnemies++;
	}

	//Item a cagar
	if(DropItems.Length > 0) GPEnemyDroidPawn(NewActor).DropClass = DropItems[ActorFactoryData.CurrentSpawnIdx % DropItems.Length];
}

DefaultProperties
{
	ControllerClass=class'GPEnemyDroidController';
	PawnClass=class'GPEnemyDroidPawn';
}