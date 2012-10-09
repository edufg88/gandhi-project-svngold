class GPEnemyDroidController extends GPBaseAIController;

var float SightRadius;
var float SightAngle;
var float DetectDistance;

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

var bool bParalyzed;

var bool bCanShoot;
var float ROF;

function WarnEnemies(Pawn PwnGandhi);
function SetWarned(Pawn PwnGandhi);

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	Super.Possess(inPawn, bVehicleTransition);
	DroidPawn = GPEnemyDroidPawn(inPawn);
	ROF = Pawn.Weapon.GetFireInterval(0);
	SZ = GPEnemyDroidPawn(inPawn).SoundZ;
}

exec function ToggleShield()
{
	if(!hasShield) 
	{
		//Shield = Spawn(class'GPFX_SphereShieldEnemy', Pawn);
		//Shield.SetDrawScale(2.0);
		hasShield = true;
	}
	else 
	{
		//Shield.Destroy();
		Shield = none;
	}
}

function SetRagdoll()
{
	GPEnemyDroidPawn(Pawn).SetRagdoll();
	Pawn.Mesh.AddImpulse((Normal(Pawn.Location-Gandhi.Location))*200, Pawn.Location);
}

function UnSetRagdoll()
{
	GPEnemyDroidPawn(Pawn).UnSetRagdoll();
	bParalyzed = false;
}

state Paralyzed
{
	event BeginState(Name PreviousStateName)
	{
		bParalyzed = true;

		if (DroidPawn == None)
		{
			DroidPawn = GPEnemyDroidPawn(Pawn);
		}
	}

	Begin:
		SetTimer(2.f, false, NameOf(SetRagdoll));
		SetTimer(5.f, false, NameOf(UnSetRagdoll));
		GotoState('');
		
}

state Dead
{
	Begin:
		MoveTo(Pawn.Location, Gandhi);
		Sleep(5);
	goto 'Begin';
}

DefaultProperties
{
	bIsPlayer = false;
	//SiriWarned = false;
	SightRadius = 1500;
	DetectDistance = 500;

	bParalyzed = false;
	bCanShoot=true;
}