class GPGame extends GameInfo;

// Default pawn archetype to use
var const Pawn DefaultPawnArchetype;

var array<GPBaseAIController> SpawnedEnemies;
var GPSiriController Siri;
var GPInventoryGandhiPawn InvGandhi;

// Control de sonidos
////////////////////////////////////
//var int CurrentFloor;
var bool PlayingBaseSound;
var bool PlayingTensionSound;

var (Water) AudioComponent WaterSound;

var array<GPPuzzlePiece> puzs;
var bool puzzleTime;

exec function startPuzzle()
{
	puzzleTime = true;
}

////////////////////////////////////

function PlayAmbient()
{
	local int dice;
	dice = Rand(2);
	switch(dice)
	{
		case 0:
			PlaySound(SoundCue'SoundFX.Misc.SFX_Gong_Cue');
		case 1:
			PlaySound(SoundCue'SoundFX.Misc.SFX_IndustrialFX_Cue');
			break;
		default:
			break;
	}
}

function PostBeginPlay()
{
	SetTimer(20.f, true, NameOf(PlayAmbient));
}

exec function GPMap(int i)
{
	//ClientPrepareMapChange(name("HangarMap"), false, true);
	//PlayerOwner.ClientCommitMapChange();

	switch(i) {
		case 0:
			ConsoleCommand("open DefinitivoTemp");
			break;
		//case 1:
		//	ConsoleCommand("open BayMarc");
		//	break;
		//case 2:
		//	ConsoleCommand("open HangarTest");
		//	break;
		case 1:
			ConsoleCommand("open HangarTest");
			break;
		//case 4:
		//	ConsoleCommand("open PW-Sandbox-GP");
		//	break;
	}
}

exec function GPNextMap()
{
	local int nextMap;

	switch(WorldInfo.GetMapName())
	{
		case "DefinitivoTemp":
			nextMap = 1;
			break;
		case "HangarTest":
			nextMap = 0;
			break;
	}
	GPMap(nextMap);
}

function AddSpawnedEnemy(GPBaseAIController GPEC)
{
	SpawnedEnemies.AddItem(GPEC);
}

function RemoveSpawnedEnemy(GPBaseAIController GPEC)
{
	SpawnedEnemies.RemoveItem(GPEC);
}

function WarnEnemies()
{
	local int i;
	for(i = 0; i < SpawnedEnemies.Length; i++) {
		SpawnedEnemies[i].Warn();
	}
}

function SetSiri(GPSiriController GPS) 
{
	Siri = GPS;
}

function WarnSiri(Pawn P) 
{
	Siri.Warn(P);
}

/**
 * Called by the game or the player when the player wants to be restarted
 *
 * @param		NewPlayer			Player that wants to be restarted
 */
function RestartPlayer(Controller NewPlayer)
{
	local GPPlayerReplicationInfo GPPlayerReplicationInfo;

	// Check incoming variables
	if (NewPlayer == None)
	{
		return;
	}

	// Grab the player replication info and check if the player has assigned a class archetype
	GPPlayerReplicationInfo = GPPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo);
	if (GPPlayerReplicationInfo == None || GPPlayerReplicationInfo.ClassArchetype == None)
	{
		return;
	}

	// Proceed with restarting the player 
	Super.RestartPlayer(NewPlayer);
}

/**
 * Adds the default inventory for the pawn
 *
 * @param		Pawn		Pawn to give the default inventory to
 */
