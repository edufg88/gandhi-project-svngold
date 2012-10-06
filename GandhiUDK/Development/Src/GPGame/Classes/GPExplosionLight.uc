/**
 * GPExplosionLight
 *
 * Explosion light component which handles the light effects from weapons
 *
 */
class GPExplosionLight extends UDKExplosionLight
	HideCategories(UDKExplosionLight, PointLightComponent, LightMass, LightComponent, ImageReflection)
	EditInlineNew;

// Expose everything in this struct to the Editor
struct SLightValues
{
	var() float StartTime;
	var() float Radius;
	var() float Brightness;
	var() color LightColor;
};

// Light properties at each time shift
var(ExplosionLight) array<SLightValues> LightTimeShifts;

/**
 * Called when the light component should initialize itself
 *
 */
function Initialize()
{
	local LightValues LV;
	local int i;

	// Copy the LightTimeShift array to the TimeShift array
	if (LightTimeShifts.Length > 0)
	{
		for (i = 0; i < LightTimeShifts.Length; ++i)
		{
			LV.StartTime = LightTimeShifts[i].StartTime;
			LV.Radius = LightTimeShifts[i].Radius;
			LV.Brightness = LightTimeShifts[i].Brightness;
			LV.LightColor = LightTimeShifts[i].LightColor;

			TimeShift.Additem(LV);
		}
	}
}

defaultproperties
{
}
