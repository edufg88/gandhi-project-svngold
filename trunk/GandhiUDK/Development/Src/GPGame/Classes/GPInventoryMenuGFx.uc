class GPInventoryMenuGFx extends GFxMoviePlayer;

//var TextureRenderTarget2D MyRenderTexture;
var Inventory inv;
var int actualTab; //0 = inv, 1 = map, 2 = esc
var GPWeapon newWeap;
var GPWeapon actualWeap;
var bool firstSend;
var array<GPPuzzlePiece> puzs;

function Init(optional LocalPlayer LocalPlayer)
{
	super.Init(LocalPlayer);

	Start();
	Advance(0);

	avoidDebugKeys();
	sendInventory();
	sendLogs();
}

function sendInventory() {
	local float life;
	local bool attached;
	local GPArmorItem gpai;
	local string invName;
	//local GPDoorKey key;

	inv = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn.InvManager.InventoryChain;
	
	while(inv != none) {
		gpai = GPArmorItem(inv);
		invName = string(inv.Name);
		if(gpai != none && !gpai.IsA('GPTurbineItem')) {
			life = float(gpai.ArmorPoints)/gpai.MaxArmorPoints;
			attached = gpai.isAttachedToGandhi;
		}
		else if(GPWeapon(inv) != none) {
			invName = string(GPWeapon(inv).WeaponName);
			life = 0;
			attached = GPWeapon(inv).activeWeap;
			if(attached && firstSend) {
				actualWeap = GPWeapon(inv);
				newWeap = actualWeap;
			}
		}
		else if(GPDoorKey(inv) != none) {
			//key = GPDoorKey(inv);
			if(GPDoorKey(inv).Used) {
				invName = "KeyUsed";
			}
			else invName = "Key"$GPDoorKey(inv).getNumCode();
		}
		else {
			life = 0;
			attached = false;
		}
		sendInvItem(invName, life, attached);
		inv = inv.Inventory;
	}
	firstSend = false;
	fillSlots();
}

function sendInvItem(string item, float vida, bool attached) {
	ActionScriptVoid("_root.menu.newItem");
}

function fillSlots() {
	ActionScriptVoid("_root.menu.fillSlots");
}

function sendLogs() 
{
	local string str;
	foreach GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).logInfos(str) {
		sendLogString(str, false);
	}
	foreach GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).logDialogs(str) {
		sendLogString(str, true);
	}
}

function sendLogString(string str, bool isDialog)
{
	ActionScriptVoid("_root.menu.addLog");
}

event OnClose() {
	local GPPlayerController gppc;
	if(newWeap != actualWeap) {
		gppc = GPPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());
		if(newWeap == none) gppc.ToggleHolster(); //enfundará
		else if(actualWeap == none) { //y por lo tanto newWeap != none
			gppc.PreviousWeapon = newWeap;
			gppc.ToggleHolster(); //desenfundará la correcta
		}
		else {
			//GPInventoryManager(gppc.Pawn.InvManager).wantsWeapon = newWeap;
			gppc.NextWeapon(); //arreglar para elegir arma
		}
	}

	super.OnClose();
}

function attWeap(int ind/*, bool equip*/) 
{
	local GPWeapon gpw;
	//local GPPlayerController gppc;

	setInv(ind);

	gpw = GPWeapon(inv);
	if(gpw == none) class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientMessage("ERROR ATTACHING WEAPON!");
	
	//class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn.InvManager.SetCurrentWeapon(gpw);

	//gppc = GPPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

	if(newWeap != none) newWeap.activeWeap = false;

	//si es la misma, queremos desequipar
	if(gpw == newWeap) {
		newWeap = none;
	}
	else {
		gpw.activeWeap = true;
		newWeap = gpw;
	}
	
}

function invTrash(int ind) 
{
	local GPArmorItem gpai;

	setInv(ind);

	gpai = GPArmorItem(inv);
	if(gpai == none) class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientMessage("ERROR ATTACHING ARMOR!");
	
	gpai.ToTrash();
}

