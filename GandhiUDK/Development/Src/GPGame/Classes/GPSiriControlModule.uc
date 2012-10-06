class GPSiriControlModule extends GPInventoryItem;

// Al cogerlo se quedará en el inventario y con eso ya podemos controlar a Siri
simulated function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus)
{
	// Podemos / deberíamos controlar que el jugador lo tuviera en el
	// inventario una vez lo hayamos cogido
	local GPPlayerController GPC;
	GPC = GPPlayerController(GPPlayerPawn(Owner).Controller);
	GPC.bCanControlSiri = true;
}

function string GetName()
{
	return "Siri Control Module";
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'SiriControlModule.Mesh.SM_SiriControl'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		//Scale3D=(X=0.5,Y=0.5,Z=0.5)
		//Scale=0.5
	End Object
	DroppedPickupMesh=StaticMeshComponent1
	PickupFactoryMesh=StaticMeshComponent1
}
