//EFG: De momento hacemos que herede de UDKWeapon, más adelante ya veremos...
class GPWeapon extends UDKWeapon
	HideCategories(Movement, Display, Attachment, Collision, Physics, Advanced, Debug, Object);

var(Properties) Name WeaponName;
// Weapon fire modes
var(Weapon) const editinline instanced array<GPWeaponFireMode> FireModes;
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

////////////////////////////////////////////////
//  WEAPON HUD
////////////////////////////////////////////////
// Weapon background texture
var(HUD)  Texture2D WeaponBackgroundTexture;
// Weapon background size
var(HUD)  IntPoint WeaponBackgroundSize;
// Weapon background UV coordinates
var(HUD, WeaponBackgroundUV) const int WeaponBackgroundU<DisplayName=U>;
var(HUD, WeaponBackgroundUV) const int WeaponBackgroundV<DisplayName=V>;
var(HUD, WeaponBackgroundUV) const int WeaponBackgroundUL<DisplayName=UL>;
var(HUD, WeaponBackgroundUV) const int WeaponBackgroundVL<DisplayName=VL>;
// Weapon icon texture
var(HUD) const Texture2D WeaponIconTexture;
// Weapon icon offset
var(HUD) const IntPoint WeaponIconOffset;
// Weapon icon size
var(HUD) const IntPoint WeaponIconSize;
// Weapon icon UV coordinates
var(HUD, WeaponIconUV) const int WeaponIconU<DisplayName=U>;
var(HUD, WeaponIconUV) const int WeaponIconV<DisplayName=V>;
var(HUD, WeaponIconUV) const int WeaponIconUL<DisplayName=UL>;
var(HUD, WeaponIconUV) const int WeaponIconVL<DisplayName=VL>;
// Font to use for the health text
var(HUD) Font WeaponTextFont;
// Height offset to use for the health text
var(HUD) int WeaponTextHeightOffset;


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

// Last crosshair target
var ProtectedWrite Actor LastCrosshairTargetLock;
// Next time to consume ammo during continuous firing
var ProtectedWrite float NextConsumeAmmoDuringContinuousFireTime;
// Actor to home projectiles to
var ProtectedWrite Actor HomingProjectileTarget;

var GPPlayerPawn GPPlayerPawn;
var GPEnemyDroidPawn GPEnemyDroidPawn;

var bool activeWeap;

var(Pawn) MeshComponent CargadorMesh;

/**
 * Called when the weapon is first initialized
 *
 */
simulated event PostBeginPlay()
{
	local int i;
	
	Super.PostBeginPlay();

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

	// Attachamos el cargador
	SkeletalMeshComponent(Mesh).AttachComponentToSocket(CargadorMesh, 'CargadorSocket');
}

/**
 * Returns the range of the fire mode indicated
 *
 * @param		FireModeNum			Fire mode to get the range for
 * @return							Returns the range of the fire mode indicated
 */
simulated function float GetFireModeRange(byte FireModeNum)
{
	// Return a default value if the parameter don't make sense
	if (FireModeNum >= FireModes.Length || FireModes[FireModeNum] == None)
	{
		return -1.f;
	}

	return FireModes[FireModeNum].GetRange();
}

/**
 * Returns the attack angle of the fire mode indicated
 *
 * @param		FireModeNum			Fire mode to get the range for
 * @return							Returns the attack angle of the fire mode indicated
 */
simulated function float GetAttackAngle(byte FireModeNum)
{
	// Return a default value if the parameter don't make sense
	if (FireModeNum >= FireModes.Length || FireModes[FireModeNum] == None)
	{
		return -1.f;
	}

	return FireModes[FireModeNum].GetAttackAngle();
}


/**
 * Returns the damage boost amount
 *
 * @return			Returns the damage boost amount
 */
simulated function float GetDamageBoost()
{
	local float ActualDamageBoost;
	local GPPlayerPawn PlayerPawn;

	ActualDamageBoost = DamageBoost;

	// See if the pawn has amplified damage
	PlayerPawn = GPPlayerPawn(Instigator);
	if (PlayerPawn != None)
	{
		ActualDamageBoost *= PlayerPawn.DamageMultiplier;
	}

	// Always make sure it is above or equal to 1.f
	return FMax(ActualDamageBoost, 1.f);
}

