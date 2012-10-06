/* Hace blending entre el enfundado y el desenfundado de las armas en Gandhi */

class GPBlendByHolster extends UDKAnimBlendBase;

event TickAnim(float DeltaSeconds)
{
	local GPPlayerPawn GPPawn;
	
	if ( SkelComponent.Owner != none )
		GPPawn = GPPlayerPawn(SkelComponent.Owner);
	else
		GPPawn = none;
	
	if ( GPPawn != none )
	{
		if ( GPPawn.IsCarryingWeapon )
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
	Children(0)=(Name="Not Carrying")
	Children(1)=(Name="Carrying")
	bFixNumChildren=true
	
	bTickAnimInScript=true
}