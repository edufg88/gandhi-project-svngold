class GPPickupFactory_Ammo extends GPPickupFactory;

// Weapon archetypes to give ammo to
var(AmmoPickup) const array<GPWeapon> ValidWeaponArchetypes;
// How much ammo to add instantly when picking this up
var(AmmoPickup) const int AmmoToAdd;

/**
 * Returns true if the pick up can be picked up by a pawn
 *
 * @param			Other			The pawn trying to pick up this pick up
 * @return							Returns true if the pick up can be picked up by the pawn
 */
function bool CanPickup(Pawn Pawn)
{
	local int i;
	local GPWeapon GPWeapon;

	// Check that the pawn is valid
	if (Pawn == None || Pawn.Health <= 0 || Pawn.InvManager == None)
	{
		return false;
	}

	// Ensure that the pawn has the valid weapon archetype
	for (i = 0; i < ValidWeaponArchetypes.Length; ++i)
	{
		if (ValidWeaponArchetypes[i] != None)
		{
			ForEach Pawn.InvManager.InventoryActors(class'GPWeapon', GPWeapon)
			{
				if (GPWeapon.ObjectArchetype == ValidWeaponArchetypes[i] && GPWeapon.NeedsAmmo())
				{
					return true;
				}
			}
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
	local int i;
	local GPWeapon GPWeapon;

	// Check that the pawn is valid
	if (Pawn == None || Pawn.Health <= 0 || Pawn.InvManager == None)
	{
		return;
	}

	// Give ammo to the valid weapon archetypes
	for (i = 0; i < ValidWeaponArchetypes.Length; ++i)
	{
		if (ValidWeaponArchetypes[i] != None)
		{
			ForEach Pawn.InvManager.InventoryActors(class'GPWeapon', GPWeapon)
			{
				if (GPWeapon.ObjectArchetype == ValidWeaponArchetypes[i])
				{
					GPWeapon.StartAmmoRegeneration();
					GPWeapon.AddAmmo(AmmoToAdd);
				}

				break;
			}
		}
	}

	Super.GiveTo(Pawn);
}

defaultproperties
{
}