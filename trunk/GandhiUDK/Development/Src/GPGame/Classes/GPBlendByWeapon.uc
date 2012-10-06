class GPBlendByWeapon extends UDKAnimBlendBase;

event TickAnim(float DeltaSeconds)
{
	local GPPlayerPawn GPPawn;
	
	if ( SkelComponent.Owner != none )
		GPPawn = GPPlayerPawn(SkelComponent.Owner);
	else
		GPPawn = none;
	
	if ( GPPawn != none )
	{
		if ( GPWeapon(GPPawn.Weapon).WeaponName == 'ShockRifle' )
		{
			if ( ActiveChildIndex != 1 )
			{
				SetActiveChild( 1, 0.1 );
			}
		}
		else if ( GPWeapon(GPPawn.Weapon).WeaponName == 'LinkGun' )
		{
			if ( ActiveChildIndex != 0 )
			{
				SetActiveChild( 0, 0.1 );
			}
		}
	}
}	

defaultproperties
{
	Children(0)=(Name="LinkGun")
	Children(1)=(Name="ShockRifle")
	bFixNumChildren=true
	
	bTickAnimInScript=true
}