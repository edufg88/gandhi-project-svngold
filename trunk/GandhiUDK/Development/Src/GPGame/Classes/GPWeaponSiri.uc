class GPWeaponSiri extends UDKWeapon
HideCategories(Movement, Display, Attachment, Collision, Physics, Advanced, Debug, Object);

var(Properties) Name WeaponName;
// Weapon fire modes
var(Weapon) const editinline instanced array<GPWeaponFireModeSiri> FireModes;
// Weapon boost 
var(Weapon) protected float DamageBoost;
// Maximum ammo count
var(Weapon) const int MaxAmmoCount;
// How quickly in seconds to regenerate ammo
var(Weapon) const float AmmoRegenerationTime;
// How much ammo to give per regeneration time
var(Weapon) const int AmmoPerRegeneration;
// How much time has to pass after firing before ammo regeneration can start
var(Weapon) const float AmmoRegenerationStartTime;
// Sound to play when ammo starts regenerationg
var(Weapon) const SoundCue AmmoRegenerationSoundCue;

// Last crosshair target
var ProtectedWrite Actor LastCrosshairTargetLock;
// Next time to consume ammo during continuous firing
var ProtectedWrite float NextConsumeAmmoDuringContinuousFireTime;
// Actor to home projectiles to
var ProtectedWrite Actor HomingProjectileTarget;

var GPSiriPawn Siri;

var bool activeWeap;

////////////////////////////////////////////////
//   CROSSHAIR
////////////////////////////////////////////////
// Crosshair texture
var(Crosshair) const Texture2D CrosshairTexture;
// Crosshair relative size 
var(Crosshair) const float CrosshairRelativeSize;
// Crosshair UV coordinates
var(Crosshair) const float CrosshairU;
var(Crosshair) const float CrosshairV;
var(Crosshair) const float CrosshairUL;
var(Crosshair) const float CrosshairVL;
// Crosshair color
var(Crosshair) const Color CrosshairColorWhite;
var(Crosshair) const Color CrosshairColorRed;
var(Crosshair) const Color CrosshairColorGreen;
var(Crosshair) const Color CrosshairColorPurple;
// Sound to play if the crosshair targets another pawn
var(Crosshair) const SoundCue CrosshairTargetLockSoundCue;


simulated event PostBeginPlay()
{
	local int i;
	
	Super.PostBeginPlay();

	// Get Siri reference
	Siri = GPSiriPawn(GPGame(WorldInfo.Game).Siri.Pawn);
	
	// Set all of the weapon fire mode object's owner
	if (FireModes.Length > 0)
	{
		for (i = 0; i < FireModes.Length; ++i)
		{
			if (FireModes[i] != None)
			{
				FireModes[i].SetOwner(Self);
			}
		}
	}

	//// Set the ammo count to the max ammo count
	AmmoCount = MaxAmmoCount;

	// Setup regenerating ammo
	if (AmmoRegenerationTime > 0.f)
	{
		SetTimer(AmmoRegenerationTime, true, NameOf(RegenerateAmmo));
	}

}

simulated function float GetFireModeRange(byte FireModeNum)
{
	// Return a default value if the parameter don't make sense
	if (FireModeNum >= FireModes.Length || FireModes[FireModeNum] == None)
	{
		return -1.f;
	}

	return FireModes[FireModeNum].GetRange();
}

simulated function float GetAttackAngle(byte FireModeNum)
{
	// Return a default value if the parameter don't make sense
	if (FireModeNum >= FireModes.Length || FireModes[FireModeNum] == None)
	{
		return -1.f;
	}

	return FireModes[FireModeNum].GetAttackAngle();
}

