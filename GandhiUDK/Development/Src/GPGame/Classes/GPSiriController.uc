class GPSiriController extends AIController;

var Actor target;
var array<Pawn> Enemies;
var() Vector TempDest;
var Pawn Gandhi;
var GPSiriPawn Siri;
var float SiriDistance;
var float TeleportDistance;
var bool shooting;
var float LastShotTime;
var float ShotROFDelay;
var bool isMoving;

// 0: neutro, 1: defensivo, 2: agresivo
var int Modo;

var Vector EscapePoint;

function GetGandhi()
{
	local GPPlayerController PC;

	foreach LocalPlayerControllers(class'GPPlayerController', PC)
	{
		if(PC.Pawn != none)
			Gandhi = PC.Pawn;
	}
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
	GPGame(WorldInfo.Game).SetSiri(self);
}

function Warn(Pawn P)
{
	if (IsInState('PlayerControlled') == false)
	{
		if(shooting) return;
		Enemies.AddItem(P);
		target = P;
	}
}

function PlayerAttacked(Pawn P)
{
	switch (Modo)
	{
		// Neutro
		case 0:
			break;
		// Defensivo
		case 1:
			target = P;
			GotoState('Escape',,true);
			break;
		// Agresivo
		case 2:
			target = P;
			GotoState('Attack',,true);
			break;
	}
}

auto state Idle
{
	event BeginState(Name PreviousStateName)
	{
		GetGandhi();

		isMoving = false;
	}

	event SeePlayer (Pawn Seen)
	{
		super.SeePlayer(Seen);
		target = Seen;

		if (Seen != None && Seen == Gandhi)
		{
			GotoState('Follow',,true);
		}
	}

	event SeeMonster (Pawn Seen)
	{
		if (Seen != None && Seen != Gandhi && Modo == 2)
		{
			Warn(Seen); 
			GotoState('Attack',,true);
		}
		else if (Modo == 1)
		{
			Warn(Seen);
			GotoState('Escape',, true);
		}
	}

	// La distancia la podríamos comprobar en el evento SeePlayer?
	event Tick(float DeltaTime) 
	{
		if(Gandhi != None) 
		{
 			if (VSize(Pawn.Location - Gandhi.Location) > TeleportDistance &&  GPPlayerPawn(Gandhi).IsUnderWater == false)
			{
				Pawn.SetLocation(Gandhi.Location + Vect(100,100,0));
			}
			if(VSize(Pawn.Location - Gandhi.Location) > SiriDistance) 
			{
				target = Gandhi;
				GotoState('Follow',,true);
			}
		}
		else
		{
			GetGandhi();
		}
	}

	Begin:
		isMoving = false;
		Siri = GPSiriPawn(Pawn);
		Siri.DetachJetPS();
}

state Follow
{
	ignores SeePlayer;

	event Tick(float DeltaTime) 
	{
		if(Gandhi != None) 
		{
			if (VSize(Pawn.Location - Gandhi.Location) > TeleportDistance &&  GPPlayerPawn(Gandhi).IsUnderWater == false)
			{
				Pawn.SetLocation(Gandhi.Location + Vect(100,100,0));
			}
		}
	}

	event BeginState(Name PreviousStateName)
	{
		isMoving = true;
	
	}

	event SeeMonster (Pawn Seen)
	{
		if (Seen != None && Seen != Gandhi && Modo == 2)
		{
			Warn(Seen); 
			GotoState('Attack',,true);
		}
		else if (Modo == 1)
		{
			Warn(Seen);
			GotoState('Escape',,true);
		}
	}

	function bool FindNavMeshPath()
	{
		// Clear cache and constraints (ignore recycling for the moment)
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		// Create constraints
		class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Gandhi );
		class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Gandhi, 32 );

		// Find path
		return NavigationHandle.FindPath();
	}


Begin:
	
	// If moving, start Jet Particles
	Siri = GPSiriPawn(Pawn);
	Siri.AttachJetPS();

	// Buscamos a nuestro objetivo
	if( NavigationHandle.ActorReachable(Gandhi) )
	{
		//Direct move
		MoveToward(Gandhi, Gandhi, SiriDistance, true);
	}
	else if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(Gandhi.Location);
		
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
		{
			MoveTo( TempDest, Gandhi );
		}
	}
	else
	{
		GotoState('Idle',,true);
	}
	
	// Si estamos al lado de Gandhi nos paramos
	if(VSize(Pawn.Location - Gandhi.Location) < SiriDistance) 
	{
		GotoState('Idle',,true);
	}
	else 
	{
		goto 'Begin';
	}
}

