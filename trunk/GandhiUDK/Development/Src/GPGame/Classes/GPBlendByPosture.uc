class GPBlendByPosture extends UDKAnimBlendBase;

event TickAnim(float DeltaSeconds)
{
	local GPPlayerPawn GPPawn;
	
	if ( SkelComponent.Owner != none )
		GPPawn = GPPlayerPawn(SkelComponent.Owner);
	else
		GPPawn = none;
	
	if ( GPPawn != none )
	{
		if ( GPPawn.IsCrouched)
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
	Children(0)=(Name="Normal")
	Children(1)=(Name="Crouched")
	bFixNumChildren=true
	
	bTickAnimInScript=true
}