class GPPlayerPawn extends Pawn
	HideCategories(Movement, AI, Camera, Debug, Attachment, Physics, Advanced, Object);

struct SDamageInfo
{
	// Damage type
	var() class<DamageType> DamageType<AllowAbstract>;
	// Camera anim to play when damaged by the damage type
	var() CameraAnim CameraAnim;
};

var Rotator oldRotation;
//var bool softRot;
var bool isMovingToCover;

var int PEMRadius;

var GPTurbineItem turbine;


/////////////////////////////////////////////////
// Hit Reaction and RagDolling
/////////////////////////////////////////////////
// Death animation
var(HitReaction) Name DeathAnimName;
// Bone names to unfix when hit reaction is simulated
var(HitReaction) array<Name> UnfixedBodyNames;
// Bone names to enable springs when hit reaction is simulated
var(HitReaction) array<Name> EnabledSpringBodyNames;
// Linear bone spring strength to use when hit reaction is simulated
var(HitReaction) float LinearBoneSpringStrength;
// Angular bone spring strength to use when hit reaction is simulated
var(HitReaction) float AngularBoneSpringStrength;
// Radius of the force to apply
var(HitReaction) float ForceRadius;
// Force amplification
var(HitReaction) float ForceAmplification;
// Maximum amount of force that can be applied 
var(HitReaction) float MaximumForceThatCanBeApplied;
// Blend in time for the hit reaction
var(HitReaction) float PhysicsBlendInTime;
// Physics simulation time for the hit reaction
var(HitReaction) float PhysicsTime;
// Blend out time for the hit reaction
var(HitReaction) float PhysicsBlendOutTime;
// Full body rag doll
var(HitReaction) bool FullBodyRagdoll;


/////////////////////////////////////////////////
//  Posible Hit Points
/////////////////////////////////////////////////
var(HitPoint) const int ChestPoint;
var(HitPoint) const int LeftArmPoint;
var(HitPoint) const int RightArmPoint;
var(HitPoint) const int LegsPoint;

/////////////////////////////////////////////////
// Sockets
/////////////////////////////////////////////////
var(Pawn) const Name WeaponSocketName;
var(Pawn) const Name TurbineSocketName;
var(Pawn) const Name ShieldSocketName;
var(Pawn) const Name EMPSocketName;
var(Pawn) const Name ChestArmorSocketName;
var(Pawn) const Name UpperLeftArmArmorSocketName;
var(Pawn) const Name LowerLeftArmArmorSocketName;
var(Pawn) const Name UpperRightArmArmorSocketName;
var(Pawn) const Name LowerRightArmArmorSocketName;
var(Pawn) const Name UpperLeftLegArmorSocketName;
var(Pawn) const Name LowerLeftLegArmorSocketName;
var(Pawn) const Name UpperRightLegArmorSocketName;
var(Pawn) const Name LowerRightLegArmorSocketName;
var(Pawn) const Name FundaPistolaSocketName;
var(Pawn) const Name FundaRifleSocketName;
///////////////////////////////////////////////////////
// Posibles armas a llevar 
/////////////////////////////////////////////////////
var(Pawn) MeshComponent LinkGunMesh;
var(Pawn) MeshComponent ShockRifleMesh;

var(Pawn) SkeletalMeshComponent TurbineMesh;

// Light environment component used by the pawn mesh
var(Pawn) const LightEnvironmentComponent LightEnvironment;
// Aim Offset Anim Node name
var(Pawn) const Name AimNodeName;
// Gun recoil skeletal controller
var(Pawn) const Name RecoilSkelControlName;
// Explosion sound to play when the pawn has died
var(Pawn) const SoundCue ExplosionSoundCue;
// Explosion particle effect to play when the pawn has died
var(Pawn) const ParticleSystem ExplosionParticleTemplate;
// Sound to play when the pawn gets hit
var(Pawn) const array<SoundCue> HitSoundCues;
// Sound to play when the pawn dies
var(Pawn) const array<SoundCue> DeathSoundCues;
// Damage info
var(Pawn) const array<SDamageInfo> DamageInfos;

// Current weapon archetype used for attachment purposes
var RepNotify GPWeapon WeaponAttachmentArchetype;
// Reference to the AimOffset node in the AnimTree
var ProtectedWrite transient AnimNodeAimOffset AnimNodeAimOffset;
// Reference to the Gun recoil skeletal controller in the AnimTree
var ProtectedWrite transient GameSkelCtrl_Recoil RecoilSkelControl;
// Current weapon attachment
var /*ProtectedWrite transient*/ GPWeapon WeaponAttachment;
// Firing multiplier rate
var ProtectedWrite transient float FiringMultiplierRate;
// Damage multiplier
var ProtectedWrite transient float DamageMultiplier;

