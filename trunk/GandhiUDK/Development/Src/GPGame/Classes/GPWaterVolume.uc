class GPWaterVolume extends UTDynamicWaterVolume;

var (GPWaterVolume) bool bEnabled;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCollision(bEnabled);
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if (bEnabled)
	{
		Super.Touch(Other, OtherComp, HitLocation, HitNormal);
	}
	else
	{
		return;
	}
}

//event untouch(Actor Other)
//{
	
//}

DefaultProperties
{
	bEnabled=true;
}
