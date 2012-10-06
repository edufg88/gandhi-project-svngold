class GPHUDGfx extends GFxMoviePlayer;

//var GFxObject hudLife;
//var GFxObject hudArmor;

var GPShowText_SeqAct showSeq;

//unoverwrittable info going on
var bool unoverGoing;

function Init(optional LocalPlayer LocalPlayer)
{
	super.Init(LocalPlayer);

	Start();
	Advance(0);

	//hudLife = GetVariableObject("root.hudIn.lifeGreen");
	//hudLife = GetVariableObject("root.hudCircle");
	//hudArmor = GetVariableObject("root.hudOut.armorBlue");
	updateWeapon(4);
}

function updateHealth(float hRatio)
{
	//hudLife.SetFloat("alpha", hRatio*2.0);
	//hudArmor.SetFloat("alpha", (hRatio-0.5)*2.0);

	//hudLife.SetFloat("alpha", hRatio);

	ActionScriptVoid("_root.hudCircle.setVida");

}

function updateAmmo(int ammo, int maxAmmo) 
{
	ActionScriptVoid("_root.infoAmmo.updateAmmo");
}

function updateWeapon(int weap) 
{
	ActionScriptVoid("_root.infoWeap.updateWeapon");
}

function UpdateArmor(int ArmorCode, float armorLife)
{
	ActionScriptVoid("_root.monigote.updateArmor");
}

function ResetMiniGandhi()
{
	ActionScriptVoid("_root.monigote.reset");
}

function ToggleHUD(bool show) 
{
	ActionScriptVoid("_root.toggleHUD");
}

function SiriMenu(bool show) 
{
	ActionScriptVoid("_root.showSiriCtrl");
}

//function startText(string text)
//{
//	ActionScriptVoid("_root.infoText.startText");
//}

function endText(optional bool isSub = false)
{
	if(isSub) endTextSubs();
	else endTextInfo();
}

function endTextInfo()
{
	ActionScriptVoid("_root.infoText.endText");
}

function endTextSubs()
{
	ActionScriptVoid("_root.infoSubs.endText");
}

function sendText(string text, optional float ms = -1, optional bool isSub = false)
{
	ActionScriptVoid("_root.infoText.showText");
}

function sendSub(string text, optional float ms = -1, optional bool isSub = false)
{
	ActionScriptVoid("_root.infoSubs.showText");
}

function showText(string text, optional float ms = -1, optional bool isSub = false, optional GPShowText_SeqAct gpst = none)
{
	if(showSeq != none) showSeq.NotifyOverwrite();
	showSeq = gpst;
	//class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientMessage(""$gpst);
	if(isSub) sendSub(text, ms, isSub);
	else sendText(text, ms, isSub);
}

function textEndedEvent()
{
	//class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientMessage("Ended!");
	unoverGoing = false;
	if(showSeq != none) {
		showSeq.NotifyTextEnded();
		showSeq = none;
	}
}

DefaultProperties
{
	unoverGoing=false;

	bDisplayWithHudOff=false
	TimingMode=TM_Game
	MovieInfo=SwfMovie'GandhiMenu.GandhiHUD'
	bPauseGameWhileActive=false 
}
