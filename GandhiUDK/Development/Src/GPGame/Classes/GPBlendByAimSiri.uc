class GPBlendByAimSiri extends UDKAnimBlendBase;

event TickAnim(float DeltaSeconds)
{
	local GPSiriPawn GPPawn;

	if ( SkelComponent.Owner != none )
	{
		GPPawn = GPSiriPawn(SkelComponent.Owner);
	}
	else
		GPPawn = none;
	
	if ( GPPawn != none)
	{
		if ( GPPawn.IsAiming )
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
	Children(1)=(Name="Aiming")
	bFixNumChildren=true
	
	bTickAnimInScript=true
}