class GPInventoryManager extends InventoryManager;

const MAXARMORS = 10;

var GPWeapon oldweapon;
var GPWeapon waux;
var GPWeapon isChangingToWeapon;
var GPWeapon wantsWeapon;

var bool firstArmor;
var bool gotGun;
var bool gotRifle;
/**
 * Spawns a new Inventory actor based on InventoryArchetype, and adds it to the Inventory Manager.
 *
 * @param	InventoryArchetype		Archetype of the inventory item to spawn and add.
 * @return							Inventory actor, None if couldn't be spawned.
 */
simulated function Inventory CreateInventoryFromArchetype(Inventory InventoryArchetype, optional bool bDoNotActivate)
{
	local Inventory Inv;

	// Ensure that the inventory archetype is valid
	if (InventoryArchetype == None)
	{
		return None;
	}

	// Spawn the inventory 
	Inv = Spawn(InventoryArchetype.Class, Owner,,,, InventoryArchetype);
	if (Inv != None)
	{
		// If could not add the inventory, then destroy it
		if (!AddInventory(Inv, bDoNotActivate))
		{
			Inv.Destroy();
			return None;
		}
		// Could add the inventory item, return it
		else
		{
			return Inv;
		}
	}

	return None;
}

event Destroyed()
{
	//local int i;
	//i = 0;
	//DiscardInventory();
}

function bool HandlePickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	if(GPDoorKey(GPDroppedPickup(Pickup).Inventory) != none && GPDoorKey(GPDroppedPickup(Pickup).Inventory).cutSceneKey
			&& GPGame(WorldInfo.Game).PlayingTensionSound) {
		class'GPHUD'.static.showHUDText("You can't pick up this key while in combat", 3000);
		return false;
	}
	if(GPLinkGunItem(GPDroppedPickup(Pickup).Inventory) != none && gotGun) {
		Pickup.Destroy();
		return false;
	}
	if(GPShockRifleItem(GPDroppedPickup(Pickup).Inventory) != none && gotRifle) {
		Pickup.Destroy();
		return false;
	}
	return super.HandlePickupQuery(ItemClass, Pickup);
}

simulated function bool AddInventory( Inventory NewItem, optional bool bDoNotActivate )
{
	local bool bResult;
	local GPPlayerPawn P;

	P = GPPlayerPawn(Owner);

	if (NewItem.IsA('GPLinkGunItem'))
	{
		gotGun = true;
		CreateInventoryFromArchetype(GPPlayerReplicationInfo(P.PlayerReplicationInfo).ClassArchetype.WeaponArchetypes[0]);
		
		if (P.WeaponAmmount == 0)
		{
			P.IsCarryingWeapon = true;
		}
		else
		{
			P.Mesh.AttachComponentToSocket(P.LinkGunMesh, P.FundaPistolaSocketName);
		}

		P.WeaponAmmount++;

		return true;
	}
	else if (NewItem.IsA('GPShockRifleItem'))
	{
		gotRifle = true;
		CreateInventoryFromArchetype(GPPlayerReplicationInfo(P.PlayerReplicationInfo).ClassArchetype.WeaponArchetypes[1]);
		
		if (P.WeaponAmmount == 0)
		{
			P.IsCarryingWeapon = true;
		}
		else
		{
			P.Mesh.AttachComponentToSocket(P.ShockRifleMesh, P.FundaRifleSocketName);
		}

		P.WeaponAmmount++;

		return true;
	}

	if (Role == ROLE_Authority)
	{
		bResult = super.AddInventory(NewItem, bDoNotActivate);
		if(firstArmor && NewItem.IsA('GPArmorItem')) {
			firstArmor = false;
			class'GPHUD'.static.showHUDText("Press I to enter Inventory. Drag & drop, or RMB, to equip and unequip.", 5000);
		}
	}

	return bResult;
}

reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
	if(oldweapon != none) oldweapon.activeWeap = false;
	if(DesiredWeapon != none) GPWeapon(DesiredWeapon).activeWeap = true;
	oldweapon = GPWeapon(DesiredWeapon);

	if(IsPlayerOwned()) {
		class'GPHUD'.static.setHUDWeapon(GPWeapon(DesiredWeapon).WeaponName);
	}

	super.SetCurrentWeapon(DesiredWeapon);
}

//function Inventory HasInventoryOfClass(class<Inventory> InvClass)
//{
//	local inventory inv;

//	inv = InventoryChain;
//	while(inv!=none)
//	{
//		if (Inv.Class==InvClass)
//			return Inv;

//		Inv = Inv.Inventory;
//	}

//	return none;
//}

/**
 * Returns an array of every of the armor pieces carried
 * */
simulated function GetArmorList(out array<GPArmorItem> ArmorList)
{
	local GPArmorItem Armor;
	//local int i;

	ForEach InventoryActors( class'GPArmorItem', Armor )
	{
		if(Armor.isAttachedToGandhi) ArmorList.AddItem(Armor);
		//if ( WeaponList.Length>0 )
		//{
		//	// Find it's place and put it there.
			

		//	for (i=0;i<WeaponList.Length;i++)
		//	{
		//		if (ArmorList[i].InventoryWeight > Weap.InventoryWeight)
		//		{
		//			WeaponList.Insert(i,1);
		//			WeaponList[i] = Weap;
		//			break;
		//		}
		//	}
		//	if (i==WeaponList.Length)
		//	{
		//		WeaponList.Length = WeaponList.Length+1;
		//		WeaponList[ i] = Weap;
		//	}
		//}
		//else
		//{
		//	WeaponList.Length = 1;
		//	WeaponList[0] = Weap;
		//}
	}
}

