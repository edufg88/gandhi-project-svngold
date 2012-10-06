
class TestAI extends UDKBot;


                              /**If true, enemy will try to chase the player pawn.*/ var bool bChasePlayers;
/**If true, enemy returns to the initial point instantly after finishing a patrol.*/ var bool bHarshPatrolReturn;
                                           /**If true, stops moving while turning.*/ var bool bPatrolIdleTurning;
                         /**Time needed to stop chasing a not visible player pawn.*/ var float LoseEnemyCheckTime;

  /**If true, possessed pawn stops moving while turning.*/ var bool bIdleTurning;
               /**Name of the corresponding chase state.*/ var name ChaseState;
/**Reference to the controller of the enemy player pawn.*/ var Controller EnemyController;
                    /**Stores location for idle turning.*/ var vector IdleTurningLocation;
             /**Index of the next patrol point to reach.*/ var int PatrolIndex;
                          /**Next patrol point to reach.*/ var GPPatrolPoint PatrolPoint;
               /**Stores the name of the previous state.*/ var name PreviousState;


/**
 * Called whenever the enemy player pawn is no longer within our line of sight.
 */
event EnemyNotVisible()
{
    bEnemyIsVisible = false;

    if (!IsTimerActive(NameOf(CheckEnemyVisibility)))
        SetTimer(LoseEnemyCheckTime,false,NameOf(CheckEnemyVisibility));

    NotSeeingPlayer(Enemy,false);
}

/**
 * Called whenever a player is seen within our line of sight.
 * @param P  the seen player pawn
 */
event SeePlayer(Pawn P)
{
    local bool bFirstSeen;

    if (P.Health > 0 && !P.bDeleteMe)
    {
        bFirstSeen = false;
        if (Enemy == none)
            bFirstSeen = true;

        bEnemyIsVisible = true;
        Enemy = P;
        EnemyController = P.Controller;

        ClearTimer(NameOf(CheckEnemyVisibility));

        if (CanSeeByPoints(Pawn.Location,Enemy.Location,Pawn.Rotation))
            SeeingPlayer(Enemy,bFirstSeen);
        else
            NotSeeingPlayer(Enemy,false);

        if (bChasePlayers)
            GotoState(ChaseState);
    }
    else
        if (Enemy != none)
            EnemyNotVisible();
}

/**
 * Re-checks enemy player pawn visibility after a while.
 */
function CheckEnemyVisibility()
{
    if (!bEnemyIsVisible)
    {
        ClearTimer(NameOf(CheckEnemyVisibility));

        NotSeeingPlayer(Enemy,true);

        Enemy = none;
        EnemyController = none;
    }
}

/**
 * Notification from the game that a pawn has been killed.
 * @param Killer       the controller responsible for the damage
 * @param Killed       the controller which owned the killed pawn
 * @param KilledPawn   the killed pawn
 * @param DamageClass  class describing the damage that was done
 */
function NotifyKilled(Controller Killer,Controller Killed,Pawn KilledPawn,class<DamageType> DamageClass)
{
    if (EnemyController == Killed)
    {
        bEnemyIsVisible = false;

        CheckEnemyVisibility();
    }
}

/**
 * Currently not seeing the enemy player pawn; delegated to states.
 * @param P      the enemy pawn
 * @param bLast  true if it's last call
 */
function NotSeeingPlayer(Pawn P,bool bLast);

/**
 * Handles attaching this controller to the given pawn.
 * @param P                   the pawn to possess
 * @param bVehicleTransition  true if transitioning from a vehicle
 */
function Possess(Pawn P,bool bVehicleTransition)
{
    super.Possess(P,bVehicleTransition);

    Pawn.SetMovementPhysics();
}

/**
 * Currently seeing the enemy player pawn; delegated to states.
 * @param P       the enemy pawn
 * @param bFirst  true if it's first call
 */
function SeeingPlayer(Pawn P,bool bFirst);


auto state Idle
{
Begin:
    Sleep(0.01);

    switch (GPEnemyDroidPawn(Pawn).DefaultPhysics)
    {
        case PHYS_Walking:
            ChaseState = 'WalkingChasePlayer';

            if (GPEnemyDroidPawn(Pawn).PatrolZ.PatrolPoints.Length == 0)
                GotoState('WalkingIdle');
            else
                GotoState('WalkingPatrol');

            break;

        case PHYS_Interpolating:
            bChasePlayers = false;

            GotoState('InterpolatingIdle');
    }
}


