class GPBossController extends GPBaseAIController;

var float SightRadius;
var float SightAngle;
var float DetectDistance;
var float AttackDistance;
var float RunDistance;

var bool hasShield;
var GPFX_SphereShieldEnemy Shield;

//var GPPatrolZone PatrolZone;
var GPDroidZone DroidZone;
var GPEnemyDroidPawn DroidPawn;

// The next move location for the AI
var Vector NextMoveLocation;
// The current enemy for the AI
var Actor CurrentEnemy;
var Actor CurrentShield;

var bool EnergyEnabled;
var float ROF;
var bool bCanShoot;
var bool bOnTheFloor; // Como Jeniffer Lopez
var bool bChange;

//

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	// Reassign the pawn as my enemy if it is on a different team
	if (InstigatedBy != None && InstigatedBy.Pawn != None)
	{
		if (InstigatedBy.IsA('GPPlayerController'))
		{
			Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);

			// Set the current enemy
			CurrentEnemy = InstigatedBy.Pawn;

			// Set the enemy location as the focal point
			SetFocalPoint(CurrentEnemy.Location);

			// Set the current enemy as the destination
			SetDestinationPosition(CurrentEnemy.Location);

			if (!IsInState('Attacking') && !bOnTheFloor)
			{
				GotoState('Attacking');
			}

			if (Pawn.Health % 1000 > 500 && bChange)
			{
				//bOnTheFloor = true;
				GPBossPawn(Pawn).FullBodyAnimSlot.PlayCustomAnim('theBoss_damageTaken_03', 1.f);
				//SetTimer(3.f, false, NameOf(GetUp));
				bChange = false;
			}
			else if (Pawn.Health % 1000 < 500 && !bChange)
			{
				bChange = true;
			}
		}
	}
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	Super.Possess(inPawn, bVehicleTransition);

	if (Pawn != None)
	{
		if (!IsInState('Moving'))
		{
			GotoState('Moving');
		}

		// Start the what to do timer
		SetTimer(0.05f, true, NameOf(WhatToDo));

		AttachPower();
		AttachWeaponPower();
		DisablePower();
		DisableWeaponPower();
	}
}

function Tick(float DeltaTime)
{
	local Rotator NewRotation;

	Super.Tick(DeltaTime);

	// Update the facing rotation of the pawn
	if (Pawn != None)
	{
		NewRotation = RLerp(Pawn.Rotation, Rotator(GetFocalPoint() - Pawn.Location), FClamp(8.125f * DeltaTime, 0.f, 1.f), true);
		Pawn.FaceRotation(NewRotation, DeltaTime);
	}

	GetGandhi();
}

function AttachPower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);

	if (BP.EnergyPS != None && BP.Mesh != None)
	{		
		if (BP.Mesh.GetSocketByName(BP.EnergySocketName) != None)
		{
			BP.EnergyPS = Worldinfo.MyEmitterPool.SpawnEmitterCustomLifetime(ParticleSystem'theBossAttacks_FX.ParticleSystems.PS_BossTornado', false);
			BP.EnergyPS.SetAbsolute(false,false,false);
			BP.EnergyPS.bUpdateComponentInTick = true;
			BP.EnergyPS.SetTickGroup(TG_EffectsUpdateWork);
			// Attach the weapon mesh to the instigator's skeletal mesh
			BP.Mesh.AttachComponentToSocket(BP.EnergyPS, BP.EnergySocketName);
		}
	}
}

function AttachWeaponPower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);

	if (BP.EnergyWeaponPS != None && BP.Mesh != None)
	{		
		if (BP.Mesh.GetSocketByName('WeaponPoint') != None)
		{
			BP.EnergyPS = Worldinfo.MyEmitterPool.SpawnEmitterCustomLifetime(ParticleSystem'theBossAttacks_FX.ParticleSystems.PS_energyAccumulation', false);
			BP.EnergyPS.SetAbsolute(false,false,false);
			BP.EnergyPS.bUpdateComponentInTick = true;
			BP.EnergyPS.SetTickGroup(TG_EffectsUpdateWork);
			// Attach the weapon mesh to the instigator's skeletal mesh
			BP.Mesh.AttachComponentToSocket(BP.EnergyWeaponPS, 'WeaponPoint');
		}
	}
}