var bool IsNaked;
//EFG: Para controlar si está apuntando o no
var bool IsAiming;
//EFG: Para controlar si está agachado o no
var bool IsCrouched;
//EFG: Para controlar si tenemos un arma desenfundada
var bool IsCarryingWeapon;
//EFG: Para controlar si estamos en el agua
var bool IsUnderWater;
//EFG: Para controlar si tiene la turbina puesta
var bool IsTurbineOn;

//EFG: Para controlar si estamos en el menú
var bool IsInMenu;

/** Slot node used for playing full body anims. */
var AnimNodeSlot FullBodyAnimSlot;

/** Slot node used for playing animations only on the top half. */
var AnimNodeSlot TopHalfAnimSlot;

var bool bIsRagdoll;

// Sistema de partículas para EMP
var(Pawn) const ParticleSystem PS_EMP;

var int WeaponAmmount;

var SoundCue PEMSound;

// Replication block (EFG: Todo el tema de Replicación en principio es para juego en red, lo dejaremos de momento porsi...)
replication
{
	if (bNetDirty && !bNetOwner && Role == Role_Authority)
		WeaponAttachmentArchetype;

	if (bnetDirty && bNetOwner && Role == Role_Authority)
		FiringMultiplierRate, DamageMultiplier;
}

//event PostBeginPlay()
//{
/////*	local Actor p;
////	p = self;
////	p.PostBeginPlay(*/);
//	//Actor(self).PostBeginPlay();

//	SplashTime = 0;
//	SpawnTime = WorldInfo.TimeSeconds;
//	EyeHeight	= BaseEyeHeight;

//	// automatically add controller to pawns which were placed in level
//	// NOTE: pawns spawned during gameplay are not automatically possessed by a controller
//	if ( WorldInfo.bStartup && (Health > 0) && !bDontPossess )
//	{
//		SpawnDefaultController();
//	}

//	if( FacialAudioComp != None )
//	{
//		FacialAudioComp.OnAudioFinished = FaceFXAudioFinished;
//	}

//	// Spawn Inventory Container
//	if (Role == ROLE_Authority && InvManager == None && InventoryManagerClass != None)
//	{
//		if (PlayerReplicationInfo.Deaths == 0)
//		{
//			InvManager = Spawn(InventoryManagerClass, Self);
//			if ( InvManager == None )
//				`log("Warning! Couldn't spawn InventoryManager" @ InventoryManagerClass @ "for" @ Self @ GetHumanReadableName() );
//			else
//				InvManager.SetupFor( Self );
//		}
//	}

//	//debug
//	ClearPathStep();
//}

/**
 * Called when damage should be amplified
 *
 * @param		AmplifiedDamageTime			How long damage amplification lasts for
 */
reliable client function ClientAmplifyDamage(float AmplifiedDamageTime)
{
	AmplifyDamage(AmplifiedDamageTime);
}

/**
 * Called when damage should be amplified
 *
 * @param		AmplifiedDamageTime			How long damage amplification lasts for
 */
simulated function AmplifyDamage(float AmplifiedDamageTime)
{
	local float ExistingTime;

	DamageMultiplier = 2.f;

	// If the player is already having damage amplified, then append the time
	if (IsTimerActive(NameOf(AmplifiedDamageTimer)))
	{
		ExistingTime = GetRemainingTimeForTimer(NameOf(AmplifiedDamageTimer));
		ClearTimer(NameOf(AmplifiedDamageTimer));
	}
	else
	{
		ExistingTime = 0.f;
	}

	// Start the amplified damage timer
	SetTimer(AmplifiedDamageTime + ExistingTime, false, NameOf(AmplifiedDamageTimer));

	// Sync with the client
	if (Role == Role_Authority)
	{
		ClientAmplifyDamage(AmplifiedDamageTime);
	}
}

/**
 * Timer which keeps track of damage amplification. When this timer expires, it sets the damage multiplier back to 1.f
 *
 */
simulated function AmplifiedDamageTimer()
{
	DamageMultiplier = 1.f;
}

/**
 * Called when the pawn should enter berserk mode
 *
 * @param		BerserkTime			How long berserk mode should last for
 */
reliable client function ClientEnterBerserkMode(float BerserkTime)
{
	EnterBerserkMode(BerserkTime);
}

/**
 * Called when the pawn should enter berserk mode
 *
 * @param		BerserkTime			How long berserk mode should last for
 */
