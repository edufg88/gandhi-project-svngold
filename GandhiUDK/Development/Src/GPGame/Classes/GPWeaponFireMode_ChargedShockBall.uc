class GPWeaponFireMode_ChargedShockBall extends GPWeaponFireMode_Projectile;

/**
 * Stub to allow subclasses to modify the projectile before it is initialized
 *
 * @param		Projectile		Projectile to modify
 */
protected function ModifyProjectile(GPProjectile Projectile)
{	
	if (Projectile != None)
	{
		// Append to the damage boost
		Projectile.DamageBoost += ContinuousFiringTime;
	}
}

defaultproperties
{
	FireOnRelease=true
}