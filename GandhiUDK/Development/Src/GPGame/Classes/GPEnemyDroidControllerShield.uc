class GPEnemyDroidControllerShield extends GPEnemyDroidController;

// Propias (van dentro de AIProperties que no hemos hecho)
var bool bPlayerCanBeHurt;

/**
 * Called when the controller possess's a pawn.
 *
 * @param		inPawn					Pawn that the controller is possessing
 * @param		bVehicleTransition		True if this is a transition into a vehicle
 * @network		Server
 */
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	local GPPatrolZone PatrolZone;
	
	Super.Possess(inPawn, bVehicleTransition);

	if (Pawn != None)
	{
		// Ponemos el primer punto de desplazamiento para el droide en su patrulla
		PatrolZone = DroidPawn.PatrolZ;
		// Set the enemy location as the focal point
		SetFocalPoint(PatrolZone.PatrolPoints[DroidPawn.PZindex].Location);
		// Set the path finding final destination
		NavigationHandle.SetFinalDestination(PatrolZone.PatrolPoints[DroidPawn.PZindex].Location);
		// Set the current enemy as the destination
		SetDestinationPosition(PatrolZone.PatrolPoints[DroidPawn.PZindex].Location);
		if (!IsInState('Moving'))
		{
			GotoState('Moving');
		}

		// Start the what to do timer
		SetTimer(0.05f, true, NameOf(WhatToDo));
	}
}

/**
 * Called everytime this actor is updated.
 *
 * @param		DeltaTime			Time since the last update
 * @network		Server
 */
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
}

function PutShieldDown()
{
	GPEnemyDroidPawnShield(Pawn).bIsCovering = false;
}

/**
 * Notification from pawn that it has received damage via TakeDamage().
 *
 * @param		InsitgatedBy		Controller that dealt damage to this controller's pawn
 * @param		HitLocation			Where in the world the controller's pawn was hit
 * @param		Damage				How much damage was taken
 * @param		DamageType			Damage type done to the pawn
 * @param		Momentum			How much momentum was transferred to the pawn
 */
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

			if (!IsInState('Attacking'))
			{
				GotoState('Attacking');
			}

			// Avisamos al resto de enemigos
			WarnEnemies(InstigatedBy.Pawn);

			// Empezamos a cubrirnos
			if (GPEnemyDroidPawnShield(Pawn).bIsCovering == false)
			{ 
				GPEnemyDroidPawnShield(Pawn).bIsCovering = true;
				SetTimer(3.f, false, NameOf(PutShieldDown));
			}
		}
	}
}

/** React to the warning **/
function SetWarned(Pawn PwnGandhi)
{
	CurrentEnemy = PwnGandhi;
	SetFocalPoint(PwnGandhi.Location);
	//// Set the path finding final destination
	//NavigationHandle.SetFinalDestination(CurrentEnemy.Location);
	SetDestinationPosition(PwnGandhi.Location);
	if (!IsInState('Attacking'))
	{
		GotoState('Attacking');
	}
}

/** Warn enemies in the same PatrolZone **/
function WarnEnemies(Pawn PwnGandhi)
{
	local GPEnemyDroidPawn P;
	local GPPatrolZone PZ;
	PZ = GPEnemyDroidPawn(Pawn).PatrolZ;

	foreach PZ.Droids(P)
	{
		GPEnemyDroidController(P.Controller).SetWarned(PwnGandhi);
	}
}

/**
 * A looping timer in which the bot decides what to do next.
 *
 * @network		Server
 */