simulated function EnterBerserkMode(float BerserkTime)
{
	local float ExistingTime;

	FiringMultiplierRate = 0.3f;

	// If the player is already in berserk mode, then append the time
	if (IsTimerActive(NameOf(BeserkModeTimer)))
	{
		ExistingTime = GetRemainingTimeForTimer(NameOf(BeserkModeTimer));
		ClearTimer(NameOf(BeserkModeTimer));
	}
	else
	{
		ExistingTime = 0.f;
	}

	// Start the berserk mode timer
	SetTimer(BerserkTime + ExistingTime, false, NameOf(BeserkModeTimer));

	// Sync with the client
	if (Role == Role_Authority)
	{
		ClientEnterBerserkMode(BerserkTime);
	}
}

/**
 * Timer which keeps track of berserk mode. When this timer expires, it set the firing multiplier rate back to 1.f
 *
 */
simulated function BeserkModeTimer()
{
	FiringMultiplierRate = 1.f;
}

/**
 * Detects which part of the body has been hit
 * returns:
 *  - 1: Chest
 *  - 2: Left Arm
 *  - 3: Right Arm
 *  - 4: Legs
 */
function int DetectHitPoint(vector HitLocation, optional TraceHitInfo HitInfo)
{
	local vector Chest, ULA, URA, ULL; //LLA LRA LLL URL LRL Faltarian
	local rotator socketRotation;
	local int iAux, iAux2, iAux3;
	
	
	if (isAiming)
	{
		return 0;
	}
	else if (isCrouched)
	{
		return 0;
	}
	else
	{
		// Comprobamos la parte superior
		self.Mesh.GetSocketWorldLocationAndRotation(ChestArmorSocketName, Chest, socketRotation, 0);
		
		if (HitLocation.Z > Chest.Z)
		{
			self.Mesh.GetSocketWorldLocationAndRotation(UpperLeftArmArmorSocketName, ULA, socketRotation, 0);
			self.Mesh.GetSocketWorldLocationAndRotation(UpperRightArmArmorSocketName, URA, socketRotation, 0);

			// Estamos seguro por encima de la cintura
			// Comprobamos la distancia X entre el socket del pecho y los sockets de la parte superior 
			// del brazo para determinar el impacto

			// Mejor utilizar vectores que componentes
			iAux = VSize(Chest - HitLocation);
			iAux2 = VSize(ULA - HitLocation);
			iAux3 = VSize(URA - HitLocation);

			if (iAux < iAux2)
			{
				// No estamos en la parte izquierda
				if (iAux < iAux3)
				{
					// Estamos en el pecho
					return ChestPoint;
				}
				else
				{
					// Estamos en la parte derecha
					return RightArmPoint;
				}
			}
			else
			{
				// Estamos en la parte izquierda
				return LeftArmPoint;
			}
		}
		else
		{
			self.Mesh.GetSocketWorldLocationAndRotation(UpperLeftArmArmorSocketName, ULL, socketRotation, 0);
			// Puede que estemos encima de la cintura
			// Comprobamos la distancia en Z entre el socket del pecho y el socket de la parte superior de la pierna
			iAux = abs(Chest.Z - HitLocation.Z);
			iAux2 = abs(ULL.Z - HitLocation.Z);

			if (iAux < iAux2)
			{
				// Estamos encima de la cintura
				self.Mesh.GetSocketWorldLocationAndRotation(UpperLeftArmArmorSocketName, ULA, socketRotation, 0);
				self.Mesh.GetSocketWorldLocationAndRotation(UpperRightArmArmorSocketName, URA, socketRotation, 0);

				// Estamos seguro por encima de la cintura
				// Comprobamos la distancia X entre el socket del pecho y los sockets de la parte superior 
				// del brazo para determinar el impacto

				// En el caso de que las Xs pasaran a ser Ys probar a utilizar vectores y decidir la componente a descartar
				iAux = VSize(Chest - HitLocation);
				iAux2 = VSize(ULA - HitLocation);
				iAux3 = VSize(URA - HitLocation);

				if (iAux < iAux2)
				{
					// No estamos en la parte izquierda
					if (iAux < iAux3)
					{
						// Estamos en el pecho
						return ChestPoint;
					}
					else
					{
						// Estamos en la parte derecha
						return RightArmPoint;
					}
				}
				else
				{
					// Estamos en la parte izquierda
					return LeftArmPoint;
				}
			}
			else
			{
				// Estamos debajo de la cintura
				return LegsPoint;
			}
		}
	}
}

/**
 * Called when the pawn takes damage
 *
 * @param		Damage				How much damage was done
 * @param		InstigatedBy		Controller that did the damage
 * @param		HitLocation			Where in the world damage was done
 * @param		Momentum			Momentum transferred by the hit
 * @param		DamageType			What type of damage was inflicted
 * @param		HitInfo				Extra information about the hit
 * @param		DamageCauser		Actual actor that did the damage
 */
simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int HitComponent; // Dónde ha dado la bala
	local GPInventoryManager InvMgr;
	local array<GPArmorItem> ArmorList;
	local GPArmorItem Item;
	local int i;
	local bool bBreak;
	local int iArmorPoints;

	// Obtenemos la lista de armaduras
	InvMgr = GPInventoryManager(InvManager);
	InvMgr.GetArmorList(ArmorList);

	// Sacamos por el log cuánto nos queda de vida
	//`Log("Damage: "$Damage$" Health: "$Health);
	
	// Controlamos que Siri no nos haga daño...
	if(InstigatedBy == GPGame(WorldInfo.Game).Siri) return;
	// Ni hacernos daño nosotros mismos...
	if(InstigatedBy.Class ==  GPGame(WorldInfo.Game).PlayerControllerClass) return;

	// Avisamos a Siri para que actúe en consecuencia
	GPGame(WorldInfo.Game).Siri.PlayerAttacked(InstigatedBy.Pawn);

	// EFG: Aquí debemos controlar dónde ha sido el impacto
	///////////////////////////////////////////////////////////////////////
	// Debemos controlar el daño como hacen en Pawn pero controlando las armaduras y demás

	// Comprobamos si hay armaduras
	if (ArmorList.Length > 0)
	{
		HitComponent = DetectHitPoint(HitLocation, HitInfo);
		
		bBreak = false;
		switch (HitComponent)
		{
			case ChestPoint:
				//ClientMessage("CHEST");
				for(i=0; i < ArmorList.Length && !bBreak; i++)
				{
					Item = ArmorList[i];
					if (Item.IsA('GPChestArmorItem'))
					{
						bBreak = true;
					}					
				}
				break;

			case LeftArmPoint:
				//ClientMessage("LEFT ARM");
				for(i=0; i < ArmorList.Length && !bBreak; i++)
				{
					Item = ArmorList[i];
					if (Item.IsA('GPLUpperArmArmorItem') || Item.IsA('GPLForeArmArmorItem'))
					{
						bBreak = true;
					}					
				}
				break;

			case RightArmPoint:
				//ClientMessage("RIGHT ARM");
				for(i=0; i < ArmorList.Length && !bBreak; i++)
				{
					Item = ArmorList[i];
					if (Item.IsA('GPRUpperArmArmorItem') || Item.IsA('GPRForeArmArmorItem'))
					{
						bBreak = true;
					}					
				}
				break;
			case LegsPoint:
				//ClientMessage("LEGS");
				for(i=0; i < ArmorList.Length && !bBreak; i++)
				{
					Item = ArmorList[i];
					if (Item.IsA('GPLCalfArmorItem') || Item.IsA('GPLThighArmorItem') ||
						Item.IsA('GPRCalfArmorItem') || Item.IsA('GPRThighArmorItem'))
					{
						bBreak = true;
					}					
				}
				break;
		}

		// Tenemos armadura 
		if(bBreak)
		{
			iArmorPoints = Item.ApplyDamage(Damage);
			if (iArmorPoints == 0)
			{
				Item.Unequip();
				class'GPHUD'.static.showHUDText("A piece of armor has been broken and unequipped", 2000);
				//ClientMessage("Destruyendo Pieza: " $ Item.ItemName);
				//InvManager.RemoveFromInventory(Item);
				//Item.Destroy();
				//Mesh.DetachComponent(Item.DroppedPickupMesh);
			}
		}
		else
		{
			//ClientMessage("IMPACTO, HAY ARMADURAS PERO NO EN LA ZONA DE IMPACTO");
			// No tenemos armadura
			Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		}
	}
	else
	{
		// Se podría hacer cálculo para este caso también para mostrar animación de impacto...
		// No se si sería aquí
		//ClientMessage("IMPACTO, NO HAY ARMADURA");
		// Si no hay evitamos comprobaciones y aplicamos el daño directamente a la salud
		Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
	
	// Play a pain sound
	if (Health > 0 && HitSoundCues.Length > 0)
	{
		PlaySound(HitSoundCues[Rand(HitSoundCues.Length)], true);
	}


	// Play the damage type hit effects for a client
	PlayHitEffects(DamageType);

}

/**
 * Plays hit effects and syncs with the client if required.
 *
 * @param		DamageType		What type of damage was inflicted
 */
simulated function PlayHitEffects(class<DamageType> DamageType)
{
	if (Role == Role_Authority)
	{
		ClientPlayHitEffects(DamageType);
	}

	DoPlayHitEffects(DamageType);
}

