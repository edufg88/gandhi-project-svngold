class GPEnergyItem extends GPInventoryItem placeable;

// Puntos de energía que devuelve al jugador
var(Energy) int EnergyPoints;

function bool Use()
{
	local GPPlayerPawn GPPawn;
	GPPawn = GPPlayerPawn(Owner);

	if (!Used)
	{
		GPPawn.HealDamage(EnergyPoints, None, None);
		//GPPawn.Health /= 2; //Pruebas
		Used = true;
		// Una vez usado deberíamos hacerlo desaparecer del inventario...
		GPPawn.InvManager.RemoveFromInventory(self);
		Destroy();
		return true;
	}
	else
	{
		return false;
	}
}

function string GetName()
{
	return "Energy Cell";
}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	return false;
}

DefaultProperties
{
	EnergyPoints = 50;

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'capsules.Mesh.SM_EnergyCell'
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
