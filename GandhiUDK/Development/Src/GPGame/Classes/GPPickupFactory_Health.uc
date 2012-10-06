class GPPickupFactory_Health extends GPPickupFactory;

// How much health to give to a human player
var(HealthPickup) const int HealthToGiveHuman;

/**
 * Returns true if the pick up can be picked up by a pawn
 *
 * @param			Other			The pawn trying to pick up this pick up
 * @return							Returns true if the pick up can be picked up by the pawn
 */
function bool CanPickup(Pawn Pawn)
{
	local GPPlayerPawn GPPlayerPawn;

	GPPlayerPawn = GPPlayerPawn(Pawn);
	if (GPPlayerPawn != None)
	{
		if (GPPlayerPawn.Health < GPPlayerPawn.HealthMax)
		{
			return true;
		}
	}

	return false;
}

/** 
 * Give pickup to player 
 *
 * @param		Pawn		Pawn to give the pick up to
 */
function GiveTo(Pawn Pawn)
{	
	local GPPlayerPawn GPPlayerPawn;
	GPPlayerPawn = GPPlayerPawn(Pawn);

	if (GPPlayerPawn != None)
	{
		GPPlayerPawn.HealDamage(HealthToGiveHuman, None, None);
	}

	Super.GiveTo(Pawn);
}

defaultproperties
{
	HealthToGiveHuman=50
}