function invEquip(int ind, bool equip) 
{
	local GPArmorItem gpai;

	setInv(ind);

	gpai = GPArmorItem(inv);
	if(gpai == none) class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientMessage("ERROR ATTACHING ARMOR!");
	
	if(equip) gpai.Equip();
	else gpai.Unequip();
}

function invRepair(int indKit, int indArmor) 
{
	local GPArmorItem gpai;
	local GPRepairKit gprk;

	setInv(indArmor);
	gpai = GPArmorItem(inv);

	setInv(indKit);
	gprk = GPRepairKit(inv);

	gprk.SetArmorToRepair(gpai);
	gprk.Use();
}

function invHeal(int indCell) 
{
	local GPPlayerPawn gpawn;
	gpawn = GPPlayerPawn(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn);

	invUse(indCell);
	setHealth(float(gpawn.Health)/gpawn.HealthMax);
}

function setInv(int ind) 
{
	local int i;

	inv = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn.InvManager.InventoryChain;
	
	for(i = 0; i < ind; i++) inv = inv.Inventory;

	if(inv == none) class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientMessage("ERROR IN INVENTORY INDEX!");
}

function invUse(int ind) 
{
	local GPInventoryItem gpii;

	setInv(ind);
	
	gpii = GPInventoryItem(inv);
	
	gpii.Use();
}

//function SetRenderTexture()
//{
//	SetExternalTexture("MyRenderTarget", MyRenderTexture);
//}

function updGandhiCoord() 
{
	local Vector coord;
	local int i;
	local GPPlayerPawn paw;
	paw = GPPlayerPawn(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn);
	coord = paw.Location;
	sendGandhiCoord(coord.X, coord.Y, coord.Z, paw.Rotation.Yaw/180);

	for(i = 0; i < puzs.Length; i++)
	{
		coord = puzs[i].Location;
		sendPuzCoord(coord.X, coord.Y, coord.Z);
	}
}

function sendGandhiCoord(float x, float y, float z, int w) 
{
	ActionScriptVoid("_root.menu.coordGandhi");
}

function sendPuzCoord(float x, float y, float z) {
	ActionScriptVoid("_root.menu.coordPuzzle");
}

function gotoMap() 
{
	ActionScriptVoid("_root.menu.showMap");
}

function gotoInv() 
{
	ActionScriptVoid("_root.menu.showInv");
}

function gotoLog() 
{
	ActionScriptVoid("_root.menu.showLog");
}

function gotoOptions() 
{
	ActionScriptVoid("_root.menu.showEsc");
}

function avoidDebugKeys() 
{
	ActionScriptVoid("_root.menu.stopDebug");
}

function updActualTab(int tab) 
{
	actualTab = tab;
	//class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().SetPause(true);
}

function bool IsInInventory() 
{
	return actualTab == 0;
}

function bool IsInMap() 
{
	return actualTab == 1;
}

function bool IsInLog() 
{
	return actualTab == 2;
}

function bool IsInOptions() 
{
	return actualTab == 3;
}

function rightClick() {
	ActionScriptVoid("_root.menu.rightClick");
}

function setHealth(float hp) {
	ActionScriptVoid("_root.hudCircle.setVida");
}

function UpdateArmor(int ArmorCode, float armorLife)
{
	ActionScriptVoid("_root.monigote.updateArmor");
}

function ResetMiniGandhi()
{
	ActionScriptVoid("_root.monigote.reset");
}

//function hideMenu() 
//{
//	Close();
//}

function exitGame() 
{
	ConsoleCommand("Quit");
}

DefaultProperties
{
	bDisplayWithHudOff=true
	TimingMode=TM_Real
	MovieInfo=SwfMovie'GandhiMenu.GandhiInventory'
	bPauseGameWhileActive=true

	//MyRenderTexture=TextureRenderTarget2D'GandhiMenu.GandhiInventoryRender'

	firstSend=true;
}