simulated function RenderCrosshair(HUD HUD)
{
	local float CrosshairSize;
	local Vector HitLocation, HitNormal, SocketLocation;
	local Rotator SocketRotation;
	local Actor HitActor;
	local SkeletalMeshComponent SkeletalMeshComponent;
	//WARNING
	//local GPSiriPawn Siri;
	local Color CrosshairColor;

	// Check all crosshair parameters
	if (HUD == None || HUD.Canvas == None || CrosshairTexture == None || CrosshairRelativeSize <= 0.f || CrosshairUL <= 0.f || CrosshairVL <= 0.f || CrosshairColorWhite.A == 0)
	{
		return;
	}

	CrosshairColor = CrosshairColorWhite;

	// Calculate the crosshair size
	CrosshairSize = CrosshairRelativeSize * HUD.SizeX;

	// Check to see if the weapon can perform a world trace to find the true cross hair location
	SkeletalMeshComponent = Siri.Mesh;
	
	if (SkeletalMeshComponent != None && FireModes.Length > 0 && FireModes[0] != None && SkeletalMeshComponent.GetSocketByName(Siri.WeaponSocketName) != None)
	{
		// Trace out to find if the crosshair will target something
		SkeletalMeshComponent.GetSocketWorldLocationAndRotation(Siri.WeaponSocketName, SocketLocation, SocketRotation);
		HitActor = Trace(HitLocation, HitNormal, SocketLocation + Vector(SocketRotation) * 16384.f, SocketLocation, true,,, TRACEFLAG_Bullet);

		if (HitActor != None)
		{
			if (HitActor.isA('GPFX_SphereShieldGandhi') || HitActor.IsA('Trigger')) 
			{
				HitActor = Trace(HitLocation, HitNormal, SocketLocation + Vector(SocketRotation) * 16384.f, HitLocation + Vector(SocketRotation) * 32.f, true,,, TRACEFLAG_Bullet);
			}
			if (HitActor != None)
			{
				if(HitActor.isA('GPEnemyPawn')) 
					CrosshairColor = CrosshairColorRed;
				//HitPawn = Pawn(HitActor);
				//if (HitPawn == GPGame(WorldInfo.Game).Siri.Pawn)
				else if (HitActor.isA('GPFX_SphereShieldEnemy')) CrosshairColor = CrosshairColorPurple;
				else if (HitActor.isA('GPSiriPawn'))
				{
					//Siri = GPSiriPawn(GPGame(WorldInfo.Game).Siri.Pawn);
					Siri = GPSiriPawn(GPGame(WorldInfo.Game).Siri.Pawn);
					Siri.PlaySoundWhenAimed();
					CrosshairColor = CrosshairColorGreen;
				}
			}
		}
		//else
		//{
			HitLocation = HUD.Canvas.Project(HitLocation);
			// Clear the LastCrosshairTargetLock
			LastCrosshairTargetLock = None;
		//}

		// Set the rendering position, and center the crosshair
		HUD.Canvas.SetPos(HitLocation.X - (CrosshairSize * 0.5f), HitLocation.Y - (CrosshairSize * 0.5f));
	}
	// Otherwise just center the crosshair
	else
	{
		HUD.Canvas.SetPos((HUD.SizeX * 0.5f) - (CrosshairSize * 0.5f), (HUD.SizeY * 0.5f) - (CrosshairSize * 0.5f));
	}

	// Set the rendering color
	HUD.Canvas.DrawColor = CrosshairColor;
	// Render the crosshair texture
	HUD.Canvas.DrawTile(CrosshairTexture, CrosshairSize, CrosshairSize, CrosshairU, CrosshairV, CrosshairUL, CrosshairVL);
}

simulated function SendToFiringState(byte FireModeNum)
{
	// make sure fire mode is valid
	if (FireModeNum >= FiringStatesArray.Length)
	{
		return;
	}

	// Set the current fire mode
	SetCurrentFireMode(FireModeNum);
	// transition to firing mode state
	GotoState(FiringStatesArray[FireModeNum]);
}

