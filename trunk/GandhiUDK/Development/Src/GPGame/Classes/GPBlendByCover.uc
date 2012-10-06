/* Hace blending entre las coberturas con el escudo del droide */

class GPBlendByCover extends  UDKAnimBlendBase;

event TickAnim(float DeltaSeconds)
{
	local GPEnemyDroidPawnShield GPPawn;
	
	if ( SkelComponent.Owner != none )
		GPPawn = GPEnemyDroidPawnShield(SkelComponent.Owner);
	else
		GPPawn = none;
	
	if ( GPPawn != none )
	{
		if ( GPPawn.bIsCovering )
		{
			if ( ActiveChildIndex != 1 )
			{
				SetActiveChild( 1, 0.1 );
			}
		}
		else if ( ActiveChildIndex != 0 )
		{
			SetActiveChild( 0, 0.1 );
		}
	}
}	


defaultproperties
{
	Children(0)=(Name="Not Covering")
	Children(1)=(Name="Covering")
	bFixNumChildren=true
	
	bTickAnimInScript=true
}