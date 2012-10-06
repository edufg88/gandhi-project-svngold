class GPClass extends Object
	HideCategories(Object);

// What weapons are available to this class
var(Class) const array<GPWeapon> WeaponArchetypes;
// What pawn class to use for this class
var(Class) const GPPlayerPawn PawnArchetype;
// Class portrait
var(Class) const Texture2D ClassPortrait;
// Movement speed for the class
var(Class) const float GroundSpeed;

defaultproperties
{
}