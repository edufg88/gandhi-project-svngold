class GPProjectile_Homing extends GPProjectile;

// How quickly the homing projectile responds to a homing target that moves
var(Homing) const float HomingResponseTime;
// How quickly the homing projectile can turn to point towards its homing target
var(Homing) const float HomingStrength<UIMin=0.1|UIMax=1.0>;
// Target to home in on
var RepNotify Actor HomingTarget;

// Replication block
replication
{
	if (bNetInitial && Role == Role_Authority)
		HomingTarget;
}

/**
 * Called whenever a variable flagged as RepNotify has been replicated.
 *
 * @param		VarName			Name of the variable that has been replicated.
 */
simulated event ReplicatedEvent(Name VarName)
{
	// If homing target has been replicated, start the homing timer
	if (VarName == NameOf(HomingTarget) && HomingTarget != None)
	{
		SetTimer(HomingResponseTime, true, NameOf(Homing));
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/**
 * Called when the projectile should be initialized.
 *
 * @param			Direction			Direction the projectile should move in
 * @network								Server and client
 */
simulated function Init(Vector Direction)
{
	Super.Init(Direction);

	// Set the timer to home in the timer
	if (HomingTarget != None)
	{
		SetTimer(HomingResponseTime, true, NameOf(Homing));
	}
}

/**
 * Changes the velocity of the projectile so that it points towards its homing target
 * 
 * @network			Server and client
 */
simulated function Homing()
{
	local Rotator LookAtDirection;

	// If the homing target is invalid, then destroy the missile
	if (HomingTarget == None)
	{
		Destroy();
	}
	else
	{
		// Steer towards the target
		LookAtDirection = RLerp(Rotator(Velocity), Rotator(HomingTarget.Location - Location), FClamp(HomingStrength, 0.1f, 1.f), true);

		// Reset velocity
		Velocity = Vector(LookAtDirection) * Speed;
	}
}

defaultproperties
{
	HomingResponseTime=0.1f
	HomingStrength=0.5f
	bBlockedByInstigator=false
	bNetTemporary=false
	bRotationFollowsVelocity=true
}