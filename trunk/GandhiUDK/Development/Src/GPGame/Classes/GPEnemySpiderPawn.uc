class GPEnemySpiderPawn extends GPEnemyPawn
	placeable;

var bool playerCanBeHurt;
var int SpiderDamage;

var(SpiderZone) GPSpiderZone SpiderZ;
var(SpiderZone) int SZIndex;

// Explosion particle effect to play when the pawn has died
var(Pawn) const ParticleSystem ExplosionParticleTemplate;

// EFG: Clase encargada de crear el objeto que soltará el enemigo al morir
//var GPDroppedItemsGenerator DIG;

//simulated event PostBeginPlay()
//{
//	super.PostBeginPlay();
//	DIG = Spawn(class'GPDroppedItemsGenerator');
//}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	Health = 200;
}

// Starts everything to be a real arachnid
function SetArachnid(bool state)
{
	if (state)
	{
		ShouldCrouch(false);
		SetPhysics(PHYS_Spider);
		bCrawler = true;
	}
	else
	{
		SetPhysics(PHYS_Walking);
		ShouldCrouch(false);
		bCrawler = default.bCrawler;
	}
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	local Pawn HitPawn;
	HitPawn = Pawn(Other);
	//`Log ("You Hit!"$Other);

	if(HitPawn != None)
	{
		if( PlayerController(HitPawn.Controller) != None && playerCanBeHurt)
		{
			HitPawn.TakeDamage(SpiderDamage, self.Controller, HitPawn.Location, vect(0,0,0) , class'UTDmgType_Lava');
			playerCanBeHurt = false;
			SetTimer (1.0, true, nameOf(attackFinished));
		}
	}
}

//event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
//{
//	local Rotator rRotation;

//	// Hacemos que pueda empezar a trepar
//	SetArachnid(true);
//	Wall.bCanStepUpOn = true;

//	rRotation = Rotator(HitNormal);
//	rRotation.Pitch = rRotation.Pitch + (90*DegToUnrRot);
//	rRotation.Roll = rRotation.Roll + (180*DegToUnrRot);
//	Mesh.SetRotation(rRotation);
//	SetBase(Wall, HitNormal);
	
//	// Pintar la normal
//	//DrawDebugCone(Location, HitNormal, 100, 0.1, 0.1, 50, MakeColor(255,0,0), true);
//	// Pintar la rotación
//	//DrawDebugCone(Location, Vector(rRotation), 100, 0.1, 0.1, 50, MakeColor(255,0,0), true);
//}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (EventInstigator.IsA('GPPlayerController'))
	{
		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

		if (Health <= 0)
		{
			if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, Location);
			}
		}
	}   

}

simulated function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		// Estamos muertos...
		//GPEnemyDroidController(Controller).GotoState('Dead');
		
		// Modo RagDoll
		SetRagdoll();
		Mesh.AddRadialImpulse(Location, 20.f, 20.f, RIF_Linear, true);
		// Spawn the explosion particle effect
		if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, Location);
		}

		// EFG: Al morir arroja objeto
		ThrowObject();

		// Control de la zona de sonido
		SoundZ.numberEnemies--;
		if (SoundZ.numberEnemies == 0)
		{
			if (GPGame(WorldInfo.Game).PlayingTensionSound)
			{
				SoundZ.StopTension();
				GPGame(WorldInfo.Game).PlayingTensionSound = false;
			}
		}

		return true;
	}

  return false;
}

//event ThrowObject()
//{
//	DIG.DropRandomItem(self.Location);
//}

//After timer expires, player can be hurt again..
function attackFinished()
{
	playerCanBeHurt = true;
	return;
}

defaultproperties
{
	// Iluminación propia de la araña
	Begin Object Class=DynamicLightEnvironmentComponent Name=GPLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	//LightEnvironment=GPLightEnvironment
	Components.Add(GPLightEnvironment)

	Begin Object class=SkeletalMeshComponent Name=GPSpiderSkeletalMesh
		SkeletalMesh=SkeletalMesh'Aracnido.Mesh.SK_Aracnido'
		LightEnvironment=GPLightEnvironment
		PhysicsAsset=PhysicsAsset'Aracnido.Mesh.PA_Aracnido_Physics'
		AnimSets(0)=AnimSet'Aracnido.Mesh.AS_Aracnido'
		AnimTreeTemplate=AnimTree'Aracnido.Mesh.AT_Aracnido' 
		bHasPhysicsAssetInstance=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
	End Object
	DrawScale=25
	mesh = GPSpiderSkeletalMesh
	Components.Add(GPSpiderSkeletalMesh)

	Begin Object Name=CollisionCylinder
		CollisionRadius=16.0
		CollisionHeight=25.0
	End Object
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	ControllerClass=class'GPEnemySpiderController'
	GroundSpeed=300.0
	bCanClimbCeilings = true
	bCanStepUpOn = false
	playerCanBeHurt = true;
	SpiderDamage = 5;
	Health = 25;

	ExplosionParticleTemplate = ParticleSystem'FX_Explosions.ParticleSystems.PS_BaseExplosion';

	bDirectHitWall=true;
	bIgnoreForces=false;

	JumpZ = 400;
}
