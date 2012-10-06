class GPDoorTrigger extends Trigger;

var() string TriggerCode;
var() bool Locked;

// En esta función controlamos cuándo se activa
function bool UsedBy(Pawn User)
{
	local GPPlayerPawn GPPawn;
	local GPDoorKey GPKey;

	// Si no tiene seguridad o ya la hemos abierto antes la abrimos
	if (!Locked)
	{
		return Super.UsedBy(User);
	}
	else if (User != None)
	{
		GPPawn = GPPlayerPawn(User);
		ForEach GPPawn.InvManager.InventoryActors(class'GPDoorKey', GPKey)
		{
			// Si tenemos en el inventario alguna llave que abra la puerta podremos abrirla
			if (GPKey.code == TriggerCode)
			{
				// Aquí podemos meter un mensaje diciendo (La puerta está cerrada...Quieres usar la llave tal?...)
				Locked = false;
				class'GPHUD'.static.showHUDText("You unlocked the door", 3000);
				return Super.UsedBy(User);
			}
		}
	}

	return false;
}

DefaultProperties
{
	TriggerCode = "holaquetalsoyelchicodelaspoesias";
	Locked = false;
}