state Patrol
{
    event BeginState(name PreviousStateName)
    {
        local float Dist;

        Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn,Pawn.Location,true,true,Dist));

        PatrolIndex = 0;
        PatrolPoint = GPEnemyDroidPawn(Pawn).PatrolZ.PatrolPoints[PatrolIndex];
    }

    event EndState(name NextStateName)
    {
        bIdleTurning = false;
    }
}


state ChasePlayer
{
    event BeginState(name PreviousStateName)
    {
        PreviousState = PreviousStateName;
    }

    /**
     * Called whenever a player is seen within our line of sight.
     * @param P  the seen player pawn
     */
    event SeePlayer(Pawn P)
    {
        if (P.Health > 0 && !P.bDeleteMe)
        {
            bEnemyIsVisible = true;
            Enemy = P;
            EnemyController = P.Controller;

            ClearTimer(NameOf(CheckEnemyVisibility));

            if (Enemy.Health > 0 && !Enemy.bDeleteMe && CanSeeByPoints(Pawn.Location,Enemy.Location,Pawn.Rotation))
                SeeingPlayer(Enemy,false);
            else
                NotSeeingPlayer(Enemy,false);
        }
        else
            if (Enemy != none)
                EnemyNotVisible();
    }

    /**
     * Re-checks enemy player pawn visibility after a while.
     */
    function CheckEnemyVisibility()
    {
        global.CheckEnemyVisibility();

        if (!bEnemyIsVisible)
            GotoState(PreviousState);
    }
}

state WalkingIdle
{
}


state WalkingPatrol extends Patrol
{
Begin:
    Sleep(0.01);

GoToFirstPoint:
    if (!ActorReachable(PatrolPoint))
    {
        ScriptedMoveTarget = FindPathToward(PatrolPoint);

        if (ScriptedMoveTarget != none)
        {
            MoveTo(ScriptedMoveTarget.Location);

            Goto('GoToFirstPoint');
        }
    }

GoToOtherPoints:
    MoveTo(PatrolPoint.Location);

    if (Pawn.ReachedDestination(PatrolPoint))
    {
        PatrolIndex++;

        if (PatrolIndex == GPEnemyDroidPawn(Pawn).PatrolZ.PatrolPoints.Length)
        {
            if (!bHarshPatrolReturn)
                PatrolIndex = 0;
            else
            {
                PatrolIndex = 1;

                Pawn.SetLocation(GPEnemyDroidPawn(Pawn).PatrolZ.PatrolPoints[0].Location);
            }
        }

        PatrolPoint = GPEnemyDroidPawn(Pawn).PatrolZ.PatrolPoints[PatrolIndex];

        if (bPatrolIdleTurning)
        {
            IdleTurningLocation = Pawn.Location;
            bIdleTurning = true;

            Pawn.ZeroMovementVariables();
            //SGDKEnemyPawn(Pawn).MaxYawAim = 0;
            Focus = PatrolPoint;

            Sleep(0.01);

            while (Pawn.Rotation.Yaw != Pawn.DesiredRotation.Yaw)
                Sleep(0.1);

            Focus = none;
            //SGDKEnemyPawn(Pawn).MaxYawAim = SGDKEnemyPawn(Pawn).default.MaxYawAim;

            bIdleTurning = false;
        }
    }

    Goto('GoToOtherPoints');
}


state WalkingChasePlayer extends ChasePlayer
{
    /**
     * Changes MoveTimer.
     */
    function ChangeMoveTimer()
    {
        MoveTimer = 0.5;
    }

Begin:
    if (!ActorReachable(Enemy))
    {
        ScriptedMoveTarget = FindPathToward(Enemy);

        if (ScriptedMoveTarget != none)
            MoveToward(ScriptedMoveTarget,Enemy,Pawn.GetCollisionRadius());
        else
            Sleep(0.25);
    }
    else
    {
        SetTimer(0.01,false,NameOf(ChangeMoveTimer));

        MoveTo(Enemy.Location,Enemy);

        MoveTimer = -1.0;
    }

    Goto('Begin');
}


defaultproperties
{
    bSlowerZAcquire=false //AI acquires targets above or below it at the same speed.

    bChasePlayers=true
    bHarshPatrolReturn=false
    bPatrolIdleTurning=true
    LoseEnemyCheckTime=10.0
}
