class GPRepairKit extends GPInventoryItem placeable;

var(Armor) GPArmorItem ArmorToRepair;
var(Armor) int PointsToRestore;

function bool SetArmorToRepair (GPArmorItem ATR)
{
	if (ATR != None)
	{
		ArmorToRepair = ATR;
		return true;
	}
	else
	{
		return false;
	}
}

function bool Use()
{
	local GPPlayerPawn GPPawn;
	GPPawn = GPPlayerPawn(Owner);

	if (!Used && ArmorToRepair != None)
	{
		ArmorToRepair.Restore(PointsToRestore);

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
	return "Repair Kit";
}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	return false;
}

DefaultProperties
{
	PointsToRestore = 50;
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'RepairKit.Mesh.SM_RepairKit'
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
