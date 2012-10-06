class GPPiecesTrigger extends Trigger;

var int PiecesLeft;
var Array<string> Codes; // Realmente es innecesario, se buscan 4 códigos distintos sean los que sean
var Array<string> CodesEntered;
var bool locked;

simulated function PostBeginPlay()
{
	Codes.AddItem("Miquel");
	Codes.AddItem("Edu");
	Codes.AddItem("Arnau");
	Codes.AddItem("Roger");
}

// En est función controlamos cuándo se activa
function bool UsedBy(Pawn User)
{
	local GPPlayerPawn GPPawn;
	local GPPuzzlePiece GPPiece;

	// Si todavía no hemos puesto todas las piezas
	if (locked && PiecesLeft > 0)
	{
		GPPawn = GPPlayerPawn(User);
		ForEach GPPawn.InvManager.InventoryActors(class'GPPuzzlePiece', GPPiece)
		{
			// Buscamos si tenemos alguna pieza nueva
			if ( CodesEntered.Find(GPPiece.code) == INDEX_NONE)
			{
				CodesEntered.AddItem(GPPiece.code);
				PiecesLeft--;
			}
		}

		// Si ya hemos completado
		if (PiecesLeft == 0)
		{
			locked = false;
		}
	}
	else
	{
		return Super.UsedBy(User);
	}

	return false;
}

DefaultProperties
{
	PiecesLeft = 4;
	locked = true;
}
