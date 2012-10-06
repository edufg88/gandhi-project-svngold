class GPEnemyBossPawn extends GPEnemyDroidPawn;

DefaultProperties
{
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

	Begin Object class=SkeletalMeshComponent Name=GPEnemySkeletalMesh
		PhysicsAsset=PhysicsAsset'Droid.Mesh.PA_Droid_Physics'
		SkeletalMesh=SkeletalMesh'Boss.Meshes.SK_theBoss'
		AnimSets(0)=AnimSet'Boss_Animations.AS_theBoss'
		AnimTreeTemplate=AnimTree'Boss_Animations.AT_theBoss'
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
	DrawScale=1.0
	Mesh = GPEnemySkeletalMesh
	Components.Add(GPEnemySkeletalMesh)
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0040.000000
	End Object
	CylinderComponent=CollisionCylinder

	ControllerClass=class'GPEnemyDroidController'
	GroundSpeed=200.0
	WeaponArchetype = GPWeapon'GP_Archetypes.Weapons.GPWeapon_ShockRifle'
}
