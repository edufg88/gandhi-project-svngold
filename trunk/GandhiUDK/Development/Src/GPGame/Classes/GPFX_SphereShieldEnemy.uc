class GPFX_SphereShieldEnemy extends GPFX_SphereShield;

var int shieldHealth;

var () MaterialInstanceConstant ShieldMICPresetLowEnergy;

simulated event Tick(float DeltaTime) {
	super.Tick(DeltaTime);
	SetLocation(Owner.Location);
}

simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	shieldHealth -= Damage;
	//if(shieldHealth <= 150) ShieldMIC.SetParent(ShieldMICPresetLowEnergy);
	if(shieldHealth <= 0) {
		GPEnemyDroidController(GPEnemyDroidPawn(Owner).Controller).ToggleShield();
		Destroy();
	}
}

simulated function bool StopsProjectile(Projectile P)
{
	if(P.IsPlayerOwned()) return false;
	
	return super.StopsProjectile(P);
}

DefaultProperties
{
	ShieldMICPreset = MaterialInstanceConstant'ShieldMaterial.MaterialInstances.M_EnemyShieldMaterial_INST'
	ShieldMICPresetLowEnergy = MaterialInstanceConstant'ShieldMaterial.MaterialInstances.M_ShieldMaterial_LowEnergy_INST'
	shieldHealth = 300;
}

