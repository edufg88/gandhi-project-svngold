class GPDroppedItemsGenerator extends Actor;

// Posible items to be dropped
var (Item) GPChestArmorItem ChestArmorItem;
var (Item) GPLForeArmArmorItem LForeArmArmorItem;
var (Item) GPLUpperArmArmorItem LUpperArmArmorItem;
var (Item) GPRForeArmArmorItem RForeArmArmorItem;
var (Item) GPRUpperArmArmorItem RUpperArmArmorItem;
var (Item) GPLThighArmorItem LThighArmorItem;
var (Item) GPLCalfArmorItem LCalfArmorItem;
var (Item) GPRThighArmorItem RThighArmorItem;
var (Item) GPRCalfArmorItem RCalfArmorItem;
var (Item) GPTurbineItem TurbineItem;
var (Item) GPEnergyItem EnergyItem;
var (Item) GPDoorKey DoorKey;

function DropItem(class<actor> ItemClass, vector loc)
{
	local GPInventory gpi;
	local vector speed;

	speed.X = 20;
	speed.Y = 20;
	speed.Z = 20;

	gpi=GPInventory(Spawn(ItemClass));
	gpi.DropFrom(loc, speed);
}

/** ARROJA UN ÍTEM ALEATORIO
 * 0 : nada 
 * 1 : chest 
 * 2 : left upper arm
 * 3 : left lower arm
 * 4 : right upper arm
 * 5 : right lower arm
 * 6 : left upper leg
 * 7 : left lower leg
 * 8 : right upper leg
 * 9 : right lower leg
 * 10 : turbine
 * 11 : door key
 * */
simulated function DropRandomItem(vector loc)
{
	local vector speed;
	local int dice; 

	speed.X = 0;
	speed.Y = 0;
	speed.Z = 0;
	loc.z += 50;
	//dice = 11;// Rand(10); // dice = Rand(10);
	dice = Rand(11);

	switch (dice)
	{
		case 0:
			EnergyItem=Spawn(Class'GPEnergyItem');
			EnergyItem.DropFrom(loc, speed);
			break;
		// PIEZAS DE ARMADURA
		case 1:
			ChestArmorItem=Spawn(Class'GPChestArmorItem');
			ChestArmorItem.DropFrom(loc, speed);
			break;
		case 2:
			LUpperArmArmorItem=Spawn(Class'GPLUpperArmArmorItem');
			LUpperArmArmorItem.DropFrom(loc , speed);
			break;
		case 3:
			LForeArmArmorItem=Spawn(Class'GPLForeArmArmorItem');
			LForeArmArmorItem.DropFrom(loc, speed);
			break;
		case 4:
			RUpperArmArmorItem=Spawn(Class'GPRUpperArmArmorItem');
			RUpperArmArmorItem.DropFrom(loc, speed);
			break;
		case 5:
			RForeArmArmorItem=Spawn(Class'GPRForeArmArmorItem');
			RForeArmArmorItem.DropFrom(loc, speed);
			break;
		case 6:
			LThighArmorItem=Spawn(Class'GPLThighArmorItem');
			LThighArmorItem.DropFrom(loc, speed);
			break;
		case 7:
			LCalfArmorItem=Spawn(Class'GPLCalfArmorItem');
			LCalfArmorItem.DropFrom(loc, speed);
			break;
		case 8:
			RThighArmorItem=Spawn(Class'GPRThighArmorItem');
			RThighArmorItem.DropFrom(loc, speed);
			break;
		case 9:
			RCalfArmorItem=Spawn(Class'GPRCalfArmorItem');
			RCalfArmorItem.DropFrom(loc, speed);
			break;
		case 10:
			TurbineItem=Spawn(Class'GPTurbineItem');
			TurbineItem.DropFrom(loc, speed);
			break;
		case 11:
			DoorKey=Spawn(Class'GPDoorKey');
			DoorKey.SetCode("prueba");
			DoorKey.DropFrom(loc, speed);
			break;
		// OTROS CONSUMIBLES
		default:
			break;
	}
}

DefaultProperties
{

}
