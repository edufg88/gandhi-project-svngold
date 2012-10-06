class GPHUD extends HUD;

var() int ReticuleWidth;

//var GPDescriptionPopupPlayer PopupPlayer;

var GPHUDGfx hudGFx;
var GPMenuGfx menuGFx;
var GPInventoryMenuGFx invenGFx;

var bool siriMenuShowing;

var array<string> logInfos;
var array<string> logDialogs;

// Widget position X
var int WidgetPositionX;

// HUD Properties
var() const GPHUDProperties HUDProperties;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	hudGfx = new () class'GPHUDGfx';
	hudGfx.SetTimingMode(TM_Game);
	hudGfx.Init(class'Engine'.static.GetEngine().GamePlayers[hudGfx.LocalPlayerOwnerIndex]);

	hudGFx.updateWeapon(4);
}

exec function QuitGame()
{
	ConsoleCommand("Quit");
}

exec function ShowMenu()
{
	if(menuGFx == none) {
		menuGfx = new () class'GPMenuGfx';
		menuGfx.Init(class'Engine'.static.GetEngine().GamePlayers[hudGfx.LocalPlayerOwnerIndex]);
	}
	else {
		menuGfx.Close(true);
		menuGfx = none;
	}
}

function OpenInventory() 
{
	local int i;
	local array<GPPuzzlePiece> puzs;

	//PlayerOwner.ConsoleCommand("CE invopen");
	GPPlayerPawn(PlayerOwner.Pawn).IsInMenu = true;
	GPPlayerPawn(PlayerOwner.Pawn).bJumpCapable = false;
	PlayerOwner.IgnoreMoveInput(true);
	PlayerOwner.IgnoreLookInput(true);
	GPPlayerPawn(PlayerOwner.Pawn).bNoWeaponFiring = true;

	//GPPlayerPawn(PlayerOwner.Pawn).bCanJump = false;
	//PlayerOwner.ClientPrepareMapChange(name("prova2"), false, true);
	//PlayerOwner.ClientCommitMapChange();
	//PlayerOwner.IgnoreMoveInput(true);
	//PlayerOwner.IgnoreLookInput(true);
	//hey = Spawn(class'GPPlayerPawn',none,,,, GPPlayerPawn(WorldInfo.GetALocalPlayerController().Pawn));
	invenGFx = new () class'GPInventoryMenuGFx';
	invenGFx.Init(class'Engine'.static.GetEngine().GamePlayers[hudGfx.LocalPlayerOwnerIndex]);
	invenGFx.setHealth(float(GPPlayerPawn(PlayerOwner.Pawn).Health)/GPPlayerPawn(PlayerOwner.Pawn).HealthMax);

	if(GPGame(class'WorldInfo'.static.GetWorldInfo().Game).puzzleTime) {
		puzs = GPGame(class'WorldInfo'.static.GetWorldInfo().Game).puzs;
		for(i = 0; i < puzs.Length; i++)
		{
			invenGFx.puzs.AddItem(puzs[i]);
		}
	}
	//if(toMap) invenGFx.gotoMap();
	//invenGFx.avoidDebugKeys();
	//PlayerOwner.SetPause(true);
}

function CloseInventory()
{
	//PlayerOwner.ConsoleCommand("CE invclose");
	GPPlayerPawn(PlayerOwner.Pawn).IsInMenu = false;
	GPPlayerPawn(PlayerOwner.Pawn).bJumpCapable = true;
	PlayerOwner.IgnoreMoveInput(false);
	PlayerOwner.IgnoreLookInput(false);
	GPPlayerPawn(PlayerOwner.Pawn).bNoWeaponFiring = false;

	//PlayerOwner.IgnoreMoveInput(false);
	//PlayerOwner.IgnoreLookInput(false);
	invenGFx.Close(true);
	invenGFx = none;
	//PlayerOwner.SetPause(false);
}

exec function ShowInventory()
{
	if(invenGFx == none) {
		OpenInventory();
	}
	else if(invenGFx.IsInInventory()) {
		CloseInventory();
	}
	else {
		invenGFx.gotoInv();
	}
}

exec function ShowMap()
{
	if(invenGFx == none) {
		OpenInventory();
		invenGFx.gotoMap();
	}
	else if(invenGFx.IsInMap()) {
		CloseInventory();
	}
	else {
		invenGFx.gotoMap();
	}
}

