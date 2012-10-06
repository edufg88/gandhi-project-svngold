class GPInventory extends Inventory
	abstract;

var bool bReceiveOwnerEvents;	// If true, receive Owner events. OwnerEvent() is called.

var bool isAttachedToGandhi;

/** adds weapon overlay material this item uses (if any) to the GRI in the correct spot
 *  @see UTPawn.WeaponOverlayFlags, UTWeapon::SetWeaponOverlayFlags 
simulated static function AddWeaponOverlay(UTGameReplicationInfo GRI);
*/

function GivenTo( Pawn thisPawn, optional bool bDoNotActivate ) 
{
	super.GivenTo(thisPawn, bDoNotActivate);
}

/** called on the owning client just before the pickup is dropped or destroyed */
reliable client function ClientLostItem()
{
	if (Role < ROLE_Authority)
	{
		// owner change might not get replicated to client so force it here
		SetOwner(None);
	}
}

simulated event Destroyed()
{
	local Pawn P;

	P = Pawn(Owner);
	if (P != None && (P.IsLocallyControlled() || (P.DrivenVehicle != None && P.DrivenVehicle.IsLocallyControlled())))
	{
		ClientLostItem();
	}

	Super.Destroyed();
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	ClientLostItem();

	Super.DropFrom(StartLocation, StartVelocity);
	
}

simulated function AttachToPawn(Pawn NewPawn, Name SocketName)
{	
	local GPPlayerPawn GPPlayerPawn;
	local vector scale3d;
	scale3d.X=1;
	scale3d.Y=1;
	scale3d.Z=1;

	// Check the mesh and the pawn's mesh
	if (DroppedPickupMesh != None && NewPawn != None && NewPawn.Mesh != None)
	{
		GPPlayerPawn = GPPlayerPawn(NewPawn);
		if (GPPlayerPawn != None && GPPlayerPawn.Mesh.GetSocketByName(SocketName) != None)
		{
			// Reescalamos para que encaje perfecto
			DroppedPickupMesh.SetScale(1);
			DroppedPickupMesh.SetScale3D(scale3d);

			// Attach the weapon mesh to the instigator's skeletal mesh
			GPPlayerPawn.Mesh.AttachComponentToSocket(DroppedPickupMesh, SocketName);
			// Set the weapon mesh's light environment
			DroppedPickupMesh.SetLightEnvironment(GPPlayerPawn.LightEnvironment);
			// Set the weapon's shadow parent to the instigator's skeletal mesh
			DroppedPickupMesh.SetShadowParent(GPPlayerPawn.Mesh);
			// Set the weapon attachment archetype so that other clients can see what gun this pawn is carrying
			//GPPlayerPawn.we.WeaponAttachmentArchetype = GPWeapon(ObjectArchetype);

			isAttachedToGandhi = true;
		}
	}
}

function AnnouncePickup(Pawn Other) {
	class'GPHUD'.static.showHUDText(""$GetName()$" acquired.", 0);
}

/* OwnerEvent:
	Used to inform inventory when owner event occurs (for example jumping or weapon change)
	set bReceiveOwnerEvents=true to receive events.
*/
function OwnerEvent(name EventName);

// Return the name of the item
function string GetName();

defaultproperties
{
	bDropOnDeath = false;
	MessageClass=class'UTPickupMessage'

	DroppedPickupClass=class'GPRotatingDroppedPickUp'

	isAttachedToGandhi = false
}