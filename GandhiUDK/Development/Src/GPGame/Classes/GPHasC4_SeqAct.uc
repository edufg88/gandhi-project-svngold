class GPHasC4_SeqAct extends SequenceAction;

//var() string TriggerCode;
//var() bool Locked;

//var bool finished;

event Activated()
{
	local GPInventoryManager GPInvMan;
	local GPC4 gpc;

	if (InputLinks[0].bHasImpulse) {
		GPInvMan = GPInventoryManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn.InvManager);
		ForEach GPInvMan.InventoryActors(class'GPC4', gpc)
		{
			ActivateOutputLink(0);
			return;
		}
		ActivateOutputLink(1);
	}
}

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
	ObjName="Has C4"
	ObjCategory="GPGame"
	
	bAutoActivateOutputLinks=false

	
	InputLinks(0)=(LinkDesc="In")
	//InputLinks(1)=(LinkDesc="Touched")
	
	OutputLinks.Empty
	OutputLinks[0]=(LinkDesc="Obtained")
	OutputLinks[1]=(LinkDesc="Missing")
	//OutputLinks[2]=(LinkDesc="Overwritten")


	VariableLinks.Empty
	//VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="TriggerCode",PropertyName=TriggerCode)
	//VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Locked",PropertyName=ShowTime)
	//VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="SmallFont",PropertyName=SmallFont)

}