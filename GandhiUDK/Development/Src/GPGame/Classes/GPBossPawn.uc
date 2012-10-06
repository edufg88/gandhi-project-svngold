class GPBossPawn extends Pawn placeable
	HideCategories(Camera, Debug, Attachment, Physics, Advanced, Object);

// 
var(PS) ParticleSystemComponent EnergyPS, EnergyWeaponPS;
var(PS) const Name EnergySocketName;
var(Weapon) const Name WeaponSocketName;
var(Sound) bool bPlayingSound;

//EFG: Para controlar si está apuntando o no
var bool IsAiming;

// Current weapon attachment
var ProtectedWrite transient GPWeaponBoss WeaponAttachment;
// Current weapon archetype used for attachment purposes
var RepNotify GPWeaponBoss WeaponAttachmentArchetype;
var const GPWeaponBoss WeaponArchetype;

/** Slot node used for playing full body anims. */
var AnimNodeSlot FullBodyAnimSlot;

/** Slot node used for playing animations only on the top half. */
var AnimNodeSlot TopHalfAnimSlot;

// Reference to the AimOffset node in the AnimTree
var ProtectedWrite transient AnimNodeAimOffset AnimNodeAimOffset;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	Health = 3000;
	AddDefaultInventory();
}

/**
 * Called when the AnimTree has been initialized for a skeletal mesh component
 *
 * @param		SkelComp			Skeletal mesh component that has had its AnimTree initialized
 */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// Only refresh anim nodes if our main mesh was updated
	if (SkelComp == Mesh)
	{
		FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
		TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

		// Reference the anim node aim offset
		AnimNodeAimOffset = AnimNodeAimOffset(SkelComp.FindAnimNode('AnimNode'));
		AnimNodeAimOffset.SetActiveProfileByName('Default');
	}
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	AimTick();
}

function AimTick()
{
	local GPBossController PlayerController;
	//local PlayerController PlayerController;
	local float CurrentPitch;

	if (AnimNodeAimOffset != None)
	{
		// If player controller is valid then Use local controller pitch
		PlayerController = GPBossController(Controller);
		if (PlayerController != None)
		{
			CurrentPitch = PlayerController.Rotation.Pitch;
		}
		// Otherwise use the remote view pitch value
		else
		{			
			// Remember that the remote view pitch is sent over "compressed", so "uncompress" it here
			CurrentPitch = RemoteViewPitch << 8;
		}

		// "Fix" the current pitch
		if (CurrentPitch > 16384)
		{
			CurrentPitch -= 65536;
		}

		// Update the aim offset
		AnimNodeAimOffset.Aim.Y = FClamp((CurrentPitch / 16384.f), -1.f, 1.f);
	}
	else AnimNodeAimOffset.Aim.Y = 0;
}



event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	`Log("Boss:"$Health);

	if(Health <= 0) {
		class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ConsoleCommand("ce bossDeath");
	}

	return;
}

function AddDefaultInventory()
{
	local GPInventoryManager GPInventoryManager;
	local GPWeaponBoss GPWeapon;
	// Tenemos inventario
	GPInventoryManager = GPInventoryManager(self.InvManager);
	if (GPInventoryManager == None)
	{
		return;
	}
	// Tenemos armamento que añadir
	if (WeaponArchetype == None)
	{
		return;
	}
	// Añadimos lo necesario entonces
	GPInventoryManager.CreateInventoryFromArchetype(WeaponArchetype);
	GPWeapon = GPWeaponBoss(Weapon);
	GPWeapon.Boss = self;
	UpdateWeaponAttachment();

	Weapon.bCanThrow = false;
}

simulated function UpdateWeaponAttachment()
{
	// Ensure that the weapon attachment archetype is not none
	if (WeaponAttachmentArchetype == None)
	{
		return;
	}

	// If there was a weapon attachment before, destroy it now
	if (WeaponAttachment != None)
	{
		//WeaponAttachment.DetachWeapon();
		WeaponAttachment.Destroy();
	}

	// Spawn the weapon attachment
	//WeaponAttachment = Spawn(WeaponArchetype.Class,,,,, WeaponArchetype);
	if (WeaponAttachment != None)
	{
		// Attach the weapon to myself
		//WeaponAttachment.AttachToPawn(Self);
		// Set the weapon attachments instigator
		WeaponAttachment.Instigator = Self;
	}
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	local GPWeaponBoss GPWeapon;

	// Figure out which weapon to play the firing effects
	GPWeapon = (Weapon != None) ? GPWeaponBoss(Weapon) : WeaponAttachment;

	Super.WeaponFired(GPWeapon, bViaReplication, HitLocation);
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	Super.WeaponStoppedFiring((Weapon != None) ? GPWeaponBoss(Weapon) : WeaponAttachment, bViaReplication);
}

DefaultProperties
{
	//DrawScale = 7.5;

	// Iluminación propia del Boss
	Begin Object Class=DynamicLightEnvironmentComponent Name=GPLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	//LightEnvironment=GPLightEnvironment
	Components.Add(GPLightEnvironment)

	Begin Object class=SkeletalMeshComponent Name=GPPawnSkeletalMesh
		PhysicsAsset=PhysicsAsset'Boss.Meshes.PA_theBoss'
		SkeletalMesh=SkeletalMesh'Boss.Meshes.SK_theBoss'
		AnimSets(0)=AnimSet'Boss_Animations.AS_theBoss'
		AnimTreeTemplate=AnimTree'Boss_Animations.AT_theBoss'
		LightEnvironment=GPLightEnvironment
		bUseOnePassLightingOnTranslucency=true

		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
		bPerBoneMotionBlur=false
		HiddenGame=FALSE 
		HiddenEditor=FALSE
	End Object
	

	Mesh = GPPawnSkeletalMesh
	Components.Add(GPPawnSkeletalMesh)
	
	// Energy Particle System
	EnergySocketName = "energySocket"

	Begin Object Class=ParticleSystemComponent Name=EnergyPSAct
		Template=ParticleSystem'theBossAttacks_FX.ParticleSystems.PS_BossTornado'
		//Scale=0.3;
	End Object
	EnergyPS=EnergyPSAct

	Begin Object Class=ParticleSystemComponent Name=EnergyWeaponPSAct
		Template=ParticleSystem'theBossAttacks_FX.ParticleSystems.PS_energyAccumulation'
		//Scale=0.3;
	End Object
	EnergyWeaponPS=EnergyWeaponPSAct
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0065.000000
	End Object
	CylinderComponent=CollisionCylinder

	ControllerClass=class'GPBossController'
	GroundSpeed=200.0

	bCanStepUpOn = false
	bPlayingSound = false
	bCanJump = false;
	bCanCrouch = false;

	IsAiming = false;

	WeaponSocketName = "WeaponPoint"

	InventoryManagerClass=class'GPInventoryManager'
	WeaponArchetype = GPWeaponBoss'GP_Archetypes.Weapons.GPWeaponBoss'
}
