class GPPostProcessVolume extends PostProcessVolume;

// WARNING conflicts previous declaration
//var (GPWaterVolume) bool bEnabled;
var (GPVolume) int type;
var (GPVolume) const int typeWaterPP;
var (GPVolume) const int typeLightsPP;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetActive(bEnabled);
}

function SetActive (bool Check)
{
	local PostProcessSettings pps;
	
	pps.bEnableBloom = Check;
	pps.bEnableDOF = Check;
	pps.bEnableMotionBlur = Check;
	pps.bEnableSceneEffect = Check;
	
	Settings = pps;
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

DefaultProperties
{
	bEnabled=false;
}