/**
 * Renders the crosshair for the weapon.
 *
 * @param		HUD			HUD to render onto
 */
simulated function RenderCrosshair(HUD HUD)
{
	local float CrosshairSize;
	local Vector HitLocation, HitNormal, SocketLocation;
	local Rotator SocketRotation;
	local Actor HitActor;
	local SkeletalMeshComponent SkeletalMeshComponent;
	local GPSiriPawn Siri;
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
	SkeletalMeshComponent = SkeletalMeshComponent(Mesh);
	if (SkeletalMeshComponent != None && FireModes.Length > 0 && FireModes[0] != None && SkeletalMeshComponent.GetSocketByName(FireModes[0].FireSocketName) != None)
	{
		// Trace out to find if the crosshair will target something
		SkeletalMeshComponent.GetSocketWorldLocationAndRotation(FireModes[0].FireSocketName, SocketLocation, SocketRotation);
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

/**
 * Renders the weapon stats onto the HUD
 *
 * @param		HUD			HUD to render to
 * @param		PosX		How much screen real estate did these stats use.
 */
simulated function RenderStats(HUD HUD, out int PosX)
{
	local int PosY, NbCases, i;
	PosX = 30;
	PosY = 30;
	NbCases = 10 * AmmoCount / 100;
	i = 0;

	while(i < NbCases && i < 10)
	{
		HUD.Canvas.SetPos(PosX, PosY);
		HUD.Canvas.SetDrawColor(10,10,10,200); //R,G,B
		HUD.Canvas.DrawRect(8,12);

		PosX += 10;
		i++;
	}

	while(i < 10)
	{
		HUD.Canvas.SetPos(PosX, PosY);
		HUD.Canvas.SetDrawColor(255, 255, 255, 80);
		HUD.Canvas.DrawRect(8, 12);

		PosX += 10;
		i++;
	}

	HUD.Canvas.SetPos(PosX + 5, PosY);
	HUD.Canvas.SetDrawColor(10, 10, 10, 200);
	HUD.Canvas.Font = class'Engine'.static.GetSmallFont();
	HUD.Canvas.DrawText("AMMO");
}


/**
 * Send weapon to proper firing state and sets the CurrentFireMode.
 *
 * @param		FireModeNum			Fire mode
 */
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



/**
 * Perform all logic associated with firing a shot
 *
 */
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
	if (GPPlayerPawn != None)
	{
		// EFG: Solo disparamos si estamos apuntando y no estamos desnudos
		if (GPPlayerPawn.IsAiming)
		{
			PerformFire();
			NotifyWeaponFired(CurrentFireMode);
		}
	}
	else if (GPEnemyDroidPawn != None)
	{
		PerformFire();
		NotifyWeaponFired(CurrentFireMode);
	} 
}

/**
 * Returns true if the weapon needs ammo
 *
 * @return			Returns true if the weapon needs ammo
 */
function bool NeedsAmmo()
{
	return (AmmoCount < MaxAmmoCount);
}

/**
 * Depletes ammo by a certain amount
 *
 * @param		FireModeNum			Which fire mode is depleting ammo
 * @param		Amount				How much ammo to use
 */
function DepleteAmmo(byte FireModeNum, int Amount)
{
	AmmoCount = Max(AmmoCount - Amount, 0);

	if (IsTimerActive(NameOf(AmmoRegenerationTimer)))
	{
		ClearTimer(NameOf(AmmoRegenerationTimer));
	}

	SetTimer(AmmoRegenerationStartTime, false, NameOf(AmmoRegenerationTimer));
}

/**
 * This is called when the ammo regeneration starts
 *
 */
function AmmoRegenerationTimer()
{
	if (AmmoRegenerationSoundCue != None && Instigator != None)
	{
		Instigator.PlaySound(AmmoRegenerationSoundCue);
	}
}

/**
 * When called this will immediately start ammo regeneration
 *
 */
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

/**
 * Add ammo to weapon
 *
 * @param		Amount		Amount to add.
 * @return					Amount actually added. (In case magazine is already full and some ammo is left)
 */
function int AddAmmo(int Amount)
{
	local int LastAmmoCount;

	LastAmmoCount = AmmoCount;
	AmmoCount = Min(AmmoCount + Amount, MaxAmmoCount);

	return AmmoCount - LastAmmoCount;
}

/**
 * Returns true if there is any ammo left for a particular fire mode
 *
 * @param		FireModeNum			Fire mode num to check ammo for
 * @param		Amount				How much ammo to check for, in case we want to use more ammo
 * @return							Returns true if the fire mode has ammo
 */
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

/**
 * Returns true if the weapon has any ammo at all
 * 
 * @return			Returns true if there is any ammo at all
 */
simulated function bool HasAnyAmmo()
{
	return AmmoCount > 0;
}

/**
 * Regenerates ammo
 *
 */
function RegenerateAmmo()
{
	if (!IsTimerActive(NameOf(AmmoRegenerationTimer)))
	{
		AmmoCount = Min(AmmoCount + AmmoPerRegeneration, MaxAmmoCount);
	}
}

/**
 * Main function to play weapon firing effects. This is called from Pawn::WeaponFired in the base implementation.
 *
 * @param		FireModeNum			Fire mode to play effects for
 * @param		HitLocation			Where in the world the weapon hit
 */
simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	// Forward the play fire effects to the FireMode object
	if (FireModeNum < FireModes.Length && FireModes[FireModeNum] != None)
	{
		FireModes[FireModeNum].PlayFiringEffects(HitLocation);
	}	
}