simulated function PerformFire()
{
	// Forward the fire call to the FireMode object if it doesn't fire on release
	if (CurrentFireMode < FireModes.Length && FireModes[CurrentFireMode] != None)
	{
		// Use ammunition to fire
		DepleteAmmo(CurrentFireMode, FireModes[CurrentFireMode].CostPerShot);

		if (!FireModes[CurrentFireMode].FireOnRelease)
		{
			// Start firing the weapon
			FireModes[CurrentFireMode].Fire();
		}
		else
		{
			// Increment the flash count, to get the firing effects
			IncrementFlashCount();
		}
	}
}

simulated function FireAmmunition()
{
	if (Siri != None)
	{
		// EFG: Solo disparamos si estamos apuntando y no estamos desnudos
		if (Siri.IsAiming)
		{
			PerformFire();
			NotifyWeaponFired(CurrentFireMode);
		}
	}
}

function bool NeedsAmmo()
{
	return (AmmoCount < MaxAmmoCount);
}

function DepleteAmmo(byte FireModeNum, int Amount)
{
	AmmoCount = Max(AmmoCount - Amount, 0);

	if (IsTimerActive(NameOf(AmmoRegenerationTimer)))
	{
		ClearTimer(NameOf(AmmoRegenerationTimer));
	}

	SetTimer(AmmoRegenerationStartTime, false, NameOf(AmmoRegenerationTimer));
}

function AmmoRegenerationTimer()
{
	if (AmmoRegenerationSoundCue != None && Instigator != None)
	{
		Instigator.PlaySound(AmmoRegenerationSoundCue);
	}
}

function StartAmmoRegeneration()
{
	// Clear the ammo regeneration timer
	if (IsTimerActive(NameOf(AmmoRegenerationTimer)))
	{
		ClearTimer(NameOf(AmmoRegenerationTimer));
	}

	// Start ammo regeneration
	AmmoRegenerationTimer();
}

function int AddAmmo(int Amount)
{
	local int LastAmmoCount;

	LastAmmoCount = AmmoCount;
	AmmoCount = Min(AmmoCount + Amount, MaxAmmoCount);

	return AmmoCount - LastAmmoCount;
}

simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	if (Amount == 0)
	{
		return AmmoCount > 0;
	}
	else
	{
		return AmmoCount >= Amount;
	}
}

simulated function bool HasAnyAmmo()
{
	return AmmoCount > 0;
}

function RegenerateAmmo()
{
	if (!IsTimerActive(NameOf(AmmoRegenerationTimer)))
	{
		AmmoCount = Min(AmmoCount + AmmoPerRegeneration, MaxAmmoCount);
	}
}

simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	// Forward the play fire effects to the FireMode object
	if (FireModeNum < FireModes.Length && FireModes[FireModeNum] != None)
	{
		FireModes[FireModeNum].PlayFiringEffects(HitLocation);
	}	
}

simulated function StopFireEffects(byte FireModeNum)
{
	// Forward the stop fire effects to the FireMode object
	if (FireModeNum < FireModes.Length && FireModes[FireModeNum] != None)
	{
		FireModes[FireModeNum].StopFiringEffects();
	}
}

simulated state WeaponEquipping
{
	/**
	 * Called when the weapon has finished equipping
	 *
	 */
	simulated function WeaponEquipped()
	{
		//`Log("Weapon Equipped!!!!!");

		if (bWeaponPutDown)
		{
			// if switched to another weapon, put down right away
			PutDownWeapon();
			return;
		}

		// Attach the weapon to the instigator's mesh
		//AttachToPawn(Instigator);
		GotoState('Active');
	}
}

simulated function TimeWeaponFiring(byte FireModeNum)
{
	// If the weapon is a continous fire mode (since it requires a tick during fire) then don't start the refire timer 
	if (CurrentFireMode < FireModes.Length && FireModes[CurrentFireMode] != None && FireModes[CurrentFireMode].RequiredTickDuringFire)
	{
		return;
	}
	
	// Otherwise do the default behavior
	Super.TimeWeaponFiring(FireModeNum);
}

