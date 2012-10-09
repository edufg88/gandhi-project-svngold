class GPEnemyDroidPawn extends GPEnemyPawn
	placeable
	HideCategories(Camera, Debug, Physics, Advanced, Object);

// Class
var ProtectedWrite GPClass ClassArchetype;
// Inventory (Separar en herencia por clases)
var const GPWeapon WeaponArchetype;
//var const ... Shield; (El resto de cosas del inventario)
/////////////////////////////////////////////////
//  Posible Hit Points
/////////////////////////////////////////////////
var(HitPoint) const int ChestPoint;
var(HitPoint) const int LeftArmPoint;
var(HitPoint) const int RightArmPoint;
var(HitPoint) const int LegsPoint;
var(HitPoint) const int WeakPoint;

/////////////////////////////////////////////////
//  Hit Points Armor Points
/////////////////////////////////////////////////
var (HitPoint) int ChestArmorPoints;
var (HitPoint) int LeftArm1ArmorPoints;
var (HitPoint) int LeftArm2ArmorPoints;
var (HitPoint) int RightArm1ArmorPoints;
var (HitPoint) int RightArm2ArmorPoints;
var (HitPoint) int LLeg1ArmorPoints;
var (HitPoint) int LLeg2ArmorPoints;
var (HitPoint) int LLeg3ArmorPoints;
var (HitPoint) int RLeg1ArmorPoints;
var (HitPoint) int RLeg2ArmorPoints;
var (HitPoint) int RLeg3ArmorPoints;

/////////////////////////////////////////////////
// Sockets
/////////////////////////////////////////////////
var(Pawn) const Name WeaponSocketName;
var(Pawn) const Name ChestArmorSocketName;
var(Pawn) const Name UpperLeftArmArmorSocketName;
var(Pawn) const Name LowerLeftArmArmorSocketName;
var(Pawn) const Name UpperRightArmArmorSocketName;
var(Pawn) const Name LowerRightArmArmorSocketName;
var(Pawn) const Name LeftLeg1ArmorSocketName;
var(Pawn) const Name LeftLeg2ArmorSocketName;
var(Pawn) const Name LeftLeg3ArmorSocketName;
var(Pawn) const Name RightLeg1ArmorSocketName;
var(Pawn) const Name RightLeg2ArmorSocketName;
var(Pawn) const Name RightLeg3ArmorSocketName;
var(Pawn) const Name WeakPointSocketName;

/////////////////////////////////////////////////
// Posibles piezas del Droide
/////////////////////////////////////////////////
var(Pawn) MeshComponent ChestArmorMesh;
var(Pawn) MeshComponent UpperLeftArmArmorMesh;
var(Pawn) MeshComponent LowerLeftArmArmorMesh;
var(Pawn) MeshComponent UpperRightArmArmorMesh;
var(Pawn) MeshComponent LowerRightArmArmorMesh;
var(Pawn) MeshComponent LeftLeg1ArmorMesh;
var(Pawn) MeshComponent LeftLeg2ArmorMesh;
var(Pawn) MeshComponent LeftLeg3ArmorMesh;
var(Pawn) MeshComponent RightLeg1ArmorMesh;
var(Pawn) MeshComponent RightLeg2ArmorMesh;
var(Pawn) MeshComponent RightLeg3ArmorMesh;


// Explosion particle effect to play when the pawn has died
var(Pawn) const ParticleSystem ExplosionParticleTemplate;

// EFG: Clase encargada de crear el objeto que soltará el enemigo al morir
//var GPDroppedItemsGenerator DIG;

// Zona de patrulla para el droide
var GPPatrolZone PatrolZ;
// Zona de cobertura para el droide
var GPDroidZone DroidZ;

// Current weapon attachment
var ProtectedWrite transient GPWeapon WeaponAttachment;
// Current weapon archetype used for attachment purposes
var RepNotify GPWeapon WeaponAttachmentArchetype;

var EPhysics DefaultPhysics;

/** Slot node used for playing full body anims. */
var AnimNodeSlot FullBodyAnimSlot;

/** Slot node used for playing animations only on the top half. */
var AnimNodeSlot TopHalfAnimSlot;

// Reference to the AimOffset node in the AnimTree
var ProtectedWrite transient AnimNodeAimOffset AnimNodeAimOffset;

var int PZindex;

