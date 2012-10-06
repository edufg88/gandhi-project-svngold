class GPDoorKey extends GPInventoryItem placeable;

var(Key) string code;
var(Key) bool cutSceneKey;


function SetCode (string newCode)
{
	code = newCode;
}

function string getRoom()
{
	switch(code) {
		case "WC1":
			return "WC";
		case "H3":
			return "Bedroom 3";
		case "saladescanso":
			return "Hall";
		case "H5":
			return "Bedroom 5";
		case "salainundada":
			return "Conference Room";
		case "ascensorP1":
			return "Elevator";
	}
}

function int getNumCode()
{
	switch(code) {
		case "WC1":
			return 1;
		case "H3":
			return 2;
		case "saladescanso":
			return 3;
		case "H5":
			return 4;
		case "salainundada":
			return 5;
		case "ascensorP1":
			return 6;
	}
}

function keyUsed() 
{
	GPPlayerPawn(Owner).InvManager.RemoveFromInventory(self);
	Destroy();
}

function string GetName()
{
	return "Door Key for "$getRoom();
}

//// Función para controlar la cantidad de ítems de un mismo tipo que podemos llevar, por ejemplo
function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	//class'GPHUD'.static.showHUDText("Door key for "$code$" acquired", 3000, false, true);
	return false;
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'labkey.Mesh.SM_labKey'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		Scale3D=(X=0.7,Y=0.7,Z=0.7)
		Scale=0.7
	End Object
	DroppedPickupMesh=StaticMeshComponent1
	PickupFactoryMesh=StaticMeshComponent1

	code="test1";
	cutSceneKey=false;
	bIsPlaceable=false;
}