function DetachPower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);

	if (BP.Mesh != None)
	{
		if (BP.mesh.GetSocketByName(BP.EnergySocketName) != None)
		{
			BP.DetachComponent(BP.EnergyPS);
		}
	}
}

function DetachWeaponPower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);

	if (BP.Mesh != None)
	{
		if (BP.mesh.GetSocketByName('WeaponPoint') != None)
		{
			BP.DetachComponent(BP.EnergyWeaponPS);
		}
	}
}

function EnablePower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);
	BP.EnergyPS.ActivateSystem();
	BP.EnergyWeaponPS.ActivateSystem();
	EnergyEnabled = true;
}

function EnableWeaponPower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);
	BP.EnergyWeaponPS.ActivateSystem();
}

function DisablePower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);
	BP.EnergyPS.DeactivateSystem();
	//BP.EnergyWeaponPS.DeactivateSystem();
	EnergyEnabled = false;
}

function DisableWeaponPower()
{
	local GPBossPawn BP;
	BP = GPBossPawn(Pawn);
	BP.EnergyWeaponPS.DeactivateSystem();
}


function DisableEnergy()
{
	EnergyEnabled = false;
}

function GetUp()
{
	bOnTheFloor = false;
	GPBossPawn(Pawn).FullBodyAnimSlot.PlayCustomAnim('theBoss_damageTaken_03_Raise', 1.f);
	GoToState('Attacking');
}

function WhatToDo()
{
	SightAngle = 90*UnrRotToDeg;

	// Check that I have a pawn
	if (Pawn == None)
	{
		return;
	}

	if (bOnTheFloor)
	{
		if (!IsInState('Down'))
			GotoState('Down');
		return;
	}

	// No tenemos lógica, el Boss siempre sabrá donde está Gandhi.
	if (Gandhi == None)
		GetGandhi();
	CurrentEnemy = Gandhi;

	// If an enemy was found, go to the Attacking state
	if (CurrentEnemy != None)
	{
		// Set the enemy location as the focal point
		SetFocalPoint(CurrentEnemy.Location);

		// Set the path finding final destination
		NavigationHandle.SetFinalDestination(CurrentEnemy.Location);

		// Set the current enemy as the destination
		SetDestinationPosition(CurrentEnemy.Location);

		// Go to the attack state if not already there
		if (!IsInState('Attacking'))
		{
			if (!EnergyEnabled)
			{
				EnablePower();
				GPBossPawn(Pawn).TopHalfAnimSlot.PlayCustomAnim('theBoss_energyAccumulation_01', 1.f, ,,false);
				SetTimer(3.f, false, NameOf(DisablePower));
				//SetTimer(12.f, false, NameOf(DisableEnergy));
			}
			
			GotoState('Attacking');
		}

		return;
	}

	// ============
	// Handle tasks
	// ============

	// Set the movement physics
	if (Pawn.Physics != PHYS_Walking)
	{
		Pawn.SetMovementPhysics();
	}
}

function bool GeneratePathTo(Vector Goal, optional float WithinDistance, optional bool bAllowPartialPath)
{
	if (NavigationHandle == None)
	{
		 return false;
	}

	// Set up the path finding
	class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, Goal);
	class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Goal, WithinDistance, bAllowPartialPath);
	// Perform the path finding
	return NavigationHandle.FindPath();
}

function bool CanDirectlyReachDestination()
{
	local Vector PathingExtent;

	// Ensure that the pawn exists
	if (Pawn == None || Pawn.Health <= 0)
	{
		return false;
	}

	// Check that there is no obstacles in the way by performing a fast trace
	PathingExtent.X = Pawn.GetCollisionRadius();
	PathingExtent.Y = 1.f;
	PathingExtent.Z = 1.f;

	// If the fast trace returned false, then return false
	if (!FastTrace(GetDestinationPosition(), Pawn.Location, PathingExtent))
	{
		return false;
	}

	return true;
}