/**
 * Returns an array of every of the armor pieces carried
 * */
simulated function bool CanHazMoreArmor()
{
	local GPArmorItem Armor;
	local int uneqArmors;

	uneqArmors = 0;

	ForEach InventoryActors( class'GPArmorItem', Armor )
	{
		if(!Armor.isAttachedToGandhi && !Armor.IsA('GPTurbineItem')) uneqArmors++;
	}

	return uneqArmors < MAXARMORS;
}

simulated function UpdateHUDArmors()
{
	local GPArmorItem Armor;
	//local int i;

	ForEach InventoryActors( class'GPArmorItem', Armor )
	{
		if(Armor.isAttachedToGandhi && !Armor.IsA('GPTurbineItem')) Armor.UpdateHUD();
	}
}


function EnfundarPistola()
{
	//SetCurrentWeapon(None);
	GPPlayerPawn(Owner).Mesh.AttachComponentToSocket(GPPlayerPawn(Owner).LinkGunMesh, GPPlayerPawn(Owner).FundaPistolaSocketName);
	
}

function EnfundarRifle()
{
	GPPlayerPawn(Owner).Mesh.AttachComponentToSocket(GPPlayerPawn(Owner).ShockRifleMesh, GPPlayerPawn(Owner).FundaRifleSocketName);
}

function DesenfundarPistola()
{
	GPPlayerPawn(Owner).Mesh.DetachComponent(GPPlayerPawn(Owner).LinkGunMesh);
}

function DesenfundarRifle()
{
	//SetCurrentWeapon(waux);
	GPPlayerPawn(Owner).Mesh.DetachComponent(GPPlayerPawn(Owner).ShockRifleMesh);
	
}

function PlayDesenfundarPistola()
{
	GPPlayerPawn(Owner).TopHalfAnimSlot.PlayCustomAnim('test_Idle_desenfundar',2.0);
	// La quitamos del socket
	SetTimer(0.10f, false, NameOf(DesenfundarPistola));
	//GPPlayerPawn(Owner).Mesh.DetachComponent(GPPlayerPawn(Owner).LinkGunMesh);
}

function PlayDesenfundarRifle()
{
	GPPlayerPawn(Owner).TopHalfAnimSlot.PlayCustomAnim('test_Idle_desenfundar2',2.0);
}

function SetWeapon()
{
	SetCurrentWeapon(waux);
	//isChangingToWeapon = none;

	//if(wantsWeapon != none) {
	//	NextWeapon();
	//}
}

function SetAiming()
{
	GPPlayerPawn(Owner).IsAiming = true;
}

simulated function PrevWeapon()
{
	//Super.PrevWeapon();
	// Como solo tenemos 2 armas, nos da lo mismo
	NextWeapon();
}

simulated function NextWeapon()
{
	//Super.NextWeapon();

	local GPWeapon GPW;
	local GPPlayerPawn GPP;
	local Weapon	StartWeapon, CandidateWeapon, W;
	local bool		bBreakNext;

	//if(isChangingToWeapon == none) {
	//	wantsWeapon = none;
	//}
	//else {
	//	return; //SetWeapon con timer ya se encargará
	//}

	GPP = GPPlayerPawn(Instigator);
	StartWeapon = Instigator.Weapon;
	if( PendingWeapon != None )
	{
		StartWeapon = PendingWeapon;
	}

	ForEach InventoryActors( class'Weapon', W )
	{
		if( bBreakNext || (StartWeapon == None) )
		{
			CandidateWeapon = W;
			break;
		}
		if( W == StartWeapon )
		{
			bBreakNext = true;
		}
	}

	if( CandidateWeapon == None )
	{
		ForEach InventoryActors( class'Weapon', W )
		{
			CandidateWeapon = W;
			break;
		}
	}
	// If same weapon, do not change
	if( CandidateWeapon == Instigator.Weapon )
	{
		return;
	}

	GPW = GPWeapon(CandidateWeapon);
	
	if (GPW != None)
	{
		if (GPP.IsAiming)
		{
			SetTimer (1.5f, false, NameOf(SetAiming));
			GPP.IsAiming = false;
			GPP.IsCarryingWeapon = true;
		}

		//isChangingToWeapon = GPW;

		// El arma que llevábamos era el Rifle
		if (GPW.WeaponName == 'LinkGun')
		{	
			// No hace falta comprobar si lleva el arma, si no no tendría arma y GPW seria None
			
			// Enfundamos el rifle
			GPP.TopHalfAnimSlot.PlayCustomAnim('test_Idle_enfundar2',2.0);
			SetTimer(0.4f, false, NameOf(EnfundarRifle)); 
			
			// Desenfundamos la pistola
			SetTimer(0.60f, false, NameOf(PlayDesenfundarPistola));

			waux = GPWeapon(CandidateWeapon);
			SetTimer(0.2f, false, NameOf(SetWeapon));
			
		}
		// El arma que llevábamos era la Pistola
		else if (GPW.WeaponName == 'ShockRifle')
		{
			GPP.TopHalfAnimSlot.PlayCustomAnim('test_Idle_enfundar', 3);
			SetTimer(0.37f, false, NameOf(EnfundarPistola));
			SetTimer(0.6f, false, NameOf(PlayDesenfundarRifle));
			SetTimer(1.0f, false, NameOf(DesenfundarRifle));

			waux = GPWeapon(CandidateWeapon);
			SetTimer(0.2f, false, NameOf(SetWeapon));
			//SetCurrentWeapon(CandidateWeapon);
		}
	}
}

DefaultProperties
{
	PendingFire(0)=0
	PendingFire(1)=0

	firstArmor=true;
}
