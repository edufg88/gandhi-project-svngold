class GPHUDProperties extends Object
	HideCategories(Object);

// Cursor texture
var(Cursor) const Texture2D CursorTexture;
// Cursor width
var(Cursor) const int CursorWidth;
// Cursor Height
var(Cursor) const int CursorHeight;
// Cursor color
var(Cursor) const Color CursorColor;

// Active sound
var(Sounds) const SoundCue ActiveSoundCue;
// Select sound
var(Sounds) const SoundCue SelectSoundCue;

// Task font
var(Tasks) const Font TaskFont;
// Task texture
var(Tasks) const Texture2D TaskTexture;
// Task UV coordinates
var(Tasks, UV) const float TaskU<DisplayName=U>;
var(Tasks, UV) const float TaskV<DisplayName=V>;
var(Tasks, UV) const float TaskUL<DisplayName=UL>;
var(Tasks, UV) const float TaskVL<DisplayName=VL>;

// Berserk font
var(Berserk) const Font BerserkFont;
// Berserk icon
var(Berserk) const Texture2D BerserkTexture;
// Berserk UV coordinates
var(Berserk, UV) const float BerserkU<DisplayName=U>;
var(Berserk, UV) const float BerserkV<DisplayName=V>;
var(Berserk, UV) const float BerserkUL<DisplayName=UL>;
var(Berserk, UV) const float BerserkVL<DisplayName=VL>;

// Double damage font
var(DoubleDamage) const Font DoubleDamageFont;
// Double damage icon
var(DoubleDamage) const Texture2D DoubleDamageTexture;
// Double damage UV coordinates
var(DoubleDamage, UV) const float DoubleDamageU<DisplayName=U>;
var(DoubleDamage, UV) const float DoubleDamageV<DisplayName=V>;
var(DoubleDamage, UV) const float DoubleDamageUL<DisplayName=UL>;
var(DoubleDamage, UV) const float DoubleDamageVL<DisplayName=VL>;

defaultproperties
{
}