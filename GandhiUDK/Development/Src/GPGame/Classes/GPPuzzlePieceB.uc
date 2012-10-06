class GPPuzzlePieceB extends GPPuzzlePiece;

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'PiezasPuzzle.Mesh.SM_PiezaPuzzleB'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		Scale3D=(X=2.5,Y=2.5,Z=2.5)
		Scale=2.5
	End Object
	DroppedPickupMesh=StaticMeshComponent1
	PickupFactoryMesh=StaticMeshComponent1
}