event AddDefaultInventory(Pawn Pawn)
{
	local GPPlayerReplicationInfo GPPlayerReplicationInfo;
	local GPInventoryManager GPInventoryManager;
	local GPInventory GPInv;
	//local GPWeapon GPW;
	//local GPPlayerPawn P;
	//local bool RegetLink, RegetShock;
	//local GPPlayerPawn GPPawn;
	//local int i;	

	//GPPawn = GPPlayerPawn(Pawn);
	//RegetLink = false;
	//RegetShock = false;
	// Ensure the pawn is valid
	if (Pawn == None)
	{
		return;
	}
	else if (Pawn.Class == class'GPPlayerPawn')
	{
		// Ensure that the pawn has the right inventory mananger
		if (GPInventoryManager(Pawn.InvManager) != none)
		{
			GPInventoryManager = GPPlayerReplicationInfo(Pawn.PlayerReplicationInfo).PawnInventory;
			//Pawn.InvManager = GPInventoryManager;
			
			if (GPInventoryManager == None)
			{
				return;
			}
			else
			{
				//GPInventoryManager.AddInventory(GPPlayerReplicationInfo(Pawn.PlayerReplicationInfo).LastWeapon);
				ForEach GPInventoryManager.InventoryActors(class'GPInventory', GPInv)
				{
					//GPInventoryManager(Pawn.InvManager).CreateInventoryFromArchetype(GPInv);
					GPInventoryManager(Pawn.InvManager).AddInventory(GPInv);
					GPInv.isAttachedToGandhi = false;
					GPInv.InvManager = Pawn.InvManager;
					GPInv.SetOwner(Pawn);
				}
				if(GPInventoryManager.gotGun) GPPlayerPawn(Pawn).GiveGun();
				if(GPInventoryManager.gotRifle) GPPlayerPawn(Pawn).GiveRifle();

			}
		}
		else
		{
			GPInventoryManager = GPInventoryManager(Pawn.InvManager);
		}

		// Ensure that the player replication info is accessible and the class archetype is set
		GPPlayerReplicationInfo = GPPlayerReplicationInfo(Pawn.PlayerReplicationInfo);
		if (GPPlayerReplicationInfo == None || GPPlayerReplicationInfo.ClassArchetype == None)
		{
			return;
		}

		// Check if the class has any weapons to give
		//if (GPPlayerReplicationInfo.ClassArchetype.WeaponArchetypes.Length > 0)
		//{
		//	// Iterate through each array entry and give the weapon to the pawn
		//	for (i = 0; i < GPPlayerReplicationInfo.ClassArchetype.WeaponArchetypes.Length; ++i)
		//	{
		//		if (GPPlayerReplicationInfo.ClassArchetype.WeaponArchetypes[i] != None)
		//		{
		//			// Create the inventory from the weapon archetype
		//			GPInventoryManager.CreateInventoryFromArchetype(GPPlayerReplicationInfo.ClassArchetype.WeaponArchetypes[i]);
		//			// Ponemos las armas en el socket correspondiente para que se vean ingame 
		//			//GPPawn.Mesh.AttachComponentToSocket(GPPawn.LinkGunMesh, GPPawn.FundaPistolaSocketName);
		//			GPPawn.Mesh.AttachComponentToSocket(GPPawn.ShockRifleMesh, GPPawn.FundaRifleSocketName);
		//		}
		//	}
		//}

		// Añadimos por defecto algunos elementos al inventario /////////////////////////////
		//GPInventoryManager.CreateInventory(class'GPEnergyItem');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//GPInventoryManager.CreateInventory(class'GPDoorKey');
		//GPInventoryManager.CreateInventory(class'GPEnergyItem');
		//GPInventoryManager.CreateInventory(class'GPSiriControlModule');

		//GPInventoryManager.CreateInventory(class'GPChestArmorItem');
		//GPInventoryManager.CreateInventory(class'GPLCalfArmorItem');
		//GPInventoryManager.CreateInventory(class'GPLUpperArmArmorItem');
		//GPInventoryManager.CreateInventory(class'GPLForeArmArmorItem');
		//GPInventoryManager.CreateInventory(class'GPLThighArmorItem');

		//GPInventoryManager.CreateInventory(class'GPRCalfArmorItem');
		//GPInventoryManager.CreateInventory(class'GPRUpperArmArmorItem');
		//GPInventoryManager.CreateInventory(class'GPRForeArmArmorItem');
		//GPInventoryManager.CreateInventory(class'GPRThighArmorItem');

		//GPInventoryManager.CreateInventory(class'GPRCalfArmorItem');
		//GPInventoryManager.CreateInventory(class'GPRUpperArmArmorItem');
		//GPInventoryManager.CreateInventory(class'GPRForeArmArmorItem');
		//GPInventoryManager.CreateInventory(class'GPRThighArmorItem');

		//GPInventoryManager.CreateInventory(class'GPTurbineItem');

		//GPLinkGunItem(GPInventoryManager.CreateInventory(class'GPLinkGunItem')).AdjustPawn(GPPlayerPawn(Pawn), false);
		//GPInventoryManager.CreateInventoryFromArchetype(GPPlayerReplicationInfo(Pawn.PlayerReplicationInfo).ClassArchetype.WeaponArchetypes[0]);
		//GPInventoryManager.CreateInventory(class'GPShockRifleItem');
		
		//GPInventoryManager.CreateInventory(class'GPRepairKit');
		//////////////// QUITAR ////////////////////////////////////////////////////////////
	}
	else if (Pawn.Class == class'GPSiriPawn')
	{
	
	}
	else if (Pawn.Class == class'GPEnemyDroidPawn')
	{
	
	}
	else
	{}
}