/**
 * Plays hit effects on the client. This is replicated from the server to the client.
 *
 * @param		DamageType		What type of damage was inflicted
 */
reliable client function ClientPlayHitEffects(class<DamageType> DamageType)
{
	DoPlayHitEffects(DamageType);
}

/**
 * Plays hit effects on the client.
 *
 * @param		DamageType		What type of damage was inflicted
 */
simulated function DoPlayHitEffects(class<DamageType> DamageType)
{
	local int Index;
	local PlayerController PlayerController;

	// Grab the player controller, and ensure it has a player camera
	PlayerController = PlayerController(Controller);
	if (PlayerController != None && PlayerController.PlayerCamera != None)
	{
		// Search to see if anything should happen when being hit by DamageType
		Index = DamageInfos.Find('DamageType', DamageType);
		if (Index != INDEX_NONE && DamageInfos[Index].CameraAnim != None)
		{
			// If there is a camera anim, play it
			PlayerController.PlayerCamera.PlayCameraAnim(DamageInfos[Index].CameraAnim);
		}
	}
}
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
  GetActorEyesViewPoint( out_CamLoc, out_CamRot );
  
  return true;
}
/**
 * Renders the pawn stats such as health
 *
 * @param		HUD			HUD to render to
 * @param		PosX		How much screen real estate did these stats use.
 */
simulated function RenderStats(HUD HUD, out int PosX)
{
	// TODO...If necessary
}

/**
 * This pawn has died. 
 * EFG: Genera todo tipo de eventos cuando el prota muere
 */
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying(DamageType, HitLoc);

	// Play a death sound
	if (DeathSoundCues.Length > 0)
	{
		PlaySound(DeathSoundCues[Rand(DeathSoundCues.Length)], true);
	}

	// Play the explosion sound 
	if (ExplosionSoundCue != None)
	{
		PlaySound(ExplosionSoundCue, true);
	}

	// Spawn the explosion particle effect
	if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, Location);
	}

	// Hide the pawn
	SetHidden(true);
}

/**
 * Called when a variable flagged with rep notify is replicated
 *
 * @param			VarName				Name of the variable that was replicated
 */
simulated event ReplicatedEvent(Name VarName)
{
	// Weapon attachment archetype was replicated, update the weapon attachment
	if (VarName == NameOf(WeaponAttachmentArchetype))
	{
		UpdateWeaponAttachment();
	}

	Super.ReplicatedEvent(VarName);
}

/**
 * Called by ReplicatedEvent when WeaponAttachmentArchetype has been replicated
 *
 */
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
		WeaponAttachment.DetachWeapon();
		WeaponAttachment.Destroy();
	}

	// Spawn the weapon attachment
	WeaponAttachment = Spawn(WeaponAttachmentArchetype.Class,,,,, WeaponAttachmentArchetype);
	if (WeaponAttachment != None)
	{
		// Attach the weapon to myself
		WeaponAttachment.AttachToPawn(Self);
		// Set the weapon attachments instigator
		WeaponAttachment.Instigator = Self;
	}
}

/**
 * Called when the pawn is destroyed
 *
 */
simulated event Destroyed()
{
	Super.Destroyed();

	// Clear anim node object references
	AnimNodeAimOffset = None;
	// Clear skeletal controller object references
	RecoilSkelControl = None;
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
		// Reference the skel control recoil
		RecoilSkelControl = GameSkelCtrl_Recoil(SkelComp.FindSkelControl(RecoilSkelControlName));
	}
}

/**
 * Called every time the pawn is updated
 *
 * @param		DeltaTime		Time since the last tick
 */
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	//`Log("Roll:"$Rotation.Roll$" Pitch:"$Rotation.Pitch$" Yaw:"$Rotation.Yaw);

	AimTick();
}

function AimTick()
{
	local PlayerController PlayerController;
	local float CurrentPitch;

	if (AnimNodeAimOffset != None && IsAiming)
	{
		// If player controller is valid then Use local controller pitch
		PlayerController = PlayerController(Controller);
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


/**
 * Called when a pawn's weapon has fired and is responsibile for delegating the creation of all of the different effects. 
 * bViaReplication denotes if this call in as the result of the flashcount/flashlocation 
 * being replicated. It's used filter out when to make the effects.
 *
 * @param		InWeapon				Weapon that was fired
 * @param		bViaReplication			Function was called because of replication
 * @param		HitLocation				Weapon hit location
 */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	local GPWeapon GPWeapon;

	// Figure out which weapon to play the firing effects
	GPWeapon = (Weapon != None) ? GPWeapon(Weapon) : WeaponAttachment;

	// Play the recoil animation if the fire mode has recoil
	if (RecoilSkelControl != None)
	{		
		if (GPWeapon != None && GPWeapon.CurrentFireMode < GPWeapon.FireModes.Length && GPWeapon.FireModes[FiringMode] != None && GPWeapon.FireModes[FiringMode].HasRecoil)
		{
			RecoilSkelControl.bPlayRecoil = true;
		}
	}

	Super.WeaponFired(GPWeapon, bViaReplication, HitLocation);
}

/**
 * Called when a pawn's weapon has stopped firing and is responsibile for delegating the destruction of all of the different effects. bViaReplication denotes if this call in as the result of the flashcount/
 * flashlocation being replicated.
 *
 * @param		InWeapon				Weapon that stopped firing
 * @param		bViaReplication			Function called because of replication
 */
simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	Super.WeaponStoppedFiring((Weapon != None) ? GPWeapon(Weapon) : WeaponAttachment, bViaReplication);
}

