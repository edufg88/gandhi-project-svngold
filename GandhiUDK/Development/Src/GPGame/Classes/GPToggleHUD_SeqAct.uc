class GPToggleHUD_SeqAct extends SeqAct_Latent;

event Activated()
{
	
	//local WTKGameStatusManager WGSM;
	//local SeqVar_ConversationBox SVCB;
	//SVCB=SeqVar_ConversationBox(VariableLinks[0].LinkedVariables[0]);
	//ConvBox=SVCB.ConvBox;
	
	//foreach GetWorldInfo().AllActors(class'WTKGameStatusManager',WGSM){
	//	WGSM.LatentActions.AddItem(self);
	//	WGSM.OnShowConversationBox(self);
	//}

	if (InputLinks[0].bHasImpulse) {
		GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).toggleGPHUD(true);
		//class'GPHUD'.static.showHUDText(Text, ShowTime);
		ActivateOutputLink(0);
	}
	if (InputLinks[1].bHasImpulse) {
		GPHUD(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().myHUD).toggleGPHUD(false);
		//class'GPHUD'.static.showHUDText(Text, ShowTime);
		ActivateOutputLink(0);
	}
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
	return Super.GetObjClassVersion() + 1;
}

defaultproperties
{
	//ShowTime=-1;
	//Text="Subtitle";
	//SmallFont=false;

	//finished=false;

	ObjName="Toggle HUD"
	ObjCategory="GPGame"
	
	bAutoActivateOutputLinks=true

	
	InputLinks(0)=(LinkDesc="Show")
	InputLinks(1)=(LinkDesc="Hide")
	
	OutputLinks.Empty
	OutputLinks[0]=(LinkDesc="Out")
	//OutputLinks[1]=(LinkDesc="TimeOut")
	//OutputLinks[2]=(LinkDesc="Overwritten")


	VariableLinks.Empty
	//VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="Text",PropertyName=Text)
	//VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="ShowTime",PropertyName=ShowTime)
	//VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="SmallFont",PropertyName=SmallFont)

}