/**
 * Main function to stop any active effects. This is called from Pawn::WeaponStoppedFiring
 *
 * @param		FireModeNum			Fire mode to stop effects for
 */
simulated function StopFireEffects(byte FireModeNum)
{
	// Forward the stop fire effects to the FireMode object
	if (FireModeNum < FireModes.Length && FireModes[FireModeNum] != None)
	{
		FireModes[FireModeNum].StopFiringEffects();
	}
}

/**
 * Attaches the weapon to the pawn
 *
 * @param			NewPawn			Pawn to attach the weapon to
 */
simulated function AttachToPawn(Pawn NewPawn)
{	
	if (NewPawn.IsA('GPPlayerPawn'))
	{
		if (Mesh != None && NewPawn != None && NewPawn.Mesh != None)
		{
			GPPlayerPawn = GPPlayerPawn(NewPawn);
			if (GPPlayerPawn != None && GPPlayerPawn.Mesh.GetSocketByName(GPPlayerPawn.WeaponSocketName) != None)
			{
				// Attach the weapon mesh to the instigator's skeletal mesh
				GPPlayerPawn.Mesh.AttachComponentToSocket(Mesh, GPPlayerPawn.WeaponSocketName);
				// Set the weapon mesh's light environment
				Mesh.SetLightEnvironment(GPPlayerPawn.LightEnvironment);
				// Set the weapon's shadow parent to the instigator's skeletal mesh
				Mesh.SetShadowParent(GPPlayerPawn.Mesh);
				// Set the weapon attachment archetype so that other clients can see what gun this pawn is carrying
				GPPlayerPawn.WeaponAttachmentArchetype = GPWeapon(ObjectArchetype);
			}
		}
	}
	else if (NewPawn.IsA('GPEnemyDroidPawn'))
	{
		if (Mesh != None && NewPawn != None && NewPawn.Mesh != None)
		{
			GPEnemyDroidPawn = GPEnemyDroidPawn(NewPawn);
			if (GPEnemyDroidPawn != None && GPEnemyDroidPawn.Mesh.GetSocketByName(GPEnemyDroidPawn.WeaponSocketName) != None)
			{
				// Attach the weapon mesh to the instigator's skeletal mesh
				GPEnemyDroidPawn.Mesh.AttachComponentToSocket(Mesh, GPEnemyDroidPawn.WeaponSocketName);
				// Set the weapon mesh's light environment
				//Mesh.SetLightEnvironment(GPEnemyDroidPawn.LightEnvironment);
				// Set the weapon's shadow parent to the instigator's skeletal mesh
				Mesh.SetShadowParent(GPEnemyDroidPawn.Mesh);
				// Set the weapon attachment archetype so that other clients can see what gun this pawn is carrying
				GPEnemyDroidPawn.WeaponAttachmentArchetype = GPWeapon(ObjectArchetype);
			}
		}
	}

	
}

