// Base class of dropped pickups for items that don't actually have an Inventory class
class GPDroppedPickUpItem extends GPDroppedPickUp;

var SoundCue PickupSound;

simulated event SetPickupMesh(PrimitiveComponent NewPickupMesh);

event PostBeginPlay()
{
	// spawn an instance of the fake item for AI queries
	Inventory = Spawn(InventoryClass);

	Super.PostBeginPlay();
}

event Destroyed()
{
	Super.Destroyed();

	if (Inventory != None)
	{
		Inventory.Destroy();
	}
}

/** initialize pickup from Pawn that dropped it */
function DroppedFrom(Pawn P);

function PickedUpBy(Pawn P)
{
	PlaySound(PickupSound);

	Super.PickedUpBy(P);
}

simulated function AttachToPawn(Pawn NewPawn, Name SocketName)
{	
	local GPPlayerPawn GPPlayerPawn;
	
	// Check the mesh and the pawn's mesh
	if (PickupMesh != None && NewPawn != None && NewPawn.Mesh != None)
	{
		GPPlayerPawn = GPPlayerPawn(NewPawn);
		if (GPPlayerPawn != None && GPPlayerPawn.Mesh.GetSocketByName(SocketName) != None)
		{
			// Attach the weapon mesh to the instigator's skeletal mesh
			GPPlayerPawn.Mesh.AttachComponentToSocket(PickupMesh, SocketName);
			// Set the weapon mesh's light environment
			PickupMesh.SetLightEnvironment(GPPlayerPawn.LightEnvironment);
			// Set the weapon's shadow parent to the instigator's skeletal mesh
			PickupMesh.SetShadowParent(GPPlayerPawn.Mesh);
			// Set the weapon attachment archetype so that other clients can see what gun this pawn is carrying
			//GPPlayerPawn.we.WeaponAttachmentArchetype = GPWeapon(ObjectArchetype);
		}
	}
}

simulated function DetachFromPawn(Pawn NewPawn, Name SocketName)
{
	local GPPlayerPawn GPPlayerPawn;
	GPPlayerPawn= GPPlayerPawn(NewPawn);

	if (PickupMesh != None)
	{
		if (GPPlayerPawn != None && GPPlayerPawn.Mesh.GetSocketByName(SocketName) != None)
		{
			GPPlayerPawn.Mesh.DetachComponent(PickupMesh);
		}
	}
}


defaultproperties
{
	InventoryClass=class'GPInventory'
}