function WhatToDo()
{
	local GPFX_SphereShieldGandhi GPShield;
	local GPPlayerPawn GPPawn;
	local GPPatrolZone PatrolZone;
	local array<GPPlayerPawn> PotentialEnemies;
	local Vector PawnDirection, ActorToPawnDirection;
	local int i;
	local float EnemyRating, BestEnemyRating;

	local int index;

	SightAngle = 90*UnrRotToDeg;

	// Check that I have a pawn
	if (Pawn == None)
	{
		return;
	}

	if (bParalyzed)
		return;

	// ==================
	// Handle enemy logic
	// ==================
	// Evaluate the current enemy reference
	if (CurrentEnemy != None)
	{
		GPPawn = GPPlayerPawn(CurrentEnemy);
		// If the enemy has no health or we have no line of sight, then reset the enemy reference
		if (GPPawn != None && (GPPawn.Health <= 0 || !FastTrace(GPPawn.Location, Pawn.Location,, true)))
		{
			CurrentEnemy = None;
		}
	}

	// Check if there is anyone within my vision to attack
	if (CurrentEnemy == None)
	{
		PawnDirection = Vector(Pawn.Rotation);
		ForEach VisibleCollidingActors(class'GPPlayerPawn', GPPawn, SightRadius, Pawn.Location, true,, true)
		{
			// Check if the pawn is within my sight cone
			ActorToPawnDirection = Normal(GPPawn.Location - Pawn.Location);
			
			if (PawnDirection dot ActorToPawnDirection >= SightAngle)
			{
				PotentialEnemies.AddItem(GPPawn);
			}
			
		}

		// Evaluate the list of potential enemies
		if (PotentialEnemies.Length > 0)
		{
			for (i = 0; i < PotentialEnemies.Length; ++i)
			{
				EnemyRating = 1.f / VSizeSq(PotentialEnemies[i].Location - Pawn.Location);
				if (CurrentEnemy == None || EnemyRating > BestEnemyRating)
				{
					CurrentEnemy = PotentialEnemies[i];
					BestEnemyRating = EnemyRating;
				}
			}
		}
	}

	// Check if enemy is nearby
	if (CurrentEnemy == None)
	{
		if (VSize(Gandhi.Location-Pawn.Location) < DetectDistance)
		{
			CurrentEnemy = Gandhi;
		}
	}

	// Check if enemy is using shield
	if (CurrentEnemy == None)
	{
		PawnDirection = Vector(Pawn.Rotation);
		ForEach VisibleCollidingActors(class'GPFX_SphereShieldGandhi', GPShield, SightRadius, Pawn.Location, true,, true)
		{
			// Check if the pawn is within my sight cone
			ActorToPawnDirection = Normal(GPShield.Location - Pawn.Location);
			
			if (PawnDirection dot ActorToPawnDirection >= SightAngle)
			{
				PotentialEnemies.AddItem(GPPlayerPawn(GPShield.Owner));
				CurrentShield = GPShield;
			}
			
		}

		// Evaluate the list of potential enemies
		if (PotentialEnemies.Length > 0)
		{
			for (i = 0; i < PotentialEnemies.Length; ++i)
			{
				EnemyRating = 1.f / VSizeSq(PotentialEnemies[i].Location - Pawn.Location);
				if (CurrentEnemy == None || EnemyRating > BestEnemyRating)
				{
					CurrentEnemy = PotentialEnemies[i];
					BestEnemyRating = EnemyRating;
				}
			}
		}
	}

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
			GotoState('Attacking');
		}

		// Avisamos al resto de enemigos
		WarnEnemies(Pawn(CurrentEnemy));

		return;
	}

	// ============
	// Handle tasks
	// ============
	// No hemos encontrado enemigo, seguimos en la patrulla
	if (CurrentEnemy == None || VSize(Gandhi.Location - Pawn.Location) > SightRadius)
	{
		index = DroidPawn.PZindex;

		PatrolZone = DroidPawn.PatrolZ;
		if(PatrolZone.PatrolPoints.Length > 0 && HasReachedDestination(PatrolZone.PatrolPoints[DroidPawn.PZindex].Location))
		{
			//MoveToward(PatrolZone.PatrolPoints[PatrolZone.index], ,	20.f, true);
			// Set the enemy location as the focal point
			DroidPawn.PZindex++;
			if (DroidPawn.PZindex >= PatrolZone.PatrolPoints.Length) DroidPawn.PZindex = 0;
		}

		SetFocalPoint(PatrolZone.PatrolPoints[index].Location);
		// Set the path finding final destination
		NavigationHandle.SetFinalDestination(PatrolZone.PatrolPoints[DroidPawn.PZindex].location);
		// Set the current enemy as the destination
		SetDestinationPosition(PatrolZone.PatrolPoints[DroidPawn.PZindex].Location);
		
		if (!IsInState('Moving'))
			GotoState('Moving');
	}

	// Set the movement physics
	if (Pawn.Physics != PHYS_Walking)
	{
		Pawn.SetMovementPhysics();
	}
}

/**
 * Generates a path in the navigation mesh to a location.
 *
 * @param		Goal					Location in the world to path find to
 * @param		WithinDistance			How accurate the path finding needs to be
 * @param		bAllowPartialPath		Returns true even though the path finder only finds part of the path
 * @return								Returns true if a path was found
 */
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