/**
 * Returns a pawn of the default pawn class
 *
 * @param		NewPlayer		Controller for whom this pawn is spawned
 * @param		StartSpot		PlayerStart at which to spawn pawn
 * @return						Returns the spawned pawn
 */
function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local Rotator StartRotation;
	local GPPlayerReplicationInfo GPPlayerReplicationInfo;

	// Don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	// Check incoming variables
	if (NewPlayer != None)
	{
		// Grab the player replication info and check if the player has assigned a class archetype
		GPPlayerReplicationInfo = GPPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo);
		if (GPPlayerReplicationInfo != None && GPPlayerReplicationInfo.ClassArchetype != None)
		{
			// Spawn and return the pawn
			return Spawn(GPPlayerReplicationInfo.ClassArchetype.PawnArchetype.Class,,, StartSpot.Location, StartRotation, GPPlayerReplicationInfo.ClassArchetype.PawnArchetype);
		}
	}

	// Abort if the default pawn archetype is none
	if (DefaultPawnArchetype == None)
	{
		return None;
	}

	// Spawn and return the pawn
	return Spawn(DefaultPawnArchetype.Class,,, StartSpot.Location, StartRotation, DefaultPawnArchetype);
}

/** 
 * Return the 'best' player start for this player to start from.
 * @param		Player				The controller for whom we are choosing a playerstart
 * @param		InTeam				This specifies the Player's team (if the player hasn't joined a team yet)
 * @param		IncomingName		Thisspecifies the tag of a teleporter to use as the Playerstart
 * @returns							Returns the NavigationPoint chosen as player start (usually a PlayerStart)
 */
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string IncomingName)
{
	local PlayerStart PlayerStart;

	ForEach WorldInfo.AllNavigationPoints(class'PlayerStart', PlayerStart)
	{
		// Ensure that the player start is on the same team
		if (PlayerStart.TeamIndex != InTeam)
		{
			continue;
		}

		// Ensure that the player start is enabled
		if (!PlayerStart.bEnabled)
		{
			continue;
		}

		return PlayerStart;
	}

	return Super.FindPlayerStart(Player, InTeam, IncomingName);
}

/**
 * First make sure pawn properties are back to default, then give mutators an opportunity to modify them
 *
 * @param		PlayerPawn			Pawn to reset back to defaults
 */
function SetPlayerDefaults(Pawn PlayerPawn)
{
	local GPPlayerReplicationInfo GPPlayerReplicationInfo;

	PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
	PlayerPawn.WaterSpeed = PlayerPawn.Default.WaterSpeed;
	PlayerPawn.AirSpeed = PlayerPawn.Default.AirSpeed;
	PlayerPawn.Acceleration = PlayerPawn.Default.Acceleration;
	PlayerPawn.AccelRate = PlayerPawn.Default.AccelRate;
	PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;

	// Set the movement speed of the class
	if (PlayerPawn.Controller != None)
	{
		GPPlayerReplicationInfo = GPPlayerReplicationInfo(PlayerPawn.Controller.PlayerReplicationInfo);
		if (GPPlayerReplicationInfo != None)
		{
			PlayerPawn.GroundSpeed = GPPlayerReplicationInfo.ClassArchetype.GroundSpeed;
		}
	}	

	if (BaseMutator != None)
	{
		BaseMutator.ModifyPlayer(PlayerPawn);
	}

	PlayerPawn.PhysicsVolume.ModifyPlayer(PlayerPawn);
}