state Attack
{
	event BeginState(Name PreviousStateName)
	{
		Siri.IsAiming = true;
		shooting = true;
	}

	event EndState(name NextStateName)
	{
		Siri.IsAiming = false;
		shooting = false;
	}

	event Tick(float DeltaTime) 
	{
		super.Tick(DeltaTime);			

		if(shooting) 
		{
			LastShotTime += DeltaTime;

			if(Pawn(target).Health <= 0) 
			{
				Enemies.RemoveItem(Pawn(target));
				if(Enemies.Length > 0) 
				{
					target = Enemies[0];
				}
				else 
				{
					target = Gandhi;
					//shooting = false;
					GotoState('Follow',,true);
				}
			}
			Pawn.SetRotation(Rotator(target.Location - Pawn.Location));
			if(LastShotTime >= ShotROFDelay && target != Gandhi) 
			{
				LastShotTime = 0;
				Pawn.StartFire(0);
				Pawn.StopFire(0);
			}
		}

		if(Gandhi != None) 
		{
			if (VSize(Pawn.Location - Gandhi.Location) > TeleportDistance &&  GPPlayerPawn(Gandhi).IsUnderWater == false)
			{
				Pawn.SetLocation(Gandhi.Location + Vect(100,100,0));
			}
		}
	}

	function bool FindNavMeshPath()
	{
		// Clear cache and constraints (ignore recycling for the moment)
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		// Create constraints
		class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, target );
		class'NavMeshGoal_At'.static.AtActor( NavigationHandle, target, 32 );

		// Find path
		return NavigationHandle.FindPath();
	}

Begin:
	// Buscamos a nuestro objetivo
	if( NavigationHandle.ActorReachable(target) )
	{
		//Direct move
		MoveToward(target, target, SiriDistance, true);
	}
	else if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(target.Location);
		
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
		{
			MoveTo( TempDest, target );
		}
	}
	else
	{
		GotoState('Idle');
	}
	
	goto 'Begin';
}

// Volviendo donde está Gandhi (Gandhi ha llamado a Siri)
state Seek 
{
	ignores SeePlayer, SeeMonster;

	event BeginState(Name PreviousStateName)
	{
		isMoving = true;
	}

	function bool FindNavMeshPath()
	{
		// Clear cache and constraints (ignore recycling for the moment)
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		// Create constraints
		class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Gandhi );
		class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Gandhi, 32 );

		// Find path
		return NavigationHandle.FindPath();
	}


Begin:
	// If moving, start Jet Particles
	Siri = GPSiriPawn(Pawn);
	Siri.AttachJetPS();

	// Buscamos a nuestro objetivo
	if( NavigationHandle.ActorReachable(Gandhi) )
	{
		//Direct move
		MoveToward(Gandhi, Gandhi, SiriDistance, true);
	}
	else if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(Gandhi.Location);
		
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
		{
			MoveTo( TempDest, Gandhi );
		}
	}
	else
	{
		GotoState('Idle',,true);
	}
	
	// Si estamos al lado de Gandhi nos paramos
	if(VSize(Pawn.Location - Gandhi.Location) < SiriDistance) 
	{
		GotoState('Follow',, true);
	}
	else 
	{
		goto 'Begin';
	}
}

state Escape
{
	ignores SeePlayer, SeeMonster;

	function bool FindNavMeshPath()
	{
		// Clear cache and constraints (ignore recycling for the moment)
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		// Create constraints
		class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, EscapePoint);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, EscapePoint, 100);
		// Find path
		return NavigationHandle.FindPath();
	}

	event BeginState(Name PreviousStateName)
	{
		isMoving = true;
		EscapePoint = Normal(Pawn.Location - target.Location) * 200;
	}

Begin:
	// If moving, start Jet Particles
	Siri = GPSiriPawn(Pawn);
	Siri.AttachJetPS();

	if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(EscapePoint);
		
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius() ) )
		{
			MoveTo( TempDest );
		}
	}
	else
	{
		MoveToDirectNonPathPos(EscapePoint);
		//GotoState('Idle',,true);
	}
	
	// Si estamos al lado de Gandhi nos paramos
	if(VSize(Pawn.Location - EscapePoint) < SiriDistance) 
	{
		GotoState('Idle',, true);
	}
	else 
	{
		goto 'Begin';
	}
}

state Stay
{
	event BeginState(Name PreviousStateName)
	{
		isMoving = false;
	}

	function bool FindNavMeshPath()
	{
		// Clear cache and constraints (ignore recycling for the moment)
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		// Create constraints
		class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, Pawn.Location);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Pawn.Location, 50);
		// Find path
		return NavigationHandle.FindPath();
	}

Begin:
	if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(Pawn.Location);
		
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius() ) )
		{
			MoveTo( TempDest );
		}
	}
}

state PlayerControlled
{
	ignores SeePlayer, SeeMonster;

	event BeginState(Name PreviousStateName)
	{}
	event EndState(Name NextStateName)
	{}
	event Possess(Pawn inPawn, bool bVehicleTransition)
	{}
	event UnPossess()
	{}
}

DefaultProperties
{
	Modo = 2;

	SiriDistance = 128
	TeleportDistance = 2500;
	shooting = false
	isMoving = false
	LastShotTime = 0
	ShotROFDelay = 0.5
	bIsPlayer=true;
}