function bool HasReachedDestination(optional Vector Destination = GetDestinationPosition(), optional float CheckDistance = Pawn.GetCollisionRadius())
{
	// Ensure that the pawn exists
	if (Pawn == None || Pawn.Health <= 0)
	{
		return false;
	}

	// Check that the pawn is within distance
	return VSizeSq2D(Pawn.Location - Destination) <= Square(CheckDistance);
}

state Down
{
	Begin:  
		Sleep(3.f);
		GotoState('');
}

state Moving
{
Begin:
	// Check if the pawn exists and isn't dead
	if (Pawn == None || Pawn.Health <= 0)
	{
		GotoState('Dead');
	}

	// Check that our pawn is able to move around on the ground, if not loop back to the beginning
	if (Pawn.Physics != PHYS_Walking)
	{
		Pawn.SetMovementPhysics();
		bPreciseDestination = false;
		Sleep(0.f);         
		Goto('Begin');
	}

	// Comprobamos si tenemos que correr o andar
	if (VSizeSq2D(Pawn.Location - CurrentEnemy.Location) > Square(RunDistance))
	{
		Pawn.GroundSpeed = 300;
	}
	else
	{
		Pawn.GroundSpeed = 180;
	}

MoveDirect:
	// Check if the pawn can directly reach the destination
	if (CanDirectlyReachDestination())
	{
		// Set the focal point so that the pawn looks there
		SetFocalPoint(GetDestinationPosition());

		// Move to the destination position
		bPreciseDestination = true;

		// Check if we've reached the destination
		Goto('HasReachedDestination');
	}
MoveViaPathing:
	// Generate a path and set the next move location
	if (GeneratePathTo(NavigationHandle.FinalDestination.Position, Pawn.GetCollisionRadius(), true) && NavigationHandle.GetNextMoveLocation(NextMoveLocation, Pawn.GetCollisionRadius()))
	{
		// Set the destination position
		SetDestinationPosition(NextMoveLocation);

		// Set the focal point so that the pawn looks there
		SetFocalPoint(GetDestinationPosition());

		// Move to the destination position
		bPreciseDestination = true;

		// Go back to the beginning
		Sleep(0.f);
		Goto('Begin');
	}
	else
	{
		// Could not generate path, go straight to the end
		Goto('End');
	}
HasReachedDestination:
	// Check if we've reached the destination, if we haven't then go back to the beginning
	if (!HasReachedDestination())
	{
		// Go back to the beginning
		Sleep(0.f);
		Goto('Begin');
	}
	// We've reached the current destination, check if we've reached the final desination
	else if (!HasReachedDestination(NavigationHandle.FinalDestination.Position))
	{	
		// Set the focal position
		SetFocalPoint(GetDestinationPosition());

		// Set the destination position
		SetDestinationPosition(NavigationHandle.FinalDestination.Position);

		// Move to the destination position
		bPreciseDestination = true;

		// Go back to the beginning
		Sleep(0.f);
		Goto('Begin');
	}
End:
	// Exit out 
	GotoState('');
}

state Attacking
{
	/**
	 * Returns true if the weapon will hit the enemy or not
	 *
	 * @return			Returns true if the weapon will hit the enemy or not 
	 * @network			Server
	 */
	function bool CanAttackEnemy()
	{
		local GPWeaponBoss GPWeapon;
		local Vector PawnDirection, ActorToPawnDirection;

		// Check that the pawn is still valid
		if (Pawn == None || Pawn.Health <= 0 || Pawn.Weapon == None)
		{
			return false;
		}

		// Check that the enemy is still valid
		if (CurrentEnemy == None)
		{
			return false;
		}

		// Check if the AI is within range with its weapon
		GPWeapon = GPWeaponBoss(Pawn.Weapon);
		if (GPWeapon == None || VSizeSq(Pawn.Location - CurrentEnemy.Location) > Square(AttackDistance))
		{
			return false;
		}

		// Check if the AI is aiming at the enemy
		PawnDirection = Vector(Pawn.Rotation);
		ActorToPawnDirection = Normal(CurrentEnemy.Location - Pawn.Location);
		if (PawnDirection dot ActorToPawnDirection < GPWeapon.GetAttackAngle(0))
		{
			return false;
		}

		return true;
	}

	/**
	 * Called when this state is ending
	 *
	 * @param		NextStateName			Name of the state this actor is going to next
	 * @network		Server
	 */
	event EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		if (Pawn != None && Pawn.Weapon != None && Pawn.Weapon.IsFiring())
		{
			Pawn.Weapon.StopFire(0);
		}
	}

	function CanShootAgain()
	{
		bCanShoot = true;
	}

	function ExecuteShot()
	{
		
	}

