class GPDoorKey_SeqAct extends SequenceAction;

var() string TriggerCode;
var() bool showText;

//var bool finished;

event Activated()
{
	local GPInventoryManager GPInvMan;
	local GPDoorKey GPKey;
	local bool locked;

	//local WTKGameStatusManager WGSM;
	//local SeqVar_ConversationBox SVCB;
	//SVCB=SeqVar_ConversationBox(VariableLinks[0].LinkedVariables[0]);
	//ConvBox=SVCB.ConvBox;
	
	//foreach GetWorldInfo().AllActors(class'WTKGameStatusManager',WGSM){
	//	WGSM.LatentActions.AddItem(self);
	//	WGSM.OnShowConversationBox(self);
	//}

	if (InputLinks[0].bHasImpulse) {
		//GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).showText(Text, ShowTime, true);
		//class'GPHUD'.static.showHUDText(Text, ShowTime);
		if (TriggerCode != " ")
		{
			locked = true;
			GPInvMan = GPInventoryManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn.InvManager);
			ForEach GPInvMan.InventoryActors(class'GPDoorKey', GPKey)
			{
				// Si tenemos en el inventario alguna llave que abra la puerta podremos abrirla
				if (GPKey.code == TriggerCode)
				{
					// Aquí podemos meter un mensaje diciendo (La puerta está cerrada...Quieres usar la llave tal?...)
					//Locked = false;
					//GPKey.keyUsed();
					GPKey.Used = true;
					TriggerCode = " ";
					locked = false;
					if(showText) class'GPHUD'.static.showHUDText("You unlocked the door", 3000, false, true);
					ActivateOutputLink(0);
				}
			}
			if(locked) ActivateOutputLink(1);
		}
		else
		{
			ActivateOutputLink(0);
		}
	}
	if (InputLinks[1].bHasImpulse) {
		//GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).endText();
		//class'GPHUD'.static.endHUDText();
		//NotifyTextEnded();
		if (TriggerCode == " ") ActivateOutputLink(0);
		else ActivateOutputLink(1);
	}

	//if(ShowTime == -1) finished = true;
}

//event bool Update(float DeltaTime)
//{
//	return !finished;
//}

//function NotifyTextEnded() 
//{
//	ActivateOutputLink(1);
//	finished = true;
//}

//function NotifyOverwrite()
//{
//	ActivateOutputLink(2);
//	finished = true;
//}

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 10;
}

defaultproperties
{
	//ShowTime=-1;
	//Text="Subtitle";
	//SmallFont=false;
	TriggerCode=" ";
	showText=true;
	//Locked=false;

	//finished=false;

	ObjName="Door Key"
	ObjCategory="GPGame"
	
	bAutoActivateOutputLinks=false

	
	InputLinks(0)=(LinkDesc="Used")
	InputLinks(1)=(LinkDesc="Touched")
	
	OutputLinks.Empty
	OutputLinks[0]=(LinkDesc="Unlocked")
	OutputLinks[1]=(LinkDesc="Locked")
	//OutputLinks[2]=(LinkDesc="Overwritten")


	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="TriggerCode",PropertyName=TriggerCode)
	//VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Locked",PropertyName=ShowTime)
	//VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="SmallFont",PropertyName=SmallFont)

}