exec function ShowLog()
{
	if(invenGFx == none) {
		OpenInventory();
		invenGFx.gotoLog();
	}
	else if(invenGFx.IsInLog()) {
		CloseInventory();
	}
	else {
		invenGFx.gotoLog();
	}
}

exec function ShowOptions()
{
	//equivalente a ESC/Start, por lo tanto diferente
	if(invenGFx == none) {
		OpenInventory();
		invenGFx.gotoOptions();
	}
	//else if(invenGFx.IsInOptions()) {
		//CloseInventory();
	//}
	else {
		//invenGFx.gotoOptions();
		CloseInventory();
	}
}

function rightClick() 
{
	invenGFx.rightClick();
}

exec function ShowSiriMenu() 
{
	if(!GPPlayerController(PlayerOwner).bCanControlSiri) return;
	hudGFx.SiriMenu(true);
	siriMenuShowing = true;
	PlayerOwner.IgnoreMoveInput(true);
}

exec function HideSiriMenu() 
{
	if(!GPPlayerController(PlayerOwner).bCanControlSiri) return;
	hudGFx.SiriMenu(false);
	siriMenuShowing = false;
	PlayerOwner.IgnoreMoveInput(false);
}

/**
 * Show text on HUD. Optional: ms = -1 --> infinite time (default) // 0 --> auto time // int > 0 --> time in ms
 *
 * @param		text				Text to be shown.
 * @param		ms					Optional: ms = -1 --> infinite time (default) // 0 --> auto time // int > 0 --> time in ms
 */
static function showHUDText(string text, optional float ms = -1, optional bool isSub = false, optional bool unOverwrittable = false) 
{
	GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).showText(text, ms, isSub, none, unOverwrittable);
}

static function endHUDText(optional bool isSub = false)
{
	GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).endText(isSub);
}

static function setHUDWeapon(name weapName)
{
	local int i;
	if(weapName == 'LinkGun') i = 1;
	else if(weapName == 'ShockRifle') i = 2;
	else i = 4; //none
	GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).hudGFx.updateWeapon(i);
}

static function PuzzlePicked(GPPuzzlePiece gpz)
{
	//GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).puzs.RemoveItem(gpz);
	GPGame(class'WorldInfo'.static.GetWorldInfo().Game).puzs.RemoveItem(gpz);
}

static function PuzzleSpawned(GPPuzzlePiece gpz)
{
	//local GPGame gpg;
	//local GPHUD gph;
	//gph = GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD); //.puzs.AddItem(gpz);
	GPGame(class'WorldInfo'.static.GetWorldInfo().Game).puzs.AddItem(gpz);
	//gpg.WarnEnemies();
}

/**
 * Show text on HUD. Optional: ms = -1 --> infinite time (default) // 0 --> auto time // int > 0 --> time in ms
 *
 * @param		text				Text to be shown.
 * @param		ms					Optional: ms = -1 --> infinite time (default) // 0 --> auto time // int > 0 --> time in ms
 * @param		gpst				Optional: GPShowText kismet module to inform when timeout or if cancelled
 */
function showText(string text, optional float ms = -1, optional bool isSub = false, optional GPShowText_SeqAct gpst = none, optional bool unOverwrittable = false)
{
	if(!isSub && hudGFx.unoverGoing) return;
	hudGFx.unoverGoing = unOverwrittable;

	hudGFx.showText(text, ms, isSub, gpst);
	if(isSub) logDialogs.AddItem(text);
	else logInfos.AddItem(text);
}

function endText(optional bool isSub = false)
{
	if(!isSub && hudGFx.unoverGoing) return;
	hudGFx.endText(isSub);
}

function toggleGPHUD(bool show)
{
	GPPlayerPawn(PlayerOwner.Pawn).IsAiming = false;
	hudGFx.ToggleHUD(show);
}

function UpdateArmor(int ArmorCode, float armorLife)
{
	hudGFx.UpdateArmor(ArmorCode, armorLife);
	if(invenGFx != none) invenGFx.UpdateArmor(ArmorCode, armorLife);
}

function RefreshArmors()
{
	hudGFx.ResetMiniGandhi();
	if(invenGFx != none) invenGFx.ResetMiniGandhi();
	GPInventoryManager(PlayerOwner.Pawn.InvManager).UpdateHUDArmors();
}

