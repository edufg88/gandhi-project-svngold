class GPPlayerReplicationInfo extends PlayerReplicationInfo;

// What class the player is
var ProtectedWrite GPClass ClassArchetype;
var GPInventoryManager PawnInventory;
var Name LastWeapon;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
}

defaultproperties
{
	ClassArchetype = GPClass'GP_Archetypes.Pawns.GandhiClass'
}