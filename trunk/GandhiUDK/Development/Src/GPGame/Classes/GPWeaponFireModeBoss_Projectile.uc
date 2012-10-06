class GPWeaponFireModeBoss_Projectile extends GPWeaponFireModeBoss;

// Projectile archetype to fire
var(FireMode_Projectile) const GPProjectile ProjectileArchetype<AllowAbstract>;

/**
 * Fires the weapon fire mode
 *
 * @network			Server and client
 */
protected function BeginFire()
{
	local Vector StartTrace, EndTrace, RealStartLoc, AimDir, SocketLocation;
	local Rotator SocketRotation;
	local ImpactInfo TestImpact;	
	local SkeletalMeshComponent SkeletalMeshComponent;
	local GPProjectile SpawnedProjectile;
	local GPProjectile_Homing GPProjectile_Homing;

	// Increment the flash count
	Owner.IncrementFlashCount();

	// This only runs on the server version of the object
	if (Owner.Role == Role_Authority)
	{
		// Calculate the weapon firing location and rotation
		SkeletalMeshComponent = Owner.Boss.Mesh;
		if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(Owner.Boss.WeaponSocketName) != None)
		{
			// Get the socket's world location and rotation
			SkeletalMeshComponent.GetSocketWorldLocationAndRotation(Owner.Boss.WeaponSocketName, SocketLocation, SocketRotation);
			RealStartLoc = SocketLocation;
			AimDir = Vector(SocketRotation);
		}
		else
		{
			// This is where we would start an instant trace. (what CalcWeaponFire uses)
			StartTrace = Owner.Instigator.GetWeaponStartTraceLocation();
			AimDir = Vector(Owner.GetAdjustedAim(StartTrace));

			// this is the location where the projectile is spawned.
			RealStartLoc = Owner.GetPhysicalFireStartLoc(AimDir);

			if (StartTrace != RealStartLoc)
			{
				// If projectile is spawned at different location of crosshair, then simulate an instant trace where crosshair is aiming at, Get hit info.
				EndTrace = StartTrace + AimDir * Owner.GetTraceRange();
				TestImpact = Owner.CalcWeaponFire(StartTrace, EndTrace);

				// Then we realign projectile aim direction to match where the crosshair did hit.
				AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
			}
		}

		// Spawn projectile
		SpawnedProjectile = Owner.Spawn(ProjectileArchetype.Class, self.Owner.Owner,, RealStartLoc,, ProjectileArchetype);
		if (SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe)
		{			
			// Set the damage boost
			//SpawnedProjectile.DamageBoost = Owner.GetDamageBoost();

			// Set the team on the projectile, so that the projectile doesn't explode against team friendlies
			//if (Owner != None && Owner.Instigator != None && Owner.Instigator.PlayerReplicationInfo != None)
			//{
			//	SpawnedProjectile.TeamInfo = Owner.Instigator.PlayerReplicationInfo.Team;
			//}

			// Check if this is a homing projectile, if it is then set its properties
			GPProjectile_Homing = GPProjectile_Homing(SpawnedProjectile);
			if (GPProjectile_Homing != None)
			{
				GPProjectile_Homing.HomingTarget = Owner.HomingProjectileTarget;
			}

			// Give subclasses a chance to modify the projectile
			ModifyProjectile(SpawnedProjectile);

			// Initialize the projectile now
			SpawnedProjectile.Init(AimDir);
		}
	}
}

/**
 * Stub to allow subclasses to modify the projectile before it is initialized
 *
 * @param		Projectile		Projectile to modify
 * @network						Server
 */
protected function ModifyProjectile(GPProjectile Projectile);

/**
 * Returns the range of this fire mode
 *
 * @return			Returns the range of this fire mode
 * @network			Server
 */
simulated function float GetRange()
{
	if (ProjectileArchetype.LifeSpan <= 0.f)
	{
		return 16384.f;
	}
	else
	{
		return ProjectileArchetype.LifeSpan * ProjectileArchetype.MaxSpeed;
	}
}

defaultproperties
{
}