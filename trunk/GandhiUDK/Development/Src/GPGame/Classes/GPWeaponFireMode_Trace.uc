class GPWeaponFireMode_Trace extends GPWeaponFireMode;

// Decal effct
var(Decal) const MaterialInterface ExplosionDecal;
// Decal width
var(Decal) const float DecalWidth;
// Decal height
var(Decal) const float DecalHeight;
// Decal dissolve parameter name
var(Decal) const Name DecalDissolveParameterName;
// Decal life time
var(Decal) const float DecalLifeTime;

// How much damage to inflict on the victim
var(Trace) const int Damage;
// How much momentum to apply on the victim
var(Trace) const int DamageMomentum;
// Trace range
var(Trace) const float TraceRange;
// Trace damage type
var(Trace) const class<DamageType> TraceDamageType<AllowAbstract>;

// Particle systems to spawn when hitting world geometry
var(ParticleSystems) const ParticleSystem ImpactParticleTemplate;
// Beam particle system to spawn when firing the weapon
var(ParticleSystems) const ParticleSystem BeamParticleTemplate;
// Beam particle system end point parameter name
var(ParticleSystems) const Name BeamParticleEndPointParameterName;
// Beam particle system translation offset
var(ParticleSystem) const Vector BeamParticleTranslationOffset;

// Sound to play when hitting world geometry
var(Sounds) const SoundCue ImpactSoundCue;

// Reference to the beam particle system component
var ProtectedWrite transient ParticleSystemComponent BeamParticleSystemComponent;

/**
 * Fires the weapon fire mode
 *
 */
protected function BeginFire()
{
	local Vector StartTrace, EndTrace, SocketLocation;
	local Rotator SocketRotation;
	local int i;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact;
	local SkeletalMeshComponent SkeletalMeshComponent;

	// Calculate the weapon firing location and rotation
	SkeletalMeshComponent = SkeletalMeshComponent(Owner.Mesh);
	if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(FireSocketName) != None)
	{
		// Get the socket's world location and rotation
		SkeletalMeshComponent.GetSocketWorldLocationAndRotation(FireSocketName, SocketLocation, SocketRotation);
		StartTrace = SocketLocation;
		EndTrace = StartTrace + Vector(SocketRotation) * TraceRange;
	}
	else
	{
		StartTrace = Owner.Instigator.GetWeaponStartTraceLocation();
		EndTrace = StartTrace + Vector(Owner.GetAdjustedAim(StartTrace)) * TraceRange;
	}

	// Perform shot
	RealImpact = Owner.CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	// Set the flash location which also increments the flash count
	Owner.SetFlashLocation(RealImpact.HitLocation);

	// Process all Instant Hits on local player and server (gives damage, spawns any effects).
	if (ImpactList.Length > 0)
	{
		for (i = 0; i < ImpactList.Length; ++i)
		{
			ProcessInstantHit(ImpactList[i]);
		}
	}
}

/**
 * Processes a successful instant hit trace, spawns any effects required etc.
 *
 * @param		Impact		Hit information
 */
protected function ProcessInstantHit(ImpactInfo Impact)
{
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	if (Impact.HitActor != None)
	{
		// Check if the impact is a static mesh that can become a KActor, if so handle it here
		if (Impact.HitActor.bWorldGeometry)
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if (HitStaticMesh != None && HitStaticMesh.CanBecomeDynamic())
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if (NewKActor != None)
				{
					Impact.HitActor = NewKActor;
				}
			}
		}

		// Otherwise inflict pain on the victim
		Impact.HitActor.TakeDamage(Damage, Owner.Instigator.Controller, Impact.HitLocation, DamageMomentum * Impact.RayDir, TraceDamageType, Impact.HitInfo, Owner);
	}
}

/**
 * Plays the firing effects for the weapon fire mode
 *
 * @param			HitLocation				Hit location to spawn effects
 */
