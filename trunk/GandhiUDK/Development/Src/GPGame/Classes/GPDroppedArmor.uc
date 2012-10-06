class GPDroppedArmor extends GPDroppedPickUpItem;

var int ShieldPoints;

function DroppedFrom(Pawn P)
{
	local GPPlayerPawn GPP;

	GPP = GPPlayerPawn(P);
	if (GPP != None)
	{
		//ShieldAmount = GPP.ShieldBeltArmor;
		//GPP.ShieldBeltArmor = 0;
		//GPP.SetOverlayMaterial(None);
	}
}

// EFG: Esta función no se utiliza
function GiveTo(Pawn P)
{
	local GPPlayerPawn GPP;

	GPP = GPPlayerPawn(P);

	// EFG: Hacemos que el personaje vista la nueva armadura (y/o la añadimos al inverntario automáticamente)
	AttachToPawn(GPP, GPP.ChestArmorSocketName);

	PickedUpBy(P);
}

function int CanUseShield(GPPlayerPawn P)
{
	//return Max(0, ShieldAmount - P.ShieldBeltArmor);
	return -1;
}

auto state Pickup
{
	/*
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch(Pawn Other)
	{
		return (GPPlayerPawn(Other) != None && CanUseShield(GPPlayerPawn(Other)) > 0 && Super.ValidTouch(Other));
	}
}

DefaultProperties
{
	ShieldPoints=100;
}
