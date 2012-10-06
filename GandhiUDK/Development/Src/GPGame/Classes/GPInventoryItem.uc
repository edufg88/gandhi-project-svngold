class GPInventoryItem extends GPInventory placeable;

var() bool bIsPlaceable; // Se puede spawnear en el editor
var bool Used; // Qué pasa cuando un objeto se usa?

event PostBeginPlay()
{
	if (bIsPlaceable)
	{
		self.DropFrom(self.Location, vect(0,0,0));
	}
}

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	Super.GivenTo(NewOwner, bDoNotActivate);
	AdjustPawn(GPPlayerPawn(NewOwner), false);
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
	}

	Super.ClientLostItem();
}

// Función con la que se aplicaría un efecto inmediato de algún ítem al cogerlo
simulated function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus);

// Función con la que se aplica el efecto del item al usarlo desde el inventario
function bool Use();

//// Función para controlar la cantidad de ítems de un mismo tipo que podemos llevar, por ejemplo
//function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
//{
//	return false;
//}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	Super.DropFrom(StartLocation, StartVelocity);
}


DefaultProperties
{
	Used = false;

	// EFG: Cambiar los efectos de sonido
	RespawnTime=100.0
	bReceiveOwnerEvents=true

	PickupSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_PickupCue'
	//ActivateSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_JumpCue'

	Components.Remove(Sprite);
	// Sprite para mostrar la zona
	Begin Object Class=SpriteComponent Name=SpriteTee
		Sprite=Texture2D'Miscelanea.Texture.T_ItemSpawner'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Misc"
	End Object
	Components.Add(SpriteTee)
}
