class GPWeaponFireMode extends Object
	HideCategories(Object)
	EditInlineNew
	Abstract;

// Socket name to attach all muzzle effects
var(FireMode) const Name MuzzleSocketEffectName;
// Socket name to fire from
var(FireMode) const Name FireSocketName;
// If true, then the pawn will play a recoil animation
var(FireMode) const bool HasRecoil;
// If true, then this fire mode requires tick while the weapon is being fired
var(FireMode) const bool RequiredTickDuringFire;
// If true, then call fire after the mouse button has been released
var(FireMode) const bool FireOnRelease;
// How much ammo the fire mode consume on firing
var(FireMode) const int CostPerShot;
// How much ammo the fire mode consumes if being fired continuously
var(FireMode) const int CostPerContinuousFiring;
// How often to consume ammo when fired continuously
var(FireMode) const float ContinuousFiringTimeInterval;
// How accurate the AI needs to be in order to fire his weapon
var(FireMode) const float AttackAngle;

// Sound to play when this fire mode is fired
var(Sounds) const SoundCue FireSoundCue;
// Sound to play when this fire mode stops firing
var(Sounds) const SoundCue StopFireSoundCue;
// Sound to loop when this fire mode continously fires, RequiredTickDuringFire must be true
var(Sounds) const SoundCue ContinuousFireSoundCue<EditCondition=RequiredTickDuringFire>;

// Particle system to play when this fire mode is fired. Relies on the muzzle socket effect name to be valid.
var(ParticleSystems) const ParticleSystem FireParticleTemplate;

// Explosion light to trigger when this fire mode is fired. Relies on the muzzle socket effect name to be valid.
var(Light) const editinline instanced GPExplosionLight FireLight;

// Owner of this fire mode
var ProtectedWrite GPWeapon Owner;
// Muzzle flash particle system component 
var ProtectedWrite ParticleSystemComponent MuzzleFlashParticleSystem;
// Continous firing sound audio component
var ProtectedWrite AudioComponent ContinuousFireAudioComponent;
// Ensures that the fire sound is played only once
var ProtectedWrite bool HasPlayedFiringSound;
// How long the weapon has been continuously firing for
var float ContinuousFiringTime;

/**
 * Sets the owner of the fire mode
 *
 */
simulated function SetOwner(GPWeapon NewOwner)
{
	if (NewOwner != None)
	{
		Owner = NewOwner;
	}
}

/**
 * Fires the weapon fire mode
 *
 */
final simulated function Fire()
{
	if (Owner != None)
	{
		BeginFire();
	}
}

/**
 * Plays the firing effects for the weapon fire mode
 *
 * @param			HitLocation				Hit location to spawn effects
 */
simulated function PlayFiringEffects(optional Vector HitLocation)
{
	local SkeletalMeshComponent SkeletalMeshComponent;

	// Check the owner and the dedicated server
	if (Owner == None || Owner.WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}

	// Play the weapon firing sound
	if ((!HasPlayedFiringSound || !RequiredTickDuringFire) && FireSoundCue != None && Owner.Instigator != None)
	{
		Owner.Instigator.PlaySound(FireSoundCue, true);
	}

	// If there is a continuous firing sound, create the audio component and fade it in	
	if (!HasPlayedFiringSound && ContinuousFireSoundCue != None && Owner.Instigator != None)
	{
		if (ContinuousFireAudioComponent == None)
		{
			ContinuousFireAudioComponent = Owner.Instigator.CreateAudioComponent(ContinuousFireSoundCue, true, true);
		}

		if (ContinuousFireAudioComponent != None)
		{
			ContinuousFireAudioComponent.FadeIn(0.1f, 1.f);
		}
	}

	// Set the flag that the firing sound has been played
	HasPlayedFiringSound = true;

	// Handle any socketed particle effects
	SkeletalMeshComponent = SkeletalMeshComponent(Owner.Mesh);
	if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(MuzzleSocketEffectName) != None)
	{
		// Handle the muzzle flash particle effect
		if (FireParticleTemplate != None)
		{
			// Create the muzzle flash particle system if it does not exist yet
			if (MuzzleFlashParticleSystem == None)
			{
				MuzzleFlashParticleSystem = new () class'ParticleSystemComponent';
				if (MuzzleFlashParticleSystem != None)
				{
					// Set the template
					MuzzleFlashParticleSystem.SetTemplate(FireParticleTemplate);
					// Attach the particle effect to the socket
					SkeletalMeshComponent.AttachComponentToSocket(MuzzleFlashParticleSystem, MuzzleSocketEffectName);
				}
			}

			// Trigger the muzzle flash particle system
			if (MuzzleFlashParticleSystem != None)
			{
				MuzzleFlashParticleSystem.ActivateSystem();
			}
		}

		// Handle the muzzle flash light effect
		if (FireLight != None)
		{
			// Attach the fire light to the socket
			if (!FireLight.bAttached || FireLight.Owner == None)
			{
				SkeletalMeshComponent.AttachComponentToSocket(FireLight, MuzzleSocketEffectName);
				FireLight.Initialize();
			}
			
			// Reset the fire light
			FireLight.ResetLight();
		}
	}
}

/**
 * Stops the firing effects for the weapon fire mode
 *
 */
simulated function StopFiringEffects()
{
	// Ensure the owner is valid, no need to run on the dedicated server
	if (Owner == None || Owner.WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}

	// The player has no longer played the firing sound
	HasPlayedFiringSound = false;

	// Play the weapon stop firing sound
	if (StopFireSoundCue != None && Owner.Instigator != None)
	{
		Owner.Instigator.PlaySound(StopFireSoundCue, true);
	}

	// If there is a continuous firing audio component, fade it out now
	if (ContinuousFireAudioComponent != None)
	{
		ContinuousFireAudioComponent.FadeOut(0.1f, 0.f);
		ContinuousFireAudioComponent = None;
	}

	// Deactivate the muzzle flash
	if (MuzzleFlashParticleSystem != None)
	{
		MuzzleFlashParticleSystem.DeactivateSystem();
	}
}

/**
 * Fires the weapon fire mode
 *
 */
protected function BeginFire();

/**
 * Called from the GPWeapon during WeaponFiring and if RequiredTickDuringFire is true
 *
 */
function simulated Tick(float DeltaTime);

/**
 * Returns the range of tis fire mode
 */
simulated function float GetRange()
{
	return 16384.f;
}

/**
 * Returns the attack angle of the fire mode indicated
 */
simulated function float GetAttackAngle()
{
	return AttackAngle;
}

defaultproperties
{
	HasRecoil=true
	AttackAngle=0.87f
}