/** 
 * This is used to reduce damage for teamplay modifications, etc. 
 *
 * @param		Damage				Damage value to use and to modify
 * @param		Injured				Pawn that was injured
 * @param		InstigatedBy		Controller who instigated the damage
 * @param		HitLocation			Where in the world the hit occured
 * @param		Momentum			Momentum value to use and to modify
 * @param		DamageType			Damage type that is being used when dealing damage
 * @param		DamageCauser		Actor that caused the damaged
 */
function ReduceDamage(out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
	local int OriginalDamage;
	
	OriginalDamage = Damage;

	// Check if the Injured pawn is the same pawn controlled by the InstigatedBy (self shot)
	if (InstigatedBy != None && InstigatedBy.Pawn == Injured)
	{
		return;
	}

	// Check if the Injured pawn is on the same team as the InstigatedBy controller
	if (InstigatedBy != None && InstigatedBy.PlayerReplicationInfo != None && InstigatedBy.PlayerReplicationInfo.Team != None && Injured != None && Injured.PlayerReplicationInfo != None && Injured.PlayerReplicationInfo.Team == InstigatedBy.PlayerReplicationInfo.Team)
	{
		Damage = 0;
		return;
	}

	// If the injured pawn is in the neutral zone or in god mode, then there is no damage
	if (injured.PhysicsVolume.bNeutralZone || injured.InGodMode())
	{
		Damage = 0;
		return;
	}

	// Allow mutators to modify the damage
	if (BaseMutator != None)
	{
		BaseMutator.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
	}
}

/**
 * Called when a player is killed.
 *
 * @param		Killer				The controller who killed another controller
 * @param		KilledPlayer		The controller who was killed
 * @param		KilledPawn			The pawn that was killed
 * @param		DamageType			The damage type that was used to do the damage, which killed the pawn
 */
function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> DamageType)
{
	if( KilledPlayer != None && KilledPlayer.bIsPlayer )
	{
		KilledPlayer.PlayerReplicationInfo.IncrementDeaths();
		KilledPlayer.PlayerReplicationInfo.SetNetUpdateTime(FMin(KilledPlayer.PlayerReplicationInfo.NetUpdateTime, WorldInfo.TimeSeconds + 0.3 * FRand()));
		BroadcastDeathMessage(Killer, KilledPlayer, damageType);
	}

	if( KilledPlayer != None )
	{
		ScoreKill(Killer, KilledPlayer);
	}

	GPPlayerReplicationInfo(KilledPawn.PlayerReplicationInfo).PawnInventory = GPInventoryManager(KilledPawn.InvManager);
	GPPlayerReplicationInfo(KilledPawn.PlayerReplicationInfo).LastWeapon = GPInventoryManager(KilledPawn.InvManager).oldweapon.WeaponName;
	
	//DiscardInventory(KilledPawn, Killer);
	NotifyKilled(Killer, KilledPlayer, KilledPawn, damageType);
}

function DiscardInventory( Pawn Other, optional controller Killer )
{
	//local int i;
	//i= 0;
}

DefaultProperties
{
	
	bRestartLevel=false
	bDelayedStart=false 
	HUDType=class'GPHUD'
	PlayerControllerClass=class'GPPlayerController'
	PlayerReplicationInfoClass=class'GPPlayerReplicationInfo'
	DefaultPawnClass=class'GPPlayerPawn'
	DefaultPawnArchetype=GPPlayerPawn'GP_Archetypes.Pawns.GPPlayerPawn'

	PlayingBaseSound = true;
	PlayingTensionSound = false;

	Begin Object Class=AudioComponent Name=Water
		SoundCue=SoundCue'Music.Ambient.buceo01_Cue';  
	End Object
	WaterSound = Water
}