function DrawGameHUD()
{
	//local int PosX, PosY, NbCases, i;
	local GPPlayerController Ctrl;
	Ctrl = GPPlayerController(PlayerOwner);

	// Si somos Gandhi, dibujamos una cosa...
	if (Ctrl.bWhoAmI == -1 || Ctrl.bWhoAmI == 0) 
	{
		if(PlayerOwner.Pawn.Weapon == none) hudGFx.updateWeapon(4);
		else hudGFx.updateAmmo(GPWeapon(PlayerOwner.Pawn.Weapon).AmmoCount, GPWeapon(PlayerOwner.Pawn.Weapon).MaxAmmoCount);
		RefreshArmors();

		if(PlayerOwner.IsDead())
			hudGFx.updateHealth(0);
		else 
			hudGFx.updateHealth(float(PlayerOwner.Pawn.Health)/PlayerOwner.Pawn.HealthMax);
	}
	// Si somos Siri otra...
	else if (Ctrl.bWhoAmI == 1)
	{
		//PosX = 30;
		//PosY = 30;
		//NbCases = 10 * Ctrl.Pawn.Health / 100;
		//i = 0;

		//while(i < NbCases && i < 10)
		//{
		//	Canvas.SetPos(PosX, PosY);
		//	Canvas.SetDrawColor(10,218,10,200); //R,G,B
		//	Canvas.DrawRect(8,12);

		//	PosX += 10;
		//	i++;
		//}

		//while(i < 10)
		//{
		//	Canvas.SetPos(PosX, PosY);
		//	Canvas.SetDrawColor(255, 255, 255, 80);
		//	Canvas.DrawRect(8, 12);

		//	PosX += 10;
		//	i++;
		//}

		//Canvas.SetPos(PosX + 5, PosY);
		//Canvas.SetDrawColor(10, 218, 10, 200);
		//Canvas.Font = class'Engine'.static.GetSmallFont();
		//Canvas.DrawText("SIRI HEALTH");
	}


	//DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,1050,20,200,0,0);

	
	//local GPPlayerController pc;
	//local int AmmoCount;
	//local UTWeapon Weapon;
	
	//if(!PlayerOwner.IsDead())
	//{
	//	DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,1050,20,200,0,0);

	//	hudGFx.updateHealth(float(PlayerOwner.Pawn.Health)/PlayerOwner.Pawn.HealthMax);
		//TODO: Ammo!
		//Weapon = UTWeapon(PawnOwner.Weapon);
		//if ( Weapon != none )
		//{
		//	AmmoCount = Weapon.GetAmmoCount();
		//	DrawBar("Ammo", AmmoCount, Weapon.MaxAmmoCount,1050,300,80,180,240);
		//}



		//GPPlayerController specific handling
		//pc = GPPlayerController(PlayerOwner);
		
		//if(pc != none)
		//{
		//	//see if we need to show the description popup
		//	if(pc.InfoManager.ShowInfoPopupFlag && !PopupPlayer.PlayerVisible)
		//	{
		//		PopupPlayer.CallShowPopup(pc.InfoManager.CurrentInfoTitle, pc.InfoManager.CurrentInfoDescription);
		//	}
		//	else if(pc.Infomanager.NewInfo && PopupPlayer.PlayerVisible)
		//	{
		//		PopupPlayer.CallSetInfo(pc.InfoManager.CurrentInfoTitle, pc.InfoManager.CurrentInfoDescription);
		//	}
		//	else if(!pc.Infomanager.ShowInfoPopupFlag && PopupPlayer.PlayerVisible)
		//	{
		//		PopupPlayer.CallHidePopup();
		//	}
		//}
	//}
}

//test bar rendering
function DrawBar(string Title, float Value, float MaxValue, int X, int Y, int R, int G, int B)
{
	local int PosX, NbCases, i;

	PosX = X;
	NbCases = 10 * Value / MaxValue;
	i = 0;

	while(i < NbCases && i < 10)
	{
		Canvas.SetPos(PosX, Y);
		Canvas.SetDrawColor(R,G,B,200);
		Canvas.DrawRect(8,12);

		PosX += 10;
		i++;
	}

	while(i < 10)
	{
		Canvas.SetPos(PosX, Y);
		Canvas.SetDrawColor(255, 255, 255, 80);
		Canvas.DrawRect(8, 12);

		PosX += 10;
		i++;
	}

	Canvas.SetPos(PosX + 5, Y);
	Canvas.SetDrawColor(R, G, B, 200);
	Canvas.Font = class'Engine'.static.GetSmallFont();
	Canvas.DrawText(Title);
}


