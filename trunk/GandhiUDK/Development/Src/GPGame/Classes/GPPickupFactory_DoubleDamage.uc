class GPPickupFactory_DoubleDamage extends GPPickupFactory;

var(DoubleDamage) const float DoubleDamageTime;

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
		GPPlayerPawn.AmplifyDamage(DoubleDamageTime);
	}

	Super.GiveTo(Pawn);
}

defaultproperties
{
	DoubleDamageTime=10.f
}