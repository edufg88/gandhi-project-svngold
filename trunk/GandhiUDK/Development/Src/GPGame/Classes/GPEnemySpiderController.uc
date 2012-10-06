class GPEnemySpiderController extends GPBaseAIController;

var bool bCanJump;
// The next move location for the AI
var Vector NextMoveLocation;
// The current enemy for the AI
var Actor CurrentEnemy;
var Actor CurrentShield;

var float SightAngle;

var GPEnemySpiderPawn GPSpider;
var bool bParalyzed;
/**
 * Called when this actor is first instanced into the world.
 *
 * @network		Server
 */
event PostBeginPlay()
{
	Super.PostBeginPlay();	
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
		}
	}
}

/**
 * Called when the controller possess's a pawn.
 *
 * @param		inPawn					Pawn that the controller is possessing
 * @param		bVehicleTransition		True if this is a transition into a vehicle
 * @network		Server
 */
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	//local GPSpiderZone SpiderZone;

	Super.Possess(inPawn, bVehicleTransition);

	GPSpider = GPEnemySpiderPawn(inPawn);

	if (Pawn != None)
	{
		// Ponemos el primer punto de desplazamiento para el droide en su patrulla
		//WARNING SPIDERZONE NO SE USA NUNCA
		//SpiderZone = GPEnemySpiderPawn(Pawn).SpiderZ;
		// Set the enemy location as the focal point
		SetFocalPoint(GPSpider.SpiderZ.SpiderPoints[GPSpider.SZIndex].Location);
		// Set the path finding final destination
		NavigationHandle.SetFinalDestination(GPSpider.SpiderZ.SpiderPoints[GPSpider.SZIndex].Location);
		// Set the current enemy as the destination
		SetDestinationPosition(GPSpider.SpiderZ.SpiderPoints[GPSpider.SZIndex].Location);
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


/** React to the warning **/
function SetWarned(Pawn PwnGandhi)
{
	CurrentEnemy = PwnGandhi;
	SetFocalPoint(PwnGandhi.Location);
	SetDestinationPosition(PwnGandhi.Location);
	if (!IsInState('Attacking'))
	{
		GotoState('Attacking');
	}
}

///** Warn enemies in the same PatrolZone **/
function WarnEnemies(Pawn PwnGandhi)
{
	local GPGame Game;
	local GPEnemySpiderPawn P;
	local GPSpiderZone SZ;
	SZ = GPEnemySpiderPawn(Pawn).SpiderZ;

	foreach SZ.Spiders(P)
	{
		GPEnemySpiderController(P.Controller).SetWarned(PwnGandhi);
	}

	// Metemos sonido de tensión
	Game = GPGame(WorldInfo.Game);
	if (!Game.PlayingTensionSound)
	{
		GPEnemySpiderPawn(self.Pawn).SoundZ.PlayTension();
		Game.PlayingTensionSound = true;
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
	local GPSpiderZone SpiderZone;
	local array<GPPlayerPawn> PotentialEnemies;
	local Vector PawnDirection, ActorToPawnDirection;
	local int i;
	local float EnemyRating, BestEnemyRating;

	SightAngle = 90*UnrRotToDeg;

	// Check that I have a pawn
	if (Pawn == None)
	{
		return;
	}
	if (bParalyzed)
	{
		return;
	}
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
		ForEach VisibleCollidingActors(class'GPPlayerPawn', GPPawn, 1500, Pawn.Location, true,, true)
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

	// Check if enemy is using shield
	if (CurrentEnemy == None)
	{
		PawnDirection = Vector(Pawn.Rotation);
		ForEach VisibleCollidingActors(class'GPFX_SphereShieldGandhi', GPShield, 1500, Pawn.Location, true,, true)
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
	if (CurrentEnemy == None)
	{
		SpiderZone = GPEnemySpiderPawn(Pawn).SpiderZ;
		if(SpiderZone.SpiderPoints.Length > 0 && HasReachedDestination(GPSpider.SpiderZ.SpiderPoints[GPSpider.SZIndex].Location))
		{
			// Set the enemy location as the focal point
			GPSpider.SZIndex++;
			if (GPSpider.SZIndex >= GPSpider.SpiderZ.SpiderPoints.Length) GPSpider.SZIndex = 0;
			SetFocalPoint(GPSpider.SpiderZ.SpiderPoints[GPSpider.SZIndex].Location);
			// Set the path finding final destination
			NavigationHandle.SetFinalDestination(GPSpider.SpiderZ.SpiderPoints[GPSpider.SZIndex].Location);
			// Set the current enemy as the destination
			SetDestinationPosition(GPSpider.SpiderZ.SpiderPoints[GPSpider.SZIndex].Location);
		
			if (!IsInState('Moving'))
				GotoState('Moving');
		}
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
	/**
	 * Returns true if the weapon will hit the enemy or not
	 *
	 * @return			Returns true if the weapon will hit the enemy or not 
	 * @network			Server
	 */
	function bool CanAttackEnemy()
	{
		local int Distance;
		// WARNINGS UNREFERENCED
		//local Vector PawnDirection, ActorToPawnDirection, HitLocation, HitNormal;
		//local Actor HitActor;
	
		Distance  = 200;

		// Check that the pawn is still valid
		if (Pawn == None || Pawn.Health <= 0 )
		{
			return false;
		}

		// Check that the enemy is still valid
		if (CurrentEnemy == None)
		{
			return false;
		}

		// Check distance
		if (VSizeSq(Pawn.Location - CurrentEnemy.Location) > Square(Distance))
		{
			return false;
		}

		//// Check if the AI is aiming at the enemy
		//PawnDirection = Vector(Pawn.Rotation);
		//ActorToPawnDirection = Normal(CurrentEnemy.Location - Pawn.Location);
		//if (PawnDirection dot ActorToPawnDirection < GPWeapon.GetAttackAngle(0))
		//{
		//	return false;
		//}

		//// Check if this AI has line of sight 
		//HitActor = Pawn.Trace(HitLocation, HitNormal, Pawn.Location + PawnDirection * GPWeapon.GetFireModeRange(0), Pawn.Location, true,,, TRACEFLAG_Bullet);
		//if (HitActor != CurrentEnemy)
		//{
		//	return false;
		//}

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

	function CheckJump()
	{
		bCanJump = true;
	}

	function Attack() 
	{
		local Vector jump;
		Pawn.SuggestJumpVelocity(jump, CurrentEnemy.Location, Pawn.Location);
		Pawn.Velocity = jump;
		Pawn.DoJump(true);
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
	// Check if this AI can attack the enemy
	if (CanAttackEnemy())
	{	
		// Stop movement
		bPreciseDestination = false;

		// Jump towards enemy
		if (bCanJump)
		{
			Attack();
			bCanJump = false;
			SetTimer(1.0f, false, NameOf(CheckJump));
		}

		//// If the weapon is not firing, then start firing now
		//if (!Pawn.Weapon.IsFiring())
		//{
		//	Pawn.Weapon.StartFire(0);
		//}

		// Loop back to begin
		Sleep(0.f);
		Goto('Begin');
	}
	// Can't attack the enemy, if we're still firing then stop firing
	//else if (Pawn.Weapon.IsFiring())
	//{
	//	Pawn.Weapon.StopFire(0);
	//}
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

function SetRagdoll()
{
	GPEnemySpiderPawn(Pawn).SetRagdoll();
	Pawn.Mesh.AddImpulse((Normal(Pawn.Location-Gandhi.Location))*200, Pawn.Location);
}

function UnSetRagdoll()
{
	GPEnemySpiderPawn(Pawn).UnSetRagdoll();
	bParalyzed=false;
}

state Paralyzed
{
	event BeginState(Name PreviousStateName)
	{
		bParalyzed = true;

		if (GPSpider == None)
		{
			GPSpider = GPEnemySpiderPawn(Pawn);
		}
	}

	Begin:
		SetTimer(2.f, false, NameOf(SetRagdoll));
		SetTimer(5.f, false, NameOf(UnSetRagdoll));
		GotoState('Attacking');
		
}


defaultproperties
{
	//AIProperties=AssaultAIProperties'AssaultGame_Engine_Resources.AI.AIProperties'
	bIsPlayer=true
	bCanJump=true
	bParalyzed=false;
}