/**
 * Plays the footstep sound according to the notifies specified in the Animset
 * */
simulated event PlayFootStepSound(int FootDown)
{
	local SoundCue FootSound;

	FootSound = SoundCue'SoundFX.Steps.SFX_FootSteps';
	
	PlaySound(FootSound, false, true,,, true);
}

/** Change the type of weapon animation we are playing. */
simulated function SetWeapAnimType(EWeapAnimType AnimType)
{
	if (AnimNodeAimOffset != None)
	{
		AnimNodeAimOffset.SetActiveProfileByName('Default');
	}
}

/**
 * Returns true if a health pick up is desirable or not. This is used by the AI to determine if it should go for the health pick up or not.
 *
 * @return			Returns true if a health pick up is desirable or not
 */
simulated function bool NeedsHealthPickUp()
{
	return Health < (HealthMax * 0.5f);
}

exec function ToggleTurbine()
{
	if (isTurbineOn)
	{
		WaterSpeed = WaterSpeed/3;
	}
	else
	{
		WaterSpeed = WaterSpeed*3;		
	}

	isTurbineOn = !isTurbineOn;
}

////////////////////////////////////////////////////////////////////
//      EXEC
///////////////////////////////////////////////////////////////////
function PlayPEMParticles()
{
	local Vector socketLocation;
	mesh.GetSocketWorldLocationAndRotation(EMPSocketName, socketLocation);
	WorldInfo.MyEmitterPool.SpawnEmitter(PS_EMP, socketLocation);
}

exec function ForceField()
{
	local GPEnemyDroidPawn Actor;
	local GPEnemySpiderPawn Spider;
	local GPEnemyDroidController gpedController;
	local GPEnemySpiderController gpesController;

	// Aplicamos los efectos visuales sobre Gandhi
	if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
	{
		//FullBodyAnimSlot.PlayCustomAnim('test_PEM', 2.f);
		TopHalfAnimSlot.PlayCustomAnim('test_PEM', 2.f);		
		SetTimer(2.f, false, NameOf(PlayPEMParticles));
		PlaySound(PEMSound);
	}
	
	// Aplicamos los efectos físicos sobre los enemigos
	ForEach AllActors(class'GPEnemyDroidPawn', Actor)
	{
		if (VSize(Self.Location - Actor.Location) < PEMRadius)
		{		
			gpedController = GPEnemyDroidController(Actor.Controller);
			gpedController.GotoState('Paralyzed');
		}
	}

	ForEach AllActors(class'GPEnemySpiderPawn', Spider)
	{
		if (VSize(Self.Location - Spider.Location) < PEMRadius)
		{		
			gpesController = GPEnemySpiderController(Spider.Controller);
			gpesController.GotoState('Paralyzed');
		}
	}
}

exec function ToggleCrouch()
{
	//`Log("-- Toggle Crouch --");
	if(!IsInMenu) IsCrouched = !IsCrouched;
}

exec function ToggleRagDoll()
{
	if (!bIsRagdoll)
	{
		Mesh.MinDistFactorForKinematicUpdate = 0.f;
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default, true);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn, false);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, false);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, false);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
		Mesh.ForceSkelUpdate();
		Mesh.SetTickGroup(TG_PostAsyncWork);
		CollisionComponent = Mesh;
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, false);
		Mesh.SetTraceBlocking(true, true);
		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsWeight = 1.0;

		if (Mesh.bNotUpdatingKinematicDueToDistance)
		{
			Mesh.UpdateRBBonesFromSpaceBases(true, true);
		}

		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
		Mesh.bUpdateKinematicBonesFromAnimation = false;
		Mesh.SetRBLinearVelocity(Velocity, false);
		Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
		Mesh.SetNotifyRigidBodyCollision(true);
		Mesh.WakeRigidBody();

		bIsRagdoll = true;
	}
	else
	{
		Mesh.SetNotifyRigidBodyCollision(false);
		Mesh.ScriptRigidBodyCollisionThreshold = 0;
		Mesh.bUpdateKinematicBonesFromAnimation = true;
		Mesh.PhysicsWeight = 0.0;
		//SetPhysics(PHYS_Walking);
		SetMovementPhysics();
		Mesh.SetTraceBlocking(false, false);
		Mesh.SetActorCollision(true, true);
		CylinderComponent.SetActorCollision(true, true);
		Mesh.ForceSkelUpdate();
		Mesh.SetTickGroup(TG_PreAsyncWork);
		Mesh.SetRBChannel(RBCC_Untitled3);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, true);

		bIsRagdoll = false;
	}
}

