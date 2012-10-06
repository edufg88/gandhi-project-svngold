class GPProjectile_ShockBall extends GPProjectile;

// Particle system to use for the combo explosion
var(ParticleSystems) const ParticleSystem ComboExplosionParticleTemplate;

// Sound to play when a combo explosion happens
var(Sounds) const SoundCue ComboExplosionSoundCue;

// How much damage the combo explosion inflicts on victims
var(ShockBall) const int ComboDamage;
// Range of the combo explosion
var(ShockBall) const float ComboDamageRadius;
// How much momentum to transfer to combo explosion victims
var(ShockBall) const float ComboDamageMomentum;
// Damage type to use for the combo damage
var(ShockBall) const class<DamageType> ComboDamageType<AllowAbstract>;
// Damage types that cause the shock ball to combo
var(ShockBall) const array< class<DamageType> > ComboCausingDamageTypes<AllowAbstract>;

// If true, then the shock ball has already been comboed and needs to play the effects 
var RepNotify ProtectedWrite bool WasComboed;

// Replication block
replication
{
	if (bNetDirty && Role == Role_Authority)
		WasComboed;
}

/**
 * Called when the projectile should be initialized.
 *
 * @param			Direction			Direction the projectile should move in
 */
simulated function Init(Vector Direction)
{
	Super.Init(Direction);

	// Apply the damage boost
	ApplyDamageBoost();
}

/**
 * Called when a variable flagged with rep notify is replicated
 *
 * @param		VarName			Name of the variable
 */
simulated event ReplicatedEvent(Name VarName)
{
	// If the WasComboed variable was replicated, then perform the combo explosion now
	if (VarName == NameOf(WasComboed))
	{
		ComboExplosion();
	}
	// If the DamageBoost variable was replicated, then perform the particle effect modifier now
	else if (VarName == NameOf(DamageBoost))
	{
		// Apply the damage boost
		ApplyDamageBoost();
	}

	Super.ReplicatedEvent(VarName);
}

/**
 * Applies the damage boost to the shock ball. Makes it bigger.
 *
 * @network			Server and client
 */
simulated function ApplyDamageBoost()
{
	local float DamageBoostScaler;

	// Calculate the damage boost scaler
	DamageBoostScaler = FMax(DamageBoost, 1.f);

	// Scale the particle effect so it is bigger
	if (FlightParticleSystemComponent != None)
	{
		FlightParticleSystemComponent.SetScale(DamageBoostScaler);
	}

	// Scale the collision cylinder
	if (CylinderComponent != None)
	{
		CylinderComponent.SetCylinderSize(CylinderComponent.CollisionRadius * DamageBoostScaler, CylinderComponent.CollisionHeight * DamageBoostScaler);
	}
}

/** 
 * Apply some amount of damage to this actor
 *
 * @param		DamageAmount			Base damage to apply
 * @param		EventInstigator			Controller responsible for the damage
 * @param		HitLocation				World location where the hit occurred
 * @param		Momentum				Force caused by this hit
 * @param		DamageType				Class describing the damage that was done
 * @param		HitInfo					Additional info about where the hit occurred
 * @param		DamageCauser			Actor that directly caused the damage (i.e. the Projectile that exploded, the Weapon that fired, etc)
 */
simulated event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// Has already been comboed
	if (WasComboed)
	{
		return;
	}

	Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	// Check if we need to handle a combo explosion caused by something damaging this projectile
	if (ComboCausingDamageTypes.Length > 0 && ComboCausingDamageTypes.Find(DamageType) != INDEX_NONE)
	{
		// Explode!
		ComboExplosion();

		// Set the life span to two so that there is some time to replicate
		LifeSpan = 2.f;
	}
}

/**
 * Performs the combo explosion 
 *
 */
simulated function ComboExplosion()
{
	local ParticleSystemComponent ParticleSystemComponent;
	local float DamageBoostScaler;

	// Projectile has already exploded, so abort
	if (HasExploded)
	{
		return;
	}

	// Calculate the damage boost scaler
	DamageBoostScaler = FMax(DamageBoost, 1.f);

	// Spawn the effects and play the sound effects on game instances that are the dedicated server
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (ComboExplosionParticleTemplate != None && WorldInfo.MyEmitterPool != None)
		{
			ParticleSystemComponent = WorldInfo.MyEmitterPool.SpawnEmitter(ComboExplosionParticleTemplate, Location);
			if (ParticleSystemComponent != None)
			{
				ParticleSystemComponent.SetScale(DamageBoostScaler);
			}
		}

		if (ComboExplosionSoundCue != None)
		{
			PlaySound(ComboExplosionSoundCue, true);
		}
	}

	// Cause damage to nearby victims
	if (Role == Role_Authority)
	{
		HurtRadius(ComboDamage * DamageBoostScaler, ComboDamageRadius * DamageBoostScaler, ComboDamageType, ComboDamageMomentum, Location);
		WasComboed = true;
	}

	// Fade out the ambient audio component
	if (AmbientAudioComponent != None)
	{
		AmbientAudioComponent.FadeOut(0.15f, 0.f);
	}

	// Hide the projectile
	if (FlightParticleSystemComponent != None)
	{
		FlightParticleSystemComponent.SetHidden(true);
	}

	// Hide the actor
	SetHidden(true);
}

defaultproperties
{
	bCollideWorld=true
	bProjTarget=true
	bCollideComplex=false
	bBlockedByInstigator=false
	bNetTemporary=false

	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=16
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
}