simulated function DetachWeapon()
{
	if (Mesh != None)
	{
		if (GPPlayerPawn != None && GPPlayerPawn.Mesh.GetSocketByName(GPPlayerPawn.WeaponSocketName) != None)
		{
			GPPlayerPawn.Mesh.DetachComponent(Mesh);
		}
	}
}

/**
 * The weapon is in this state while transitioning from Inactive to Active state. Typically, the weapon will remain in this state while its selection animation is being played.
 * While in this state, the weapon cannot be fired.
 *
 */
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
		AttachToPawn(Instigator);
		GotoState('Active');
	}
}

/**
 * Sets the timing for the firing state on server and local client. By default, a constant looping Rate Of Fire (ROF) is set up. When the delay has expired, the RefireCheckTimer event is triggered.
 *
 * @param			FireModeNum			Fire mode
 */
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

/**
 * Returns interval in seconds between each shot, for the firing state of FireModeNum firing mode.
 *
 * @param	FireModeNum	fire mode
 * @return	Period in seconds of firing mode
 */
simulated function float GetFireInterval(byte FireModeNum)
{
	local GPPlayerPawn PlayerPawn;
	local GPEnemyDroidPawn EnemyPawn;
	local float FiringInterval;

	FiringInterval = (FireInterval[FireModeNum] > 0) ? FireInterval[FireModeNum] : 0.01;

	if (Instigator.IsA('GPPlayerPawn'))
	{
		PlayerPawn = GPPlayerPawn(Instigator);
		if (PlayerPawn != None)
		{
			FiringInterval = FiringInterval*(PlayerPawn.FiringMultiplierRate);
		}
	}
	else if (Instigator.IsA('GPEnemyDroidPawn'))
	{
		EnemyPawn = GPEnemyDroidPawn(Instigator);
		if (EnemyPawn != None)
		{
			FiringInterval =  FiringInterval*(EnemyPawn.FiringMultiplierRate);
		}
	}

	return FiringInterval;
}

/**
 * The weapon in this state is firing the weapon.
 *
 */
simulated state WeaponFiring
{
	/**
	 * Every time the weapon is updated
	 *
	 * @param		DeltaTime		Time, in seconds, since the last update
	 */
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

/**
 * Returns true if this weapon needs an ammo pick up. This is used by AI to determine if they should go for the ammo pick up
 *
 * @return			Returns true if this weapon needs an ammo pick up
 */
simulated function bool NeedsAmmoPickUp()
{
	return AmmoCount < (MaxAmmoCount * 0.5f) && IsTimerActive(NameOf(AmmoRegenerationTimer));
}

simulated function PutDownWeapon()
{
	activeWeap = false;
	super.PutDownWeapon();
}

defaultproperties
{
	activeWeap=false;

	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
	End Object
	Mesh=MySkeletalMeshComponent
	Components.Add(MySkeletalMeshComponent)

	DamageBoost=1.f
	FiringStatesArray(0)="WeaponFiring"
	FiringStatesArray(1)="WeaponFiring"	
	CrosshairColorWhite=(R=255,G=255,B=255,A=191)
	CrosshairColorRed=(R=255,G=0,B=0,A=191)
	CrosshairColorGreen=(R=0,G=255,B=0,A=191)
	CrosshairColorPurple=(R=255,G=0,B=255,A=191)

	Begin Object Class=StaticMeshComponent Name=SM_Cargador
		StaticMesh=StaticMesh'blastergun.Mesh.SM_blastergun_cargador'
		//bUpdateSkelWhenNotRendered=false
		//bIgnoreControllersWhenNotRendered=true
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
	End Object
	CargadorMesh=SM_Cargador
}
