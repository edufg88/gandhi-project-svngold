class GPProjectile extends Projectile
	HideCategories(Attachment, Physics, Advanced, Debug, Object);

// Projectile damage type
var(Projectile) const class<DamageType> ProjectileDamageType<AllowAbstract>;

// Decal effect
var(Decal) const MaterialInterface ExplosionDecal;
// Decal width
var(Decal) const float DecalWidth;
// Decal height
var(Decal) const float DecalHeight;
// Decal dissolve parameter name
var(Decal) const Name DecalDissolveParameterName;
// Decal life time
var(Decal) const float DecalLifeTime;

// Particle effect to use when the projectile is in flight
var(ParticleEffects) const ParticleSystem FlightParticleTemplate;
// Particle effect to use when the projectile explodes
var(ParticleEffects) const ParticleSystem ExplosionParticleTemplate;

// Ambient sound effect to play when the projectile is in flight
var(Sounds) const SoundCue AmbientFlightSoundCue;
// Sound effect to play when the projectile explodes
var(Sounds) const SoundCue ExplosionSoundCue;

// Flight particle effect
var ParticleSystemComponent FlightParticleSystemComponent;
// Ambient audio component
var AudioComponent AmbientAudioComponent;
// True if the projectile has exploded already
var bool HasExploded;
// Damage boost
var RepNotify float DamageBoost;

// Replication block
replication
{
	// Replicate the damage boost initially and from the server to the client
	if (bNetInitial && Role == Role_Authority)
		DamageBoost;
}

/**
 * Called when the projectile is first initialized
 *
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Spawn the flight particle effect
	if (FlightParticleTemplate != None)
	{
		FlightParticleSystemComponent = new () class'ParticleSystemComponent';
		if (FlightParticleSystemComponent != None)
		{
			FlightParticleSystemComponent.SetTemplate(FlightParticleTemplate);
			AttachComponent(FlightParticleSystemComponent);
		}
	}

	// If there is an ambient flight sound, then create the audio component and play it back
	if (AmbientFlightSoundCue != None)
	{
		AmbientAudioComponent = CreateAudioComponent(AmbientFlightSoundCue, true, true);
	}

	// Set the damage type
	MyDamageType = ProjectileDamageType;
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if (OtherComp.Owner.IsA('GPEnemyDroidPawn'))
	{
		if (OtherComp.TemplateName == 'SM_ShieldArmor')
		{
			GPEnemyDroidPawnShield(OtherComp.Owner).ImpactOnShield();
		}
		else if (OtherComp.TemplateName == 'SM_ChestArmor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).ChestPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_LForeArmArmor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).LeftArmPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_LUpperArmArmor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).LeftArmPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_RForeArmArmor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).RightArmPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_RUpperArmArmor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).RightArmPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_LLeg1Armor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).LegsPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_LLeg2Armor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).LegsPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_LLeg3Armor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller,GPEnemyDroidPawn(OtherComp.Owner).LegsPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_RLeg1Armor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller, GPEnemyDroidPawn(OtherComp.Owner).LegsPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_RLeg2Armor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller, GPEnemyDroidPawn(OtherComp.Owner).LegsPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'SM_RLeg3Armor')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller, GPEnemyDroidPawn(OtherComp.Owner).LegsPoint, Damage);
		}
		else if (OtherComp.TemplateName == 'CollisionCylinder')
		{
			GPEnemyDroidPawn(OtherComp.Owner).ControlDamage(Pawn(self.Owner).Controller, GPEnemyDroidPawn(OtherComp.Owner).WeakPoint, Damage);
		}

		// Si el disparo es de Gandhi, notificamos
		if (self.Owner.IsA('GPPlayerPawn'))
		{
			GPEnemyDroidController(Pawn(OtherComp.Owner).Controller).NotifyTakeHit(GPPlayerController(Pawn(self.Owner).Controller), OtherComp.Owner.Location, damage, class'UTDmgType_LinkPlasma', vect(0,0,0)); 
		}
	}

	if (OtherComp.Owner.IsA('GPEnemySpiderPawn'))
	{
		// Si el disparo es de Gandhi, notificamos
		if (self.Owner.IsA('GPPlayerPawn'))
		{
			GPEnemySpiderController(Pawn(OtherComp.Owner).Controller).NotifyTakeHit(GPPlayerController(Pawn(self.Owner).Controller), OtherComp.Owner.Location, damage, class'UTDmgType_LinkPlasma', vect(0,0,0)); 
		}
	}
	
}

/**
 * ProcessTouch is called when the projectile touches anything. This has been overrided to ensure that team members are not damaged.
 *
 * @param		Other				Actor that was touched
 * @param		HitLocation			World location where the hit happened
 * @param		HitNormal			World normal of the surface of where the hit happened
 */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	// If exploded then abort
	if (HasExploded)
	{
		return;
	}

	// Perform damage otherwise
	if (DamageRadius == 0)
	{
		Other.TakeDamage(Damage * DamageBoost, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, Self);
	}

	// Explode
	Explode(HitLocation, HitNormal);
}

