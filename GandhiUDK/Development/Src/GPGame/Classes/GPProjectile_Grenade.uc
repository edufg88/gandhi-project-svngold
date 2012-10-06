class GPProjectile_Grenade extends GPProjectile;


// Minimum fuse time 
var(Grenade) const float MinFuseTime;
// Maximum fuse time
var(Grenade) const float MaxFuseTime;
// Initial random spin given to the grenade
var(Grenade) const int InitialRandomSpin;
// Addition Z velocity to give when throwing the grenade
var(Grenade) const float TossZ;
// Time in seconds before the bounce sound can next play
var(Grenade) const float BounceSoundInterval;

// Time when the next bounce sound can be played
var ProtectedWrite float NextBounceSoundTime;
// True if this grenade should explode now
var RepNotify bool ExplodeNow;

// Replication block
replication
{
	if (bNetDirty && Role == Role_Authority)
		ExplodeNow;
}

/**
 * Called when the projectile is first initialized
 *
 */
simulated event PostBeginPlay()
{
	local float FuseTime;

	Super.PostBeginPlay();

	// Set the fuse timer if the variables have been set
	if (Role == Role_Authority)
	{
		FuseTime = RandRange(MinFuseTime, MaxFuseTime);
		SetTimer(FuseTime, false, NameOf(ExplodeTimer));		
	}

	// Set the initial random spin
	if (InitialRandomSpin > 0)
	{
		RandSpin(InitialRandomSpin);
	}
}

/**
 * Called when a variable flagged with rep notify is replicated
 *
 * @param			VarName				Name of the variable that was replicated
 */
simulated event ReplicatedEvent(Name VarName)
{
	// Weapon attachment archetype was replicated, update the weapon attachment
	if (VarName == NameOf(ExplodeNow))
	{
		Explode(Location, Vect(0.f, 0.f, 1.f));
	}

	Super.ReplicatedEvent(VarName);
}

/**
 * Initializes the projectile by setting the rotation and velocity of the projectile
 *
 * @param		Direction		Direction the projectile is moving in
 */
function Init(vector Direction)
{
	// Set the rotation the same as the direction
	SetRotation(Rotator(Direction));
	// Set the velocity and give it a little Z kick as well to simulate a toss
	Velocity = Normal(Direction) * Speed;
	Velocity.Z += TossZ + (FRand() * TossZ / 2.f) - (TossZ / 4.f);
}

/**
 * Explode timer
 *
 */
function ExplodeTimer()
{
	// Flag it as exploded
	if (Role == Role_Authority)
	{
		ExplodeNow = true;
	}

	// Explode
	Explode(Location, Vect(0.f, 0.f, 1.f));
}

/**
 * Called when the actor hits the wall
 *
 * @param		HitNormal			Normal direction of the wall
 * @param		Wall				Actor that this actor collided against
 * @param		WallComp			Component that this actor collided against
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = true;

	// Play the bounce sound
	if (WorldInfo.NetMode != NM_DedicatedServer && WorldInfo.TimeSeconds >= NextBounceSoundTime)
	{
		PlaySound(ImpactSound, true);
		NextBounceSoundTime = WorldInfo.TimeSeconds + BounceSoundInterval;
	}

	// Check to make sure we didn't hit a pawn
	if (Pawn(Wall) == None)
	{
		// Reflect off Wall w/damping
		Velocity = 0.75f * ((Velocity dot HitNormal) * HitNormal * -2.f + Velocity);
		Speed = VSize(Velocity);

		if (Velocity.Z > 400.f)
		{
			Velocity.Z = 0.5f * (400.f + Velocity.Z);
		}

		// If we hit a pawn or we are moving too slowly, explod
		if (Speed < 20.f || Pawn(Wall) != None)
		{
			ImpactedActor = Wall;
			SetPhysics(PHYS_None);
		}
	}
	// Hit a different pawn, just explode
	else if (Wall != Instigator)
	{
		Explode(Location, HitNormal);
	}
}

/**
 * Called every time the grenade is updated
 *
 * @param		DeltaTime			Time, in seconds, since the last update
 */
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// Spin the grenade
	if (RotationRate != Rot(0, 0, 0))
	{
		SetRotation(Rotation + (RotationRate * DeltaTime));
	}

	// If the velocity length is reducing, then slow the rotation rate
	if (VSize(Velocity) < 85.f)
	{
		RotationRate = RLerp(RotationRate, Rot(0, 0, 0), 3.125f * DeltaTime);
	}
}

defaultproperties
{	
	bBounce=true
	LifeSpan=0.f
	TossZ=245.f
	bNetTemporary=false
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
}