simulated function float GetFireInterval(byte FireModeNum)
{
	local GPSiriPawn SiriPawn;
	local float FiringInterval;

	FiringInterval = (FireInterval[FireModeNum] > 0) ? FireInterval[FireModeNum] : 0.01;

	SiriPawn = GPSiriPawn(Instigator);
	if (SiriPawn != None)
	{
		//FiringInterval *= SiriPawn.FiringMultiplierRate;
		FiringInterval *= 1.2f;
	}

	return FiringInterval;
}

simulated state WeaponFiring
{
	simulated function Tick(float DeltaTime)
	{
		//`Log("Weapon Firing!!!!!");

		Global.Tick(DeltaTime);

		// If the fire mode requires tick, then forward the tick event if the player is still firing the weapon
		if (CurrentFireMode < FireModes.Length && FireModes[CurrentFireMode] != None)
		{			
			// Check if the fire mode needs any logic per tick
			if (FireModes[CurrentFireMode].RequiredTickDuringFire || FireModes[CurrentFireMode].FireOnRelease)
			{
				// Increase the continous firing time
				FireModes[CurrentFireMode].ContinuousFiringTime += DeltaTime;

				// Check if this consumes any ammo
				if (FireModes[CurrentFireMode].CostPerContinuousFiring > 0 && WorldInfo.TimeSeconds >= NextConsumeAmmoDuringContinuousFireTime)
				{
					// Consume ammo
					DepleteAmmo(CurrentFireMode, FireModes[CurrentFireMode].CostPerContinuousFiring);

					// Set the next time the ammo is being consumed
					NextConsumeAmmoDuringContinuousFireTime = WorldInfo.TimeSeconds + FireModes[CurrentFireMode].ContinuousFiringTimeInterval;
				}
			}

			// Forward the tick event
			if (FireModes[CurrentFireMode].RequiredTickDuringFire && ShouldRefire())
			{
				FireModes[CurrentFireMode].Tick(DeltaTime);
				return;
			}

			// If no more ammo or pending fire is now false, then end firing and fire the shot
			if ((!HasAmmo(CurrentFireMode) || !PendingFire(CurrentFireMode)))
			{
				if (FireModes[CurrentFireMode].ContinuousFiringTime > 0.f)
				{
					// Forward the fire call to the FireMode object if it doesn't fire on release
					FireModes[CurrentFireMode].Fire();

					// Notify that the weapon was fired
					NotifyWeaponFired(CurrentFireMode);
				}

				HandleFinishedFiring();
			}
		}
	}

	/**
	 * Called when the weapon exits this state
	 *
	 * @param		NextStateName			The name of the next state that this weapon will go to
	 */
	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		if (CurrentFireMode >= 0 && CurrentFireMode < FireModes.Length && FireModes[CurrentFireMode] != None)
		{
			// Set continuous firing time to zero
			FireModes[CurrentFireMode].ContinuousFiringTime = 0.f;					
		}
	}
}

simulated function bool NeedsAmmoPickUp()
{
	return AmmoCount < (MaxAmmoCount * 0.5f) && IsTimerActive(NameOf(AmmoRegenerationTimer));
}

simulated function PutDownWeapon()
{
	activeWeap = false;
	super.PutDownWeapon();
}


DefaultProperties
{
	activeWeap=false;

	//Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
	//	bUpdateSkelWhenNotRendered=false
	//	bIgnoreControllersWhenNotRendered=true
	//	bAcceptsDynamicDecals=false
	//	CastShadow=true
	//	TickGroup=TG_DuringASyncWork
	//End Object
	//Mesh=MySkeletalMeshComponent
	//Components.Add(MySkeletalMeshComponent)

	DamageBoost=1.f
	FiringStatesArray(0)="WeaponFiring"
	FiringStatesArray(1)="WeaponFiring"	
	CrosshairColorWhite=(R=255,G=255,B=255,A=191)
	CrosshairColorRed=(R=255,G=0,B=0,A=191)
	CrosshairColorGreen=(R=0,G=255,B=0,A=191)
	CrosshairColorPurple=(R=255,G=0,B=255,A=191)
}
