class GPSiriPawn extends Pawn
	placeable
	HideCategories(Camera, Debug, Attachment, Physics, Advanced, Object);

var(Jet) ParticleSystemComponent JetPS;
var(Jet) const Name JetSocketName;
var(Weapon) const Name WeaponSocketName;
var(Sound) bool bPlayingSound;

//EFG: Para controlar si está apuntando o no
var bool IsAiming;

// Current weapon attachment
var ProtectedWrite transient GPWeaponSiri WeaponAttachment;
// Current weapon archetype used for attachment purposes
var RepNotify GPWeaponSiri WeaponAttachmentArchetype;
var const GPWeaponSiri WeaponArchetype;

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// Controlamos el fuego amigo
	if(InstigatedBy == GPGame(WorldInfo.Game).Siri) return;
	if(InstigatedBy.Class ==  GPGame(WorldInfo.Game).PlayerControllerClass) return;

	// Nos están haciendo daño...Algo tendremos que hacer
	GPGame(WorldInfo.Game).Siri.PlayerAttacked(InstigatedBy.Pawn);
	//// Play a pain sound
	//if (Health > 0 && HitSoundCues.Length > 0)
	//{
	//	PlaySound(HitSoundCues[Rand(HitSoundCues.Length)], true);
	//}
	//// Play the damage type hit effects for a client
	//PlayHitEffects(DamageType);

	//Siri es inmortaaaaaaal
	//Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	return;
}

simulated function PlaySoundWhenAimed()
{
	if (!bPlayingSound)
	{
		bPlayingSound=true;
		PlaySound(SoundCue'SoundFX.Siri-Frases.SiriApuntada');
		SetTimer(10.0f, true, NameOf(SoundWhenAimedStopped));
	}
}

simulated function SoundWhenAimedStopped()
{
	bPlayingSound = false;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	//JetPS.EmitterInstances.Add(
	AttachJetPS();
	//SetPhysics(PHYS_Flying);
	AddDefaultInventory();
	//CollisionComponent = GPPawnSkeletalMesh
	//LandMovementState=PlayerFlying
	//bCollideComplex = true
}

// Attaches Jet Particle System. Usually when moving
simulated function AttachJetPS()
{	
	// Check the PS and Mesh
	if (JetPS != None && self.Mesh != None)
	{		
		if (Mesh.GetSocketByName(JetSocketName) != None)
		{
			// Attach the weapon mesh to the instigator's skeletal mesh
			Mesh.AttachComponentToSocket(JetPS, JetSocketName);
		}
	}
}
// ... The opposite
simulated function DetachJetPS()
{
	if (Mesh != None)
	{
		if (Mesh.GetSocketByName(JetSocketName) != None)
		{
			//Mesh.DetachComponent(JetPS);
		}
	}
}

function ChangeController(Controller NewController)
{
	Controller = NewController;
}

function AddDefaultInventory()
{
	local GPInventoryManager GPInventoryManager;
	local GPWeaponSiri GPWeapon;
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
	GPWeapon = GPWeaponSiri(Weapon);
	GPWeapon.Siri = self;
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
	local GPWeaponSiri GPWeapon;

	// Figure out which weapon to play the firing effects
	GPWeapon = (Weapon != None) ? GPWeaponSiri(Weapon) : WeaponAttachment;

	Super.WeaponFired(GPWeapon, bViaReplication, HitLocation);
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	Super.WeaponStoppedFiring((Weapon != None) ? GPWeaponSiri(Weapon) : WeaponAttachment, bViaReplication);
}

defaultproperties
{
	DrawScale = 7.5;

	// Iluminación propia de Siri
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
		PhysicsAsset=PhysicsAsset'Siri.Mesh.PH_Siri_Physics'
		SkeletalMesh=SkeletalMesh'siri.Mesh.SK_Siri'
		AnimSets(0)=AnimSet'Siri.Mesh.AS_Siri_Anims'
		AnimTreeTemplate=AnimTree'Siri.AT_Siri'
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
	
	// JET Particle System
	JetSocketName = "jetSocket"

	Begin Object Class=ParticleSystemComponent Name=JetPSAct
		Template=ParticleSystem'PS_SiriJet.ParticleSystems.PS_Siri_JetEffect'
		//Scale=0.3;
	End Object

	JetPS=JetPSAct

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0050.000000
	End Object
	CylinderComponent=CollisionCylinder

	ControllerClass=class'GPSiriController'
	GroundSpeed=250.0

	bCanStepUpOn = false
	bPlayingSound = false
	bCanJump = false;
	bCanCrouch = false;

	IsAiming = false;

	WeaponSocketName = "WeaponPoint"

	InventoryManagerClass=class'GPInventoryManager'
	WeaponArchetype = GPWeaponSiri'GP_Archetypes.Weapons.GPWeaponSiri'
}