exec function destroyTurbine()
{
	turbine.destroyTurbine();
}

//exec function GetEnergy()
//{
//	local GPEnergyItem EI;
//	local int count;

//	count = 0;
//	ForEach InvManager.InventoryActors(class'GPEnergyItem', EI)
//	{
//		count++;
//	}
//}

exec function SomerSault()
{
	//FullBodyAnimSlot.PlayCustomAnim('test_back_somersault', 1.0);
	FullBodyAnimSlot.PlayCustomAnim('test_front_somersault', 2.5);
}


//only update pawn rotation while moving
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	local rotator DiffRot;
	// Do not update Pawn's rotation if no accel
	if (isAiming || Normal(Acceleration)!=vect(0,0,0) || IsInState('Covering') || IsInState('CoverEdging'))
	{
		//if ( Physics == PHYS_Ladder )
		//{
		//	NewRotation = OnLadder.Walldir;
		//}
		//else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		//{
		//	//NewRotation = rotator((Location + Normal(Acceleration))-Location);
		//	//NewRotation.Pitch = 0;
		//}

		//if(softRot) {
			oldRotation = Rotation;
			//GPPlayerController(Controller).PlayerInput.aStrafe = 0;
			//`Log(GPPlayerController(Controller).PlayerInput.aStrafe);
			
			NewRotation = RInterpTo(oldRotation,NewRotation,DeltaTime,10);
			if(IsInState('CoverEdging') && !IsAiming) {
				//`Log("Coveredgiiiiing");
				DiffRot = NewRotation - oldRotation;
				IsAiming = Abs(DiffRot.Yaw) < 2500;
			}
		//}
		if(!GPPlayerController(Controller).CoverCornering) super.FaceRotation(NewRotation, DeltaTime);
	}
	//else softRot = true;
	
}

state Covering
{
	function BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );
		isMovingToCover = true;
	}

	simulated function Tick(float DeltaTime)
	{
		local rotator CoverNormal;
		local Vector NewLocation;
		local Vector DiffLoc;

		Super.Tick( DeltaTime );
		//AimTick();

		// make sure if we are covering we make the pawn face AWAY from the wall
		CoverNormal = Normalize( rotator(GPPlayerController(Controller).Wall.Normal) );
		CoverNormal.Pitch = 0;
			
		if(!IsAiming) FaceRotation(CoverNormal, DeltaTime);
		if(isMovingToCover) {
			NewLocation = VInterpTo(Location,GPPlayerController(Controller).Wall.Goal,DeltaTime,10);
			DiffLoc = NewLocation - Location;
			isMovingToCover = Move(DiffLoc) && Abs(DiffLoc.X) + Abs(DiffLoc.Y) > 1;
		}
	}
}

state CoverEdging
{
	function BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );
		isMovingToCover = true;
	}

	simulated function Tick(float DeltaTime)
	{
		local rotator CoverNormal;
		local Vector NewLocation;
		local Vector DiffLoc;

		Super.Tick( DeltaTime );
		AimTick();

		// make sure if we are covering we make the pawn face AWAY from the wall
		CoverNormal = Normalize( rotator(GPPlayerController(Controller).Wall.EdgeNormal) );
		CoverNormal.Pitch = 0;
			
		if(!IsAiming) FaceRotation(CoverNormal, DeltaTime);
		if(isMovingToCover) {
			NewLocation = VInterpTo(Location,GPPlayerController(Controller).Wall.Goal,DeltaTime,10);
			DiffLoc = NewLocation - Location;
			isMovingToCover = Move(DiffLoc) && Abs(DiffLoc.X) + Abs(DiffLoc.Y) > 1;
		}
	}
}

exec function GiveGun()
{
	local GPInventory gpi;
	local vector speed;
	speed.X = 0;
	speed.Y = 0;
	speed.Z = 0;

	gpi=Spawn(class'GPLinkGunItem');
	gpi.DropFrom(Location, speed);
}

