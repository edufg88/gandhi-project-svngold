class GPArmorItem extends GPInventory;

//EFG: Cambiar Charges por puntos de armadura!!!!
/** the number of jumps that the owner can do before the boots run out */
var int ArmorPoints;
var int MaxArmorPoints;
/** sound to play when the boots are used */
var SoundCue ActivateSound;

var int ArmorCode;

// Está rota la pieza o no?
var bool broken;

function UpdateHUD()
{
	GPHUD(GPPlayerController(GPPlayerPawn(Owner).Controller).myHUD).UpdateArmor(ArmorCode, float(ArmorPoints)/MaxArmorPoints);
}

function Restore(int PointsToRestore)
{
	ArmorPoints += PointsToRestore;
	if (ArmorPoints > MaxArmorPoints)
	{
		ArmorPoints = MaxArmorPoints;
	}

	broken = false;
}

function bool ToTrash()
{
	local GPPlayerPawn GPPawn;
	GPPawn = GPPlayerPawn(Owner);

	GPPawn.InvManager.RemoveFromInventory(self);
	Destroy();
	return true;
}

function RenderStats(HUD HUD);

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	Super.GivenTo(NewOwner, bDoNotActivate);
	//AdjustPawn(GPPlayerPawn(NewOwner), false);
}

function ItemRemovedFromInvManager()
{
	AdjustPawn(GPPlayerPawn(Owner), true);
}

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	Super.ClientGivenTo(NewOwner, bDoNotActivate);
	if (Role < ROLE_Authority)
	{
		AdjustPawn(GPPlayerPawn(NewOwner), false);
	}
}

reliable client function ClientLostItem()
{
	local GPPlayerPawn P;

	P = GPPlayerPawn(Owner);
	if (P != None)
	{
		if (Role < ROLE_Authority)
		{
			AdjustPawn(P, true);
		}
		//P.JumpBootCharge = 0;
	}

	Super.ClientLostItem();
}

/** adds or removes our bonus from the given pawn */
function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus);

function Equip() {
	if(broken) class'GPHUD'.static.showHUDText("You can't equip a broken armor", 2000);
	else AdjustPawn(GPPlayerPawn(InvManager.Owner), false);
}

function Unequip() {
	GPPlayerPawn(InvManager.Owner).Mesh.DetachComponent(DroppedPickupMesh);
	isAttachedToGandhi = false;
}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	if(!GPDroppedPickup(Pickup).Inventory.IsA('GPArmorItem') || GPInventoryManager(GPPlayerPawn(Owner).InvManager).CanHazMoreArmor()) return false;
	//else
	class'GPHUD'.static.showHUDText("You can't carry any more armors", 4000);
	return true;
}


//function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
//{
//	if (ItemClass == Class)
//	{
//		//GPPlayerPawn(Owner).JumpBootCharge = Charges;
//		if ( PickupFactory(Pickup) != None )
//		{
//			PickupFactory(Pickup).PickedUpBy(Instigator);
//		}
//		else if ( DroppedPickup(Pickup) != None )
//		{
//			DroppedPickup(Pickup).PickedUpBy(Instigator);
//		}
//		AnnouncePickup(Instigator);
//		return true;
//	}

//	return false;
//}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	//EFG: En vez de con la variable Charges probar a utilizar la variable ARMORPOINTS o algo así...
	//if (Charges <= 0)
	//{
	//	Destroy();
	//}
	//else
	//{
	//	Super.DropFrom(StartLocation, StartVelocity);
	//}
	Super.DropFrom(StartLocation, StartVelocity);
}

// EFG: Hacer la funcion abstracta y que la herede cada componente.
// Cada componente será responsable de hacer desaparecer su pieza cuando 
// los puntos de armadura lleguen a 0...etc
//function int GetDamage()
//{
//	//if (!broken)
//	//	ArmorPoints = ArmorPoints - 15;

//	if (ArmorPoints <= 0)
//	{
//		ArmorPoints = 0;
//		broken = true;
//	}

//	return ArmorPoints;
//}

function int ApplyDamage(int damage)
{
	ArmorPoints -= damage;

	if (ArmorPoints <= 0)
	{
		ArmorPoints = 0;
		broken = true;
	}

	return ArmorPoints;
}

DefaultProperties
{
	broken = false;
}
