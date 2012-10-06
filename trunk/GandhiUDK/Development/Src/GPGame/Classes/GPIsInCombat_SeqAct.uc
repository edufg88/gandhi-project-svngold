class GPIsInCombat_SeqAct extends SequenceAction;

//var() string TriggerCode;
//var() bool Locked;

//var bool finished;

event Activated()
{
	//local GPInventoryManager GPInvMan;
	//local GPDoorKey GPKey;
	//local bool locked;

	//local WTKGameStatusManager WGSM;
	//local SeqVar_ConversationBox SVCB;
	//SVCB=SeqVar_ConversationBox(VariableLinks[0].LinkedVariables[0]);
	//ConvBox=SVCB.ConvBox;
	
	//foreach GetWorldInfo().AllActors(class'WTKGameStatusManager',WGSM){
	//	WGSM.LatentActions.AddItem(self);
	//	WGSM.OnShowConversationBox(self);
	//}

	if (InputLinks[0].bHasImpulse) {
		if (GPGame(GetWorldInfo().Game).PlayingTensionSound) ActivateOutputLink(0);
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
	return Super.GetObjClassVersion() + 1;
}

defaultproperties
{
	//ShowTime=-1;
	//Text="Subtitle";
	//SmallFont=false;
	//TriggerCode=" ";
	//Locked=false;

	//finished=false;

	ObjName="Is in combat"
	ObjCategory="GPGame"
	
	bAutoActivateOutputLinks=false

	
	InputLinks(0)=(LinkDesc="In")
	//InputLinks(1)=(LinkDesc="Wandering")
	
	OutputLinks.Empty
	OutputLinks[0]=(LinkDesc="Fighting")
	OutputLinks[1]=(LinkDesc="Wandering")
	//OutputLinks[2]=(LinkDesc="Overwritten")


	VariableLinks.Empty
	//VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="TriggerCode",PropertyName=TriggerCode)
	//VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Locked",PropertyName=ShowTime)
	//VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="SmallFont",PropertyName=SmallFont)

}
