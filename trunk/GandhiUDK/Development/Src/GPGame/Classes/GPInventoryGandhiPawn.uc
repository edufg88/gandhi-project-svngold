class GPInventoryGandhiPawn extends Pawn placeable;

event PostBeginPlay() {
	super.PostBeginPlay();

	GPGame(WorldInfo.Game).InvGandhi = self;
}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=GPLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	Components.Add(GPLightEnvironment)

	Begin Object class=SkeletalMeshComponent Name=GPEnemySkeletalMesh
		//SkeletalMesh'Droid.Mesh.SK_Droid_Copyy'
		SkeletalMesh=SkeletalMesh'Gandhi.Mesh.SK_Gandhi'
		AnimSets(0)=AnimSet'Gandhi.Mesh.AS_Gandhi'
		AnimTreeTemplate=AnimTree'Gandhi.AT_Gandhi_Inventory'
		LightEnvironment=GPLightEnvironment
	End Object
	DrawScale=5.0
	Mesh = GPEnemySkeletalMesh
	Components.Add(GPEnemySkeletalMesh)
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0050.000000
	End Object
	CylinderComponent=CollisionCylinder

	Components.Remove(Sprite)

	ControllerClass=class'GPBaseAIController'
}
