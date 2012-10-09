class GPBaseAIController extends AIController;

var Actor Target;
var GPPlayerPawn Gandhi;
var GPPlayerController GandhiCtrl;
var() Vector TempDest;
var GPSoundZone SZ;

function GetGandhi()
{
	local GPPlayerController PC;

	foreach LocalPlayerControllers(class'GPPlayerController', PC)
	{
		GandhiCtrl = PC;
		if(PC.Pawn != none)
			Gandhi = GPPlayerPawn(PC.Pawn);
	}
}

function bool FindNavMeshPath()
{
	// Clear cache and constraints (ignore recycling for the moment)
	NavigationHandle.PathConstraintList = none;
	NavigationHandle.PathGoalList = none;

	// Create constraints
	class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,Target );
	class'NavMeshPath_EnforceTwoWayEdges'.static.EnforceTwoWayEdges(NavigationHandle);  // this makes sure the bot wont wander into an area were he will get stuck
	class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Target,32 );

	// Find path
	return NavigationHandle.FindPath();
}

function bool FindNavMeshPathRand()
{
	// Clear cache and constraints (ignore recycling for the moment)
	NavigationHandle.PathConstraintList = none;
	NavigationHandle.PathGoalList = none;

	// Create constraints
	class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,target );   // this tells the bot to move towards the goal you set.
	class'NavMeshPath_EnforceTwoWayEdges'.static.EnforceTwoWayEdges(NavigationHandle);  // this makes sure the bot wont wander into an area were he will get stuck
	class'NavMeshGoal_Random'.static.FindRandom( NavigationHandle );  // this tells the bot to set a random goal  there are 2 optional variables you can pass, a float representing the range to search, and an int (i think) representing how many polys away he can set his goal.  the defaults are large i think.

	// Find path
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

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
	GPGame(WorldInfo.Game).AddSpawnedEnemy(self);
	GetGandhi();
}

function PawnDied(Pawn inPawn) 
{
	GPGame(WorldInfo.Game).RemoveSpawnedEnemy(self);
	super.PawnDied(inPawn);
}

function Aim()
{
	local Rotator final_rot;
	final_rot = Rotator(Gandhi.Location-Pawn.Location); 
	Pawn.SetViewRotation(final_rot);
}

simulated event GetPlayerViewPoint(out vector out_Location, out Rotator out_Rotation)
{
	if (Pawn != None)
	{
		out_Location = Pawn.Location;
		out_Rotation = Rotation; 
	}
	else
	{
		Super.GetPlayerViewPoint(out_Location, out_Rotation);
	}
}

function Attack();

function Warn();

DefaultProperties
{
	 bIsPlayer = false;
}
