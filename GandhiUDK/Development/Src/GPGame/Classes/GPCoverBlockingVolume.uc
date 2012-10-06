class GPCoverBlockingVolume extends BlockingVolume
	placeable;

var BoxSphereBounds CBVBounds;

function PostBeginPlay()
{
	super.PostBeginPlay();
	CBVBounds.BoxExtent = vect(10,10,0);
}

DefaultProperties
{
	bStatic = false
	bNoDelete = false

	Begin Object Name=BrushComponent0
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=false
		BlockNonZeroExtent=true
		BlockRigidBody=true
		bDisableAllRigidBody=false
		RBChannel=RBCC_BlockingVolume
		//Bounds=CBVBounds
	End Object

	bWorldGeometry=true
	bCollideActors=True
	bBlockActors=True
	bBlockCamera=False
}