/**
 * HitWall is called when the projectile hits an actor.
 *
 * @param		HitNormal		World normal of the surface that the projectile hit
 * @param		Wall			Actor which represents the wall that was hit
 * @param		WallComp		Primitive component of the Wall that was actually hit
 * @network						Server and client
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	// If exploded then abort
	if (HasExploded)
	{
		return;
	}

	// If world geometry, check if it is a static mesh that can become active
	if (Wall.bWorldGeometry)
	{
		HitStaticMesh = StaticMeshComponent(WallComp);
		if (HitStaticMesh != None && HitStaticMesh.CanBecomeDynamic())
		{
			NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
			if (NewKActor != None)
			{
				Wall = NewKActor;
			}
		}
	}

	ImpactedActor = Wall;
	if (!Wall.bStatic && DamageRadius == 0)
	{
		Wall.TakeDamage(Damage * DamageBoost, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, Self);
	}

	// Explode
	Explode(Location, HitNormal);
	ImpactedActor = None;
}

/**
 * Called when the projectile explodes.
 *
 * @param		HitLocation			World location where something was hit
 * @param		HitNormal			World normal where something was hit
 */
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local MaterialInterface DecalMaterialInterface;
	local MaterialInstanceTimeVarying MaterialInstanceTimeVarying;

	// Projectile has already exploded, so abort
	if (HasExploded)
	{
		return;
	}

	// Handle special effects on game instances that aren't hosted on the dedicated server
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// Spawn the explosion decal
		if (WorldInfo.MyDecalManager != None && ExplosionDecal != None)
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
			WorldInfo.MyDecalManager.SpawnDecal(DecalMaterialInterface, HitLocation, Rotator(-HitNormal), DecalWidth, DecalHeight, 10.f, false);

			// Start the automatic scalar time
			if (MaterialInstanceTimeVarying != None)
			{
				MaterialInstanceTimeVarying.SetScalarStartTime(DecalDissolveParameterName, DecalLifeTime);
			}
		}

		if (WorldInfo.MyEmitterPool != None)
		{
			// If the flight particle effects were being used, deactivate them now
			if (FlightParticleSystemComponent != None)
			{
				FlightParticleSystemComponent.DeactivateSystem();
			}

			// Spawn the explosion particle effect
			if (ExplosionParticleTemplate != None)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, Location, Rotator(HitNormal));
			}
		}

		// Play the explosion sound
		if (ExplosionSoundCue != None)
		{
			PlaySound(ExplosionSoundCue, true);
		}
	}

	// Apply damage to victims
	if (Damage > 0 && DamageRadius > 0)
	{
		if (Role == ROLE_Authority)
		{
			MakeNoise(1.0);
		}

		ProjectileHurtRadius(HitLocation, HitNormal);
	}

	// Fade out the ambient audio component
	if (AmbientAudioComponent != None)
	{
		AmbientAudioComponent.FadeOut(0.15f, 0.f);
	}

	// Turn off collision
	SetCollision(false, false, false);
	// Hide projectiles when exploded
	SetHidden(true);
	// Set the has exploded variable to prevent this projectile from exploding again
	HasExploded = true;
	// Set the life span to two seconds so that the projectile will eventually be deleted automatically
	LifeSpan = 2.f;
}

/**
 * Adjusts HurtOrigin up to avoid world geometry, so more traces to actors around explosion will succeed
 *
 * @param		HurtOrigin		World location where the origin of the explosion is
 * @param		HitNormal		World normal of where the projectile exploded
 */
simulated function bool ProjectileHurtRadius(vector HurtOrigin, vector HitNormal)
{
	local vector AltOrigin, TraceHitLocation, TraceHitNormal;
	local Actor TraceHitActor;

	// early out if already in the middle of hurt radius
	if (bHurtEntry)
	{
		return false;
	}

	AltOrigin = HurtOrigin;
	if (ImpactedActor != None && ImpactedActor.bWorldGeometry)
	{
		// Try to adjust hit position out from hit location if hit world geometry
		AltOrigin = HurtOrigin + 2.0 * class'Pawn'.Default.MaxStepHeight * HitNormal;
		TraceHitActor = Trace(TraceHitLocation, TraceHitNormal, AltOrigin, HurtOrigin, false,,,TRACEFLAG_Bullet);
		if (TraceHitActor == None)
		{
			AltOrigin = HurtOrigin + class'Pawn'.Default.MaxStepHeight * HitNormal;
		}
		else
		{
			AltOrigin = HurtOrigin + 0.5*(TraceHitLocation - HurtOrigin);
		}
	}
	
	// Amplify damage
	return HurtRadius(Damage * DamageBoost, DamageRadius, MyDamageType, MomentumTransfer, AltOrigin);
}

defaultproperties
{
	bCollideComplex=true
	DamageBoost=1.f
	DecalWidth=32.f
	DecalHeight=32.f
	DecalDissolveParameterName="DissolveAmount"
	DecalLifeTime=20.f
}