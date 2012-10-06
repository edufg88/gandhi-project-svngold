class GPWeapon_RocketLauncher extends GPWeapon;

/**
 * Called everytime the weapon should be updated
 *
 * @param		DeltaTime				Time that has passed since the last update
 */
function Tick(float DeltaTime)
{
	local SkeletalMeshComponent SkeletalMeshComponent;
	local Vector HitLocation, HitNormal, SocketLocation;
	local Rotator SocketRotation;
	local Pawn HitPawn;

	Super.Tick(DeltaTime);

	// Only the server should run this
	if (Role == Role_Authority)
	{
		// Check to see if the weapon can perform a world trace to find the true cross hair location
		SkeletalMeshComponent = SkeletalMeshComponent(Mesh);
		if (SkeletalMeshComponent != None && FireModes.Length > 0 && FireModes[0] != None && SkeletalMeshComponent.GetSocketByName(FireModes[0].FireSocketName) != None)
		{
			// Trace out to find if the crosshair will target something
			SkeletalMeshComponent.GetSocketWorldLocationAndRotation(FireModes[0].FireSocketName, SocketLocation, SocketRotation);
			HitPawn = Pawn(Trace(HitLocation, HitNormal, SocketLocation + Vector(SocketRotation) * 16384.f, SocketLocation, true,,, TRACEFLAG_Bullet));
			// Set the focused pawn target, if the hit pawn has health and is not on the same team
			if (HitPawn != None && HitPawn.Health > 0 && HitPawn.PlayerReplicationInfo != None && Instigator != None && Instigator.PlayerReplicationInfo != None && HitPawn.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team)
			{
				HomingProjectileTarget = HitPawn;
			}
		}
	}
}

defaultproperties
{
}