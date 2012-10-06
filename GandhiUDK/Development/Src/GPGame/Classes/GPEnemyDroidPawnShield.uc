class GPEnemyDroidPawnShield extends GPEnemyDroidPawn;

var bool bIsCovering;
var bool bHasShield;

/////////////////////////////////////////////////
// Sockets
/////////////////////////////////////////////////
var(Pawn) const Name ShieldSocketName;

/////////////////////////////////////////////////
// Posibles piezas del Droide
/////////////////////////////////////////////////
var(Pawn) MeshComponent ShieldArmorMesh;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
}
function LoadArmor()
{
	Super.LoadArmor();
	Mesh.AttachComponentToSocket(ShieldArmorMesh, ShieldSocketName);
}

function ImpactOnShield()
{
	// Si impacta en el escudo no hacemos nada
	return;
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	//// QUITAR ESTO y ARREGLAR
	//NotifyTakeHit(EventInstigator, HitLocation, Damage, DamageType, vect(0,0,0), DamageCauser);

	//Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

DefaultProperties
{
	bIsCovering = false;
	bHasShield = true;

		// Iluminación propia del droide
	Begin Object Class=DynamicLightEnvironmentComponent Name=GPLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	//LightEnvironment=GPLightEnvironment
	Components.Add(GPLightEnvironment)
	
/////////////////////////////////////////////////
	// Armaduras 
	//////////////////////////////////////////////////
	
	Begin Object Class=StaticMeshComponent Name=SM_ChestArmor
		StaticMesh=StaticMesh'Droid.Mesh.SM_BodyArmor02'
		//StaticMesh=FracturedStaticMesh'Droid.Mesh.SM_BodyArmor_FRACTURED'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	ChestArmorMesh=SM_ChestArmor

	Begin Object Class=StaticMeshComponent Name=SM_LForeArmArmor
		StaticMesh=StaticMesh'Droid.Mesh.SM_LForeArmArmor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	LowerLeftArmArmorMesh=SM_LForeArmArmor

	Begin Object Class=StaticMeshComponent Name=SM_LUpperArmArmor
		StaticMesh=StaticMesh'Droid.Mesh.SM_UpperArmArmor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	UpperLeftArmArmorMesh=SM_LUpperArmArmor

	Begin Object Class=StaticMeshComponent Name=SM_RForeArmArmor
		StaticMesh=StaticMesh'Droid.Mesh.SM_RForeArmArmor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	LowerRightArmArmorMesh=SM_RForeArmArmor

	Begin Object Class=StaticMeshComponent Name=SM_RUpperArmArmor
		StaticMesh=StaticMesh'Droid.Mesh.SM_RUpperArmArmor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	UpperRightArmArmorMesh=SM_RUpperArmArmor

	Begin Object Class=StaticMeshComponent Name=SM_LLeg1Armor
		StaticMesh=StaticMesh'Droid.Mesh.SM_LLegArmor02'
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	LeftLeg1ArmorMesh=SM_LLeg1Armor

	Begin Object Class=StaticMeshComponent Name=SM_LLeg2Armor
		StaticMesh=StaticMesh'Droid.Mesh.SM_LLeg2Armor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	LeftLeg2ArmorMesh=SM_LLeg2Armor

	Begin Object Class=StaticMeshComponent Name=SM_LLeg3Armor
		StaticMesh=StaticMesh'Droid.Mesh.SM_LLeg3Armor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	LeftLeg3ArmorMesh=SM_LLeg3Armor

	Begin Object Class=StaticMeshComponent Name=SM_RLeg1Armor
		StaticMesh=StaticMesh'Droid.Mesh.SM_RLegArmor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	RightLeg1ArmorMesh=SM_RLeg1Armor
	//Components.Add(SM_RLeg1Armor)

	Begin Object Class=StaticMeshComponent Name=SM_RLeg2Armor
		StaticMesh=StaticMesh'Droid.Mesh.SM_RLeg2Armor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	RightLeg2ArmorMesh=SM_RLeg2Armor
	//Components.Add(SM_RLeg2Armor)

	Begin Object Class=StaticMeshComponent Name=SM_RLeg3Armor
		StaticMesh=StaticMesh'Droid.Mesh.SM_RLeg3Armor02'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	RightLeg3ArmorMesh=SM_RLeg3Armor
	//Components.Add(SM_RLeg3Armor)


	////////////////////////////////////

	ShieldSocketName="ShieldPoint";

	Begin Object Class=StaticMeshComponent Name=SM_ShieldArmor
		StaticMesh=StaticMesh'Droid.Mesh.SM_Shield02'
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	ShieldArmorMesh=SM_ShieldArmor


	Begin Object class=SkeletalMeshComponent Name=GPEnemySkeletalMesh
		PhysicsAsset=PhysicsAsset'Droid.Mesh.PA_Droid_Physics'
		SkeletalMesh=SkeletalMesh'Droid.Mesh.SK_Droide02'
		AnimSets(0)=AnimSet'Droid.Mesh.AS_Droide02'
		AnimTreeTemplate=AnimTree'Droid.Mesh.AT_Droid02'
		bHasPhysicsAssetInstance=true

		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=true
		//bIgnoreControllerWhenNotRendered=false
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
		LightEnvironment=GPLightEnvironment

	End Object

	Mesh = GPEnemySkeletalMesh
	Components.Add(GPEnemySkeletalMesh)
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0010.000000
		CollisionHeight=+0055.000000
	End Object
	CylinderComponent=CollisionCylinder

	ControllerClass=class'GPEnemyDroidController'
	GroundSpeed=200.0
	WeaponArchetype = GPWeapon'GP_Archetypes.Weapons.GPWeapon_LinkGun_Droid'
	DrawScale=5.5
}
