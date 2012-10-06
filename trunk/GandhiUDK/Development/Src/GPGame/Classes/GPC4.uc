class GPC4 extends GPInventoryItem placeable;

function string GetName()
{
	return "C4";
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'C4.Mesh.SM_C4'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
	End Object
	DroppedPickupMesh=StaticMeshComponent1
	PickupFactoryMesh=StaticMeshComponent1
	
}

