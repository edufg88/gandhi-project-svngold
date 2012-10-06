class GPPuzzlePiece extends GPInventoryItem placeable;

var(Puzzle) editinline instanced string code;

function string GetName()
{
	return "Puzzle Piece";
}

event PostBeginPlay()
{
	class'GPHUD'.static.PuzzleSpawned(self);
	super.PostBeginPlay();
}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	class'GPHUD'.static.PuzzlePicked(self);
	return false;
}


DefaultProperties
{
}
