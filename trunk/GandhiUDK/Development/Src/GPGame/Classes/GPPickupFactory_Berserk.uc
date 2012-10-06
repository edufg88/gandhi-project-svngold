class GPPickupFactory_Berserk extends GPPickupFactory;

var(Berserk) const float BerserkTime;

/** 
 * Give pickup to player 
 *
 * @param		Pawn		Pawn to give the pick up to
 */
function GiveTo(Pawn Pawn)
{	
	local GPPlayerPawn GPPlayerPawn;

	// Tell the pawn to go into berserk mode
	GPPlayerPawn = GPPlayerPawn(Pawn);
	if (GPPlayerPawn != None)
	{
		GPPlayerPawn.EnterBerserkMode(BerserkTime);
	}

	Super.GiveTo(Pawn);
}

defaultproperties
{
	BerserkTime=3.f
}