/**
 * Checks if the bot is able to directly go to a destination.
 *
 * @return		Returns true if the boti s able to directly go to a destination
 * @network		Server
 */
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

/**
 * Returns true if the AI has reached the final destination.
 *
 * @param		Destination			A position in the world to check if the AI has reached there
 * @param		CheckDistance		Distance radius for the check to be valid
 * @return							Returns true if the controller's pawn is close enough to the destination
 * @network							Server
 */
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

/**
 * In this state, the AI is moving to a location
 *
 * @network			Server
 */
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

/**
 * In this state, the AI is attacking an actor
 *
 * @network			Server
 */
state Attacking
{
	function bool ShortAttackFinished()
	{
		bPlayerCanBeHurt = true;
		return true;
	}

	function bool CanShortAttackEnemy()
	{
		local int Distance;
		local GPEnemyDroidPawnShield GPEDPS;
		local Vector PawnDirection, ActorToPawnDirection, HitLocation, HitNormal;
		local Actor HitActor;
		
		Distance = 100;

		GPEDPS = GPEnemyDroidPawnShield (Pawn);

		if (Pawn == None || Pawn.Health <= 0 || !GPEDPS.bHasShield)
		{
			return false;
		}

		if (CurrentEnemy == None)
		{
			return false;
		}

		// Check distance
		if (VSizeSq(Pawn.Location - CurrentEnemy.Location) > Square(Distance))
		{
			return false;
		}

		// Check if the AI is aiming at the enemy
		PawnDirection = Vector(Pawn.Rotation);
		ActorToPawnDirection = Normal(CurrentEnemy.Location - Pawn.Location);
		if (PawnDirection dot ActorToPawnDirection < (45*UnrRotToDeg))
		{
			return false;
		}

		// Check if this AI has line of sight 
		HitActor = Pawn.Trace(HitLocation, HitNormal, Pawn.Location + PawnDirection * Distance, Pawn.Location, true,,, TRACEFLAG_Bullet);
		if (HitActor != CurrentEnemy)
		{
			return false;
		}

		return true;
	}

	/**
	 * Returns true if the weapon will hit the enemy or not
	 *
	 * @return			Returns true if the weapon will hit the enemy or not 
	 * @network			Server
	 */
	function bool CanAttackEnemy()
	{
		local GPWeapon GPWeapon;
		local Vector PawnDirection, ActorToPawnDirection, HitLocation, HitNormal;
		local Actor HitActor;

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
		GPWeapon = GPWeapon(Pawn.Weapon);
		if (GPWeapon == None || VSizeSq(Pawn.Location - CurrentEnemy.Location) > Square(GPWeapon.GetFireModeRange(0)))
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

		// Check if this AI has line of sight 
		HitActor = Pawn.Trace(HitLocation, HitNormal, Pawn.Location + PawnDirection * GPWeapon.GetFireModeRange(0), Pawn.Location, true,,, TRACEFLAG_Bullet);
		if (HitActor != CurrentEnemy && HitActor != CurrentShield)
		{
			return false;
		}

		// Check if the pawn is covering
		if (GPEnemyDroidPawnShield(Pawn).bIsCovering)
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
CanAttackEnemy:	
	// Check if this AI is near enough to hit enemy with bodycombat
	if (CanShortAttackEnemy())
	{
		bPreciseDestination = false;

		//Play the anim
		GPEnemyDroidPawnShield(Pawn).FullBodyAnimSlot.PlayCustomAnim('Droide2_Idle_frontattack', 1.0);
		// Make damage
		if (bPlayerCanBeHurt)
		{
			GPPlayerPawn(Pawn(CurrentEnemy)).TakeDamage(50, self, CurrentEnemy.Location, Vect(1,1,1),class'UTDmgType_Lava'); 
			bPlayerCanBeHurt = false;
			SetTimer(1.f, false, NameOf(ShortAttackFinished));
		}

		Sleep(0.f);
		Goto('Begin');
	}
	// Check if this AI can attack the enemy
	else if (CanAttackEnemy())
	{	
		// Stop movement
		bPreciseDestination = false;

		// If the weapon is not firing, then start firing now
		if (!Pawn.Weapon.IsFiring())
		{
			if (bCanShoot)
			{
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

defaultproperties
{
	//AIProperties=AssaultAIProperties'AssaultGame_Engine_Resources.AI.AIProperties'
	bIsPlayer=true
	bPlayerCanBeHurt = true;
}