simulated event Destroyed()
{
	super.Destroyed();

	if(hudGfx != none)
	{
		hudGfx.Close(true);
		hudGfx = none;
	}
}

/**
 * Called everytime the HUD should render things onto the screen
 *
 */
event PostRender()
{
	local GPPlayerController Ctrl;
	local GPPlayerPawn GPPlayerPawn;
	local GPSiriPawn GPSiriPawn;

	Ctrl = GPPlayerController(PlayerOwner);

	Super.PostRender();

	// Render the cross hair for the player
	DrawGameHUD();

	// Render the pawns health
	//RenderPawnStats();

	// Render the weapon stats
	//RenderWeaponStats();
	// Render armor stats
	//RenderArmorStats();
	// Render inventory items
	//RenderInventory();


	if (Ctrl.Pawn != None)
	{
		if (Ctrl.bWhoAmI == -1 || Ctrl.bWhoAmI == 0) // Soy Gandhi
		{
			GPPlayerPawn = GPPlayerPawn(Ctrl.Pawn);

			if (GPPlayerPawn.IsAiming && !GPPLayerPawn.IsNaked)
			{
				RenderCrosshair();
			}
		}
		else if (Ctrl.bWhoAmI == 1) // Soy Siri
		{   
			GPSiriPawn = GPSiriPawn(Ctrl.Pawn);
			
			if (GPSiriPawn.IsAiming)
			{
				RenderCrosshair();
			}
		}
	}
}

/**
 * Renders the crosshair. This just forwards the call to the pawn's weapon
 *
 * @network		Client
 */
function RenderCrosshair()
{
	local GPWeapon GPWeapon;
	local GPWeaponSiri GPWeaponSiri;

	// Abort if the player owner is none, player owner's pawn is none or the Canvas is none
	if (PlayerOwner == None || PlayerOwner.Pawn == None || Canvas == None)
	{
		return;
	}

	// Forwards the render crosshair call to the weapon
	// Es Siri
	if (PlayerOwner.Pawn.Weapon.IsA('GPWeaponSiri'))
	{
		GPWeaponSiri = GPWeaponSiri(PlayerOwner.Pawn.Weapon);
		if (GPWeaponSiri != None)
		{
			//GPWeaponSiri.RenderCrosshair(Self);
		}
	}
	else
	{
		GPWeapon = GPWeapon(PlayerOwner.Pawn.Weapon);
		if (GPWeapon != None)
		{
			GPWeapon.RenderCrosshair(Self);
		}
	}
}

function RenderWeaponStats()
{
	local GPWeapon GPWeapon;

	// Abort if there is no player owner, or pawn
	if (PlayerOwner == None || PlayerOwner.Pawn == None)
	{
		return;
	}

	// Ensure we have a valid weapon
	GPWeapon = GPWeapon(PlayerOwner.Pawn.Weapon);
	if (GPWeapon == None)
	{
		return;
	}

	// Render the stats
	GPWeapon.RenderStats(Self, WidgetPositionX);
}

function RenderArmorStats()
{
	local GPInventoryManager InvMgr;
	local array<GPArmorItem> ArmorList;
	local GPArmorItem Item;
	local int i;

	InvMgr = GPInventoryManager(PlayerOwner.Pawn.InvManager);
	InvMgr.GetArmorList(ArmorList);

	for(i=0; i < ArmorList.Length; i++)
	{
		Item = ArmorList[i];
		Item.RenderStats(self);
	}
}

function RenderInventory()
{
	local GPInventoryManager InvMgr;
	local GPInventory Inv;
	local int PosX, PosY;

	PosX = 750;
	PosY = 30;

	InvMgr = GPInventoryManager(PlayerOwner.Pawn.InvManager);
	Canvas.SetPos(PosX, PosY);
	Canvas.SetDrawColor(0, 250, 125, 200);
	Canvas.Font = class'Engine'.static.GetSmallFont();
	Canvas.DrawText("INVENTORY --------");
	Canvas.SetDrawColor(0, 250, 0, 200);
	ForEach InvMgr.InventoryActors(class'GPInventory', Inv)
	{
		Canvas.DrawText(Inv.GetName());
		PosY += 25;
	}
}

defaultproperties
{
	WidgetPositionX=100;
	HUDProperties=GPHUDProperties'GP_Archetypes.HUD.GPHUDProperties'

	siriMenuShowing=false;
}
