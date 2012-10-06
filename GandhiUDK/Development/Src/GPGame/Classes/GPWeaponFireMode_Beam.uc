class GPWeaponFireMode_Beam extends GPWeaponFireMode_Trace;


// Damage interval
var(Beam) const float DamageInterval;
// Real impact since the last tick
var ProtectedWrite ImpactInfo RealImpact;
// Impact array
var ProtectedWrite Array<ImpactInfo> ImpactList;
// Next time damage should be dealt out
var ProtectedWrite float NextDamageTime;

/**
 * Called from the AssaultWeapon during WeaponFiring and if RequiredTickDuringFire is true
 *
 * @param		DeltaTime		Time, in seconds, since the last tick.
 */
simulated function Tick(float DeltaTime)
{
	local int i;

	Super.Tick(DeltaTime);

	// Update the beam
	UpdateBeam();

	// If the damage timer isn't active start it now
	if (Owner.WorldInfo.TimeSeconds >= NextDamageTime)
	{
		// Process all Instant Hits on local player and server (gives damage, spawns any effects).
		if (ImpactList.Length > 0)
		{
			for (i = 0; i < ImpactList.Length; ++i)
			{
				ProcessInstantHit(ImpactList[i]);
			}
		}

		NextDamageTime = Owner.WorldInfo.TimeSeconds + DamageInterval;
	}


	// Update the beam particle effect if it exists
	if (BeamParticleSystemComponent != None)
	{
		BeamParticleSystemComponent.SetVectorParameter(BeamParticleEndPointParameterName, RealImpact.HitLocation);
	}
}

/**
 * Updates the beam
 *
 */
protected simulated function UpdateBeam()
{
	local Vector StartTrace, EndTrace, SocketLocation;
	local Rotator SocketRotation;
	local SkeletalMeshComponent SkeletalMeshComponent;

	// Calculate the weapon firing location and rotation
	SkeletalMeshComponent = SkeletalMeshComponent(Owner.Mesh);
	if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(FireSocketName) != None)
	{
		SkeletalMeshComponent.GetSocketWorldLocationAndRotation(FireSocketName, SocketLocation, SocketRotation);
		StartTrace = SocketLocation;
		EndTrace = StartTrace + Vector(SocketRotation) * TraceRange;
	}
	else
	{
		StartTrace = Owner.Instigator.GetWeaponStartTraceLocation();
		EndTrace = StartTrace + Vector(Owner.GetAdjustedAim(StartTrace)) * TraceRange;
	}

	// Clear the impact list
	ImpactList.Remove(0, ImpactList.Length);

	// Perform shot and store the results
	RealImpact = Owner.CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	// Set the flash location which also increments the flash count
	Owner.SetFlashLocation(RealImpact.HitLocation);
}

defaultproperties
{
	RequiredTickDuringFire=true
}