exec function GiveRifle()
{
	local GPInventory gpi;
	local vector speed;
	speed.X = 0;
	speed.Y = 0;
	speed.Z = 0;

	gpi=Spawn(class'GPShockRifleItem');
	gpi.DropFrom(Location, speed);
}

exec function GiveTurbine()
{
	local GPTurbineItem ti;
	local vector speed;
	speed.X = 0;
	speed.Y = 0;
	speed.Z = 0;

	ti = spawn(class'GPTurbineItem');
	ti.DropFrom(Location, speed);
	//InvManager.CreateInventory(class'GPTurbineItem');
}

exec function GiveSiriCtrl()
{
	if(!GPPlayerController(Controller).bCanControlSiri) {
		GPGive(class'GPSiriControlModule');
	}
}

exec function GiveArmors()
{
	InvManager.CreateInventory(class'GPChestArmorItem');
	InvManager.CreateInventory(class'GPLCalfArmorItem');
	InvManager.CreateInventory(class'GPLUpperArmArmorItem');
	InvManager.CreateInventory(class'GPLForeArmArmorItem');
	InvManager.CreateInventory(class'GPLThighArmorItem');

	InvManager.CreateInventory(class'GPRCalfArmorItem');
	InvManager.CreateInventory(class'GPRUpperArmArmorItem');
	InvManager.CreateInventory(class'GPRForeArmArmorItem');
	InvManager.CreateInventory(class'GPRThighArmorItem');
}

exec function GPGive(class<actor> ItemClass)
{
	local GPInventory gpi;
	local vector speed;
	speed.X = 0;
	speed.Y = 0;
	speed.Z = 0;

	gpi=GPInventory(Spawn(ItemClass));
	gpi.DropFrom(Location, speed);
}

function bool DoJump( bool bUpdating )
{
	if(GPPlayerController(Controller).bCinematicMode) return false;
	return Super.DoJump(bUpdating);
}

exec function ImAhurtin()
{
	local vector speed;
	speed.X = 0;
	speed.Y = 0;
	speed.Z = 0;

	TakeDamage(1000,none,speed,speed,none);
}

DefaultProperties
{
	// Variables propias
	IsNaked=false
	IsAiming=false
	IsCrouched=false
	//softRot=false
	isMovingToCover=false

	InventoryManagerClass=class'GPInventoryManager'
	bCanPickupInventory=true
	FiringMultiplierRate=1.f
	DamageMultiplier=1.f
	bCanCrouch=false
	bCanJump=false

	IsInMenu=false

	//Components.Remove(Sprite)

	// Iluminación propia de Gandhi
	Begin Object Class=DynamicLightEnvironmentComponent Name=GPLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	LightEnvironment=GPLightEnvironment
	Components.Add(GPLightEnvironment)

	// Modelo de Gandhi
	// Set an example pawn from the UDK resources
	Begin Object class=SkeletalMeshComponent Name=GPPawnSkeletalMesh
		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=true
		//bIgnoreControllerWhenNotRendered=false
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=GPLightEnvironment
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=false

		HiddenGame=FALSE 
		HiddenEditor=FALSE
	End Object
	Mesh=GPPawnSkeletalMesh
	Components.Add(GPPawnSkeletalMesh)

	// Make the pawn slower and heavier
	JumpZ=400
	//GroundSpeed=100

	// HitPoints
	ChestPoint=1
	LeftArmPoint=2
	RightArmPoint=3
	LegsPoint=4

	bIsRagdoll = false;
	IsTurbineOn = false;
	IsCarryingWeapon = false;
	IsUnderWater = false;

	PS_EMP=ParticleSystem'empattack_fx.ParticleSystems.PS_Attack_EMP';

	Begin Object Class=SkeletalMeshComponent Name=SK_linkgun
		SkeletalMesh=SkeletalMesh'blastergun.Mesh.SK_blastergun'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
	End Object
	LinkGunMesh=SK_linkgun

	Begin Object Class=SkeletalMeshComponent Name=SK_shockrifle
		SkeletalMesh=SkeletalMesh'BlasterRifle.Mesh.SK_blaster_rifle'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
	End Object
	ShockRifleMesh=SK_shockrifle

	Begin Object Class=SkeletalMeshComponent Name=SK_turbine
		SkeletalMesh=SkeletalMesh'Turbina.Mesh.SK_Turbina'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		//Scale3D=(X=0.5,Y=0.5,Z=0.5)
		//Scale=0.5
	End Object
	TurbineMesh = SK_turbine

	WeaponAmmount = 0;

	PEMRadius = 400;
	PEMSound = SoundCue'SoundFX.Misc.SFX_PEM_Cue';
}