Begin:
	// Check if the pawn exists and is valid
	if (Pawn == None || Pawn.Health <= 0)
	{
		GotoState('Dead');
	}

	// Check if the enemy is still valid
	if (CurrentEnemy == None)
	{
		Goto('End');
	}

	// Check that our pawn is able to move around on the ground, if not loop back to the beginning
	if (Pawn.Physics != PHYS_Walking)
	{
		Pawn.SetMovementPhysics();
		bPreciseDestination = false;
		Sleep(0.f);
		Goto('Begin');
	}

	// Comprobamos si tenemos que correr o andar
	if (VSizeSq2D(Pawn.Location - CurrentEnemy.Location) > Square(RunDistance))
	{
		Pawn.GroundSpeed = 350;

		if (!EnergyEnabled)
		{
			EnablePower();
			GPBossPawn(Pawn).TopHalfAnimSlot.PlayCustomAnim('theBoss_energyAccumulation_01', 1.f, ,,false);
			SetTimer(3.f, false, NameOf(DisablePower));
		}
	}
	else
	{
		Pawn.GroundSpeed = 180;
	}
CanAttackEnemy:	
	// Check if this AI can attack the enemy
	if (CanAttackEnemy())
	{	
		// Stop movement
		bPreciseDestination = false;

		// If the weapon is not firing, then start firing now
		if (!Pawn.Weapon.IsFiring())
		{
			if (bCanShoot)
			{
				GPBossPawn(Pawn).TopHalfAnimSlot.PlayCustomAnim('theBoss_walkShot_01', 1.f);
				Sleep(0.5f);
				Pawn.Weapon.StartFire(0);
				Pawn.Weapon.StopFire(0);
				bCanShoot = false;
				SetTimer(ROF, false, NameOf(CanShootAgain));
			}
		}

		// Loop back to begin
		Sleep(0.f);
		Goto('Begin');
	}
	// Can't attack the enemy, if we're still firing then stop firing
	else if (Pawn.Weapon.IsFiring())
	{
		Pawn.Weapon.StopFire(0);
	}
MoveDirect:	
	// Ensure that we still have an enemy
	if (CurrentEnemy != None)
	{
		// Set the destination position to the enemy location
		SetDestinationPosition(CurrentEnemy.Location);
		// Check if we can reach there directly
		if (CanDirectlyReachDestination())
		{
			// Move to the destination position
			bPreciseDestination = true;

			// Look back to begin
			Sleep(0.f);
			Goto('Begin');
		}
	}
	else
	{
		Goto('End');
	}
MoveViaPathing:
	// Generate a path and set the next move location
	if (CurrentEnemy != None)
	{
		if (GeneratePathTo(CurrentEnemy.Location, Pawn.GetCollisionRadius(), true) && NavigationHandle.GetNextMoveLocation(NextMoveLocation, Pawn.GetCollisionRadius()))
		{
			// Set the destination position
			SetDestinationPosition(NextMoveLocation);

			// Set the focal point so that the pawn looks there
			SetFocalPoint(GetDestinationPosition());

			// Move to the destination position
			bPreciseDestination = true;

			// Loop back to begin
			Sleep(0.f);
			Goto('Begin');
		}
		else
		{
			// Could not generate path, go straight to the end
			Goto('End');
		}
	}
End:
	GotoState('');
}

state Charging
{
	Begin:
		//PlayAnimation
		
	End:
	// Exit out 
	GotoState('');
}

DefaultProperties
{
	bIsPlayer=true
	DetectDistance = 500;
	AttackDistance = 800;
	RunDistance = 1200;
	EnergyEnabled=false;
	ROF = 1.f;
	bCanShoot = true;
	bOnTheFloor = false;
	bChange = true;
}