// Firing multiplier rate
var ProtectedWrite transient float FiringMultiplierRate;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	//InvManager.CreateInventory(class'UTWeap_LinkGun', false);
	//Weapon.AddAmmo(999);
	//Weapon.bCanThrow = false;

	//DIG = Spawn(class'GPDroppedItemsGenerator');

	//// Añadimos las armas en función del tipo de droide
	//if (Controller.IsA('GPEnemyDroidControllerDefensive'))
	//{
	//	//InvManager.CreateInventory(class'G
	//}
	//else if (Controller.IsA('GPEnemyDroidControllerOffensive'))
	//{
	//}

	Health = 250;
	// Añadimos las armas iniciales del Droide
	AddDefaultInventory();
	// Añadimos las armaduras iniciales al Droide
	LoadArmor();
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
	local GPEnemyDroidController PlayerController;
	//local PlayerController PlayerController;
	local float CurrentPitch;

	if (AnimNodeAimOffset != None)
	{
		// If player controller is valid then Use local controller pitch
		PlayerController = GPEnemyDroidController(Controller);
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


function AddDefaultInventory()
{
	local GPInventoryManager GPInventoryManager;
	local GPWeapon GPWeapon;
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
	GPWeapon = GPWeapon(Weapon);
	GPWeapon.GPEnemyDroidPawn = self;
	UpdateWeaponAttachment();
	//ForEach InvManager.InventoryActors(class'GPWeapon', GPWeapon)
	//{
	//	Weapon = GPWeapon;

	//	break;
	//}
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
		WeaponAttachment.DetachWeapon();
		WeaponAttachment.Destroy();
	}

	// Spawn the weapon attachment
	WeaponAttachment = Spawn(WeaponArchetype.Class,,,,, WeaponArchetype);
	if (WeaponAttachment != None)
	{
		// Attach the weapon to myself
		WeaponAttachment.AttachToPawn(Self);
		// Set the weapon attachments instigator
		WeaponAttachment.Instigator = Self;
	}
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
	//if (RecoilSkelControl != None)
	//{		
	//	if (GPWeapon != None && GPWeapon.CurrentFireMode < GPWeapon.FireModes.Length && GPWeapon.FireModes[FiringMode] != None && GPWeapon.FireModes[FiringMode].HasRecoil)
	//	{
	//		RecoilSkelControl.bPlayRecoil = true;
	//	}
	//}

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
 * Detects which part of the body has been hit
 * returns:
 *  - 1: Chest
 *  - 2: Left Arm
 *  - 3: Right Arm
 *  - 4: Legs
 */
function int DetectHitPoint(vector HitLocation, optional TraceHitInfo HitInfo)
{
	local vector Chest, ULA, URA, ULL, WP;
	local rotator socketRotation;
	local int iAux, iAux2, iAux3;
	local int iAuxWeakPoint;
	
	// Comprobamos la parte superior
	self.Mesh.GetSocketWorldLocationAndRotation(ChestArmorSocketName, Chest, socketRotation, 0);
		
	if (HitLocation.Z > Chest.Z)
	{
		self.Mesh.GetSocketWorldLocationAndRotation(UpperLeftArmArmorSocketName, ULA, socketRotation, 0);
		self.Mesh.GetSocketWorldLocationAndRotation(UpperRightArmArmorSocketName, URA, socketRotation, 0);
		self.Mesh.GetSocketWorldLocationAndRotation(WeakPointSocketName, WP, socketRotation, 0);
		// Estamos seguro por encima de la cintura
		// Comprobamos la distancia X entre el socket del pecho y los sockets de la parte superior 
		// del brazo para determinar el impacto

		// Mejor utilizar vectores que componentes
		iAux = VSize(Chest - HitLocation);
		iAux2 = VSize(ULA - HitLocation);
		iAux3 = VSize(URA - HitLocation);
		iAuxWeakPoint = VSize(WP - HitLocation);

		if (iAux < iAux2)
		{
			// No estamos en la parte izquierda
			if (iAux < iAux3)
			{
				// Estamos en el pecho pero puede que sea el punto debil
				if (iAux < iAuxWeakPoint)
					return ChestPoint;
				else
					return WeakPoint;
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
			iAux = abs(Chest.X - HitLocation.X);
			iAux2 = abs(ULA.X - HitLocation.X);
			iAux3 = abs(URA.X - HitLocation.X);

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

function LoadArmor()
{
	local int random;
	random = Rand(3);

	switch (random)
	{
		// Pack 1: Torso + ForeArms...
		case 0:

			break;
		case 1:
			break;
		case 2:
			break;
	}

	Mesh.AttachComponentToSocket(ChestArmorMesh, ChestArmorSocketName);
	Mesh.AttachComponentToSocket(UpperLeftArmArmorMesh, UpperLeftArmArmorSocketName);
	Mesh.AttachComponentToSocket(LowerLeftArmArmorMesh, LowerLeftArmArmorSocketName);
	Mesh.AttachComponentToSocket(UpperRightArmArmorMesh, UpperRightArmArmorSocketName);
	Mesh.AttachComponentToSocket(LowerRightArmArmorMesh, LowerRightArmArmorSocketName);
	Mesh.AttachComponentToSocket(LeftLeg1ArmorMesh, LeftLeg1ArmorSocketName);
	Mesh.AttachComponentToSocket(LeftLeg2ArmorMesh, LeftLeg2ArmorSocketName);
	Mesh.AttachComponentToSocket(LeftLeg3ArmorMesh, LeftLeg3ArmorSocketName);
	Mesh.AttachComponentToSocket(RightLeg1ArmorMesh, RightLeg1ArmorSocketName);
	Mesh.AttachComponentToSocket(RightLeg2ArmorMesh, RightLeg2ArmorSocketName);
	Mesh.AttachComponentToSocket(RightLeg3ArmorMesh, RightLeg3ArmorSocketName);
}

function ControlDamage(Controller PC, int HitComponent, int Damage)
{
	local bool bBreak;
	//local int Damage;
	local vector socketLocation;
		
	bBreak = false;
	switch (HitComponent)
	{
		case WeakPoint:
			ClientMessage("WEAKPOINT");
			// Si el daño es en el punto débil, hacemos daño directo al personaje
			bBreak = true;
			break;

		case ChestPoint:
			ClientMessage("CHEST");
			if (ChestArmorPoints > 0)
			{
				ChestArmorPoints -= Damage;
				
				// Hemos destruido la pieza?
				if (ChestArmorPoints <= 0)
				{
					Mesh.DetachComponent(ChestArmorMesh);
					ChestArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(ChestArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else
			{
				bBreak = true;
			}
			
			ClientMessage("Chest armor points: " $ ChestArmorPoints);
			break;

		case LeftArmPoint:
			ClientMessage("LEFT ARM");

			if (LeftArm1ArmorPoints > 0)
			{
				LeftArm1ArmorPoints -= Damage;

				if (LeftArm1ArmorPoints < 0)
				{
					Mesh.DetachComponent(UpperLeftArmArmorMesh);
					LeftArm1ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(UpperLeftArmArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else if (LeftArm2ArmorPoints > 0)
			{
				LeftArm2ArmorPoints -= Damage;

				if (LeftArm2ArmorPoints < 0)
				{
					Mesh.DetachComponent(LowerLeftArmArmorMesh);
					LeftArm2ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(LowerLeftArmArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else
			{
				bBreak = true;
			}
			break;

		case RightArmPoint:
			ClientMessage("RIGHT ARM");

			if (RightArm1ArmorPoints > 0)
			{
				RightArm1ArmorPoints -= Damage;

				if (RightArm1ArmorPoints < 0)
				{
					Mesh.DetachComponent(UpperRightArmArmorMesh);
					RightArm1ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(UpperRightArmArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else if (RightArm2ArmorPoints > 0)
			{
				RightArm2ArmorPoints -= Damage;

				if (RightArm2ArmorPoints < 0)
				{
					Mesh.DetachComponent(LowerRightArmArmorMesh);
					RightArm2ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(LowerRightArmArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else
			{
				bBreak = true;
			}
			
			break;

		case LegsPoint:
			ClientMessage("LEGS");
			if (LLeg1ArmorPoints > 0)
			{
				LLeg1ArmorPoints -= Damage;
				if (LLeg1ArmorPoints < 0)
				{
					Mesh.DetachComponent(LeftLeg1ArmorMesh);
					LLeg1ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(LeftLeg1ArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else if (RLeg2ArmorPoints > 0)
			{
				RLeg2ArmorPoints -= Damage;
				if (RLeg2ArmorPoints < 0)
				{
					Mesh.DetachComponent(RightLeg2ArmorMesh);
					RLeg2ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(RightLeg2ArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else if (LLeg2ArmorPoints > 0)
			{
				LLeg2ArmorPoints -= Damage;
				if (LLeg2ArmorPoints < 0)
				{
					Mesh.DetachComponent(LeftLeg2ArmorMesh);
					LLeg2ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(LeftLeg2ArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else if (RLeg1ArmorPoints > 0)
			{
				RLeg1ArmorPoints -= Damage;
				if (RLeg1ArmorPoints < 0)
				{
					Mesh.DetachComponent(RightLeg1ArmorMesh);
					RLeg1ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(RightLeg1ArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else if (RLeg3ArmorPoints > 0)
			{
				RLeg3ArmorPoints -= Damage;
				if (RLeg3ArmorPoints < 0)
				{
					Mesh.DetachComponent(RightLeg3ArmorMesh);
					RLeg3ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(RightLeg3ArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else if (LLeg3ArmorPoints > 0)
			{
				LLeg3ArmorPoints -= Damage;
				if (LLeg3ArmorPoints < 0)
				{
					Mesh.DetachComponent(LeftLeg3ArmorMesh);
					LLeg3ArmorPoints = 0;
					if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
					{
						mesh.GetSocketWorldLocationAndRotation(LeftLeg3ArmorSocketName, socketLocation);
						WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, socketLocation);
					}
				}
			}
			else
			{
				bBreak = true;
			}
			break;
	}

	// No hay pieza, el daño va directamente al personaje
	if (bBreak)
	{
		Super.TakeDamage(Damage, PC, Location, Vect(0,0,0), class'UTDmgType_LinkPlasma');
		bBreak = false;
	}
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}



simulated function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local vector force;

	force = self.Location - GPEnemyDroidController(Controller).Gandhi.Location;
	force = Normal(force)*200;

	if (Super.Died(Killer, DamageType, HitLocation))
	{
		// Estamos muertos...
		//GPEnemyDroidController(Controller).GotoState('Dead');
		
		// Modo RagDoll
		SetRagdoll();

		//Mesh.AddForce(force, location);
		Mesh.AddImpulse(force, location);
	
		// Spawn the explosion particle effect
		if (WorldInfo.MyEmitterPool != None && ExplosionParticleTemplate != None)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionParticleTemplate, Location);
		}

		// EFG: Al morir arroja objeto
		ThrowObject();

		// Control de la zona de sonido
		SoundZ.numberEnemies--;
		if (SoundZ.numberEnemies == 0)
		{
			if (GPGame(WorldInfo.Game).PlayingTensionSound)
			{
				SoundZ.StopTension();
				GPGame(WorldInfo.Game).PlayingTensionSound = false;
			}
		}

		return true;
	}

  return false;
}

//event ThrowObject()
//{
//	DIG.DropRandomItem(self.Location);
//}


defaultproperties
{
	
	bCanStepUpOn = false

	ExplosionParticleTemplate = ParticleSystem'FX_Explosions.ParticleSystems.PS_BaseExplosion';

	// Socket Names --------------
	WeaponSocketName="WeaponPoint";
	ChestArmorSocketName="ChestArmor";
	UpperLeftArmArmorSocketName="LUpperArmArmor";
	LowerLeftArmArmorSocketName="LForeArmArmor";
	UpperRightArmArmorSocketName="RUpperArmArmor";
	LowerRightArmArmorSocketName="RForeArmArmor";
	LeftLeg1ArmorSocketName="LLeg1Armor";
	LeftLeg2ArmorSocketName="LLeg2Armor";
	LeftLeg3ArmorSocketName="LLeg3Armor";
	RightLeg1ArmorSocketName="RLeg1Armor";
	RightLeg2ArmorSocketName="RLeg2Armor";
	RightLeg3ArmorSocketName="RLeg3Armor";
	WeakPointSocketName="WeakPoint";

	// HitPoints -------------------
	ChestPoint=1
	LeftArmPoint=2
	RightArmPoint=3
	LegsPoint=4
	WeakPoint=5

	// Armor Points ---------------
	ChestArmorPoints = 100;
	LeftArm1ArmorPoints = 50;
	LeftArm2ArmorPoints = 50;
	RightArm1ArmorPoints = 50;
	RightArm2ArmorPoints = 50;
	LLeg1ArmorPoints = 33;
	LLeg2ArmorPoints = 33;
	LLeg3ArmorPoints = 33;
	RLeg1ArmorPoints = 33;
	RLeg2ArmorPoints = 33;
	RLeg3ArmorPoints = 33;
	
	

	InventoryManagerClass=class'GPInventoryManager'
	ClassArchetype = GPClass'GP_Archetypes.Pawns.GandhiClass'

	DefaultPhysics = PHYS_Walking;

	FiringMultiplierRate=1.f

}