simulated function PlayFiringEffects(optional Vector HitLocation)
{
	local Vector TraceHitLocation, TraceHitNormal, Direction;
	local Actor HitActor;
	local SkeletalMeshComponent SkeletalMeshComponent;
	local Vector StartTrace, EndTrace, SocketLocation;
	local Rotator SocketRotation;
	local MaterialInstanceTimeVarying MaterialInstanceTimeVarying;
	local MaterialInterface DecalMaterialInterface;

	if (Owner.WorldInfo.NetMode != NM_DedicatedServer)
	{
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

		if (!IsZero(HitLocation))
		{
			Direction = Normal(HitLocation - Owner.Instigator.Location);
			HitActor = Owner.Trace(TraceHitLocation, TraceHitNormal, Owner.Instigator.Location + Direction * TraceRange, Owner.Instigator.Location, true,,, class'Actor'.const.TRACEFLAG_Bullet);
			if (HitActor != None && (HitActor.bWorldGeometry || HitActor.bNoDelete))
			{
				// Spawn the explosion decal
				if (Owner.WorldInfo.MyDecalManager != None && ExplosionDecal != None)
				{
					// Get the appropriate decal material
					if (ExplosionDecal.IsA('MaterialInstanceTimeVarying'))
					{
						MaterialInstanceTimeVarying = new () class'MaterialInstanceTimeVarying';
						if (MaterialInstanceTimeVarying != None)
						{
							MaterialInstanceTimeVarying.SetParent(ExplosionDecal);
							DecalMaterialInterface = MaterialInstanceTimeVarying;
						}
					}
					else
					{
						DecalMaterialInterface = ExplosionDecal;
					}

					// Spawn the decal in the world
					Owner.WorldInfo.MyDecalManager.SpawnDecal(DecalMaterialInterface, HitLocation, Rotator(-TraceHitNormal), DecalWidth, DecalHeight, 10.f, false);

					// Start the automatic scalar time
					if (MaterialInstanceTimeVarying != None)
					{
						MaterialInstanceTimeVarying.SetScalarStartTime(DecalDissolveParameterName, DecalLifeTime);
					}
				}

				// Spawn the impact effect, find the hit normal to properly orient the emitter
				if (Owner.WorldInfo.MyEmitterPool != None && ImpactParticleTemplate != None)
				{				
					Owner.WorldInfo.MyEmitterPool.SpawnEmitter(ImpactParticleTemplate, TraceHitLocation, Rotator(TraceHitNormal));
				}
			}

			// Play the impact sound
			if (ImpactSoundCue != None)
			{
				Owner.PlaySound(ImpactSoundCue, true,,, HitLocation);
			}
		}

		// Spawn the beam particle effect if required
		if (BeamParticleSystemComponent == None && BeamParticleTemplate != None)
		{
			BeamParticleSystemComponent = new () class'ParticleSystemComponent';
			if (BeamParticleSystemComponent != None)
			{
				// Set the template
				BeamParticleSystemComponent.SetTemplate(BeamParticleTemplate);
				// Set the tick group
				BeamParticleSystemComponent.SetTickGroup(TG_PostUpdateWork);
				// Set the update component in tick
				BeamParticleSystemComponent.bUpdateComponentInTick = true;
				// Set the translation
				BeamParticleSystemComponent.SetTranslation(BeamParticleTranslationOffset);

				// Attach the beam particle effect
				if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(MuzzleSocketEffectName) != None)
				{
					SkeletalMeshComponent.AttachComponentToSocket(BeamParticleSystemComponent, MuzzleSocketEffectName);
				}
			}
		}
		
		if (BeamParticleSystemComponent != None)
		{			
			// Activate the system
			BeamParticleSystemComponent.ActivateSystem();
			// Set the end point of the beam particle effect
			BeamParticleSystemComponent.SetVectorParameter(BeamParticleEndPointParameterName, (!IsZero(HitLocation)) ? HitLocation : EndTrace);
		}
	}

	Super.PlayFiringEffects(HitLocation);
}

/**
 * Stops the firing effects for the weapon fire mode
 *
 */
simulated function StopFiringEffects()
{
	Super.StopFiringEffects();

	// Deactivate the beam 
	if (BeamParticleSystemComponent != None)
	{
		BeamParticleSystemComponent.DeactivateSystem();
	}
}

defaultproperties
{
	DecalWidth=32.f
	DecalHeight=32.f
	DecalDissolveParameterName="DissolveAmount"
	DecalLifeTime=20.f
}