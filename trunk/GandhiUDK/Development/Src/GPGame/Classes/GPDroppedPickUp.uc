// PickupFactory should be used to place items in the level.  This class is for dropped inventory, which should attach
// itself to this pickup, and set the appropriate mesh
class GPDroppedPickup extends DroppedPickUp
	notplaceable;

var PrimitiveComponent PickupMesh;
var ParticleSystemComponent PickupParticles;
var float StartScale;
var bool bPickupable; // EMP forces a pickup to be unusable until it lands
var LightEnvironmentComponent MyLightEnvironment;

event PreBeginPlay()
{
	Super.PreBeginPlay();

	// if player who dropped me is still alive, prevent picking up until landing
	// to prevent that player from immediately picking us up
	bPickupable = (Instigator == None || Instigator.Health <= 0);
}

simulated event SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	if (NewPickupMesh != None && WorldInfo.NetMode != NM_DedicatedServer )
	{
		PickupMesh = new(self) NewPickupMesh.Class(NewPickupMesh);
		if ( class<GPWeapon>(InventoryClass) != None )
		{
			PickupMesh.SetScale(PickupMesh.Scale * 1.2);
		}
		PickupMesh.SetLightEnvironment(MyLightEnvironment);
		AttachComponent(PickupMesh);
	}
}

simulated event SetPickupParticles(ParticleSystemComponent NewPickupParticles)
{
	if (NewPickupParticles != None && WorldInfo.NetMode != NM_DedicatedServer )
	{
		PickupParticles = new(self) NewPickupParticles.Class(NewPickupParticles);
		AttachComponent(PickupParticles);
		PickupParticles.SetActive(true);
	}
}

simulated event Landed(vector HitNormal, Actor FloorActor)
{
	local float DotP, Offset;

	Super.Landed(HitNormal, FloorActor);

	if (PickupMesh != None)
	{
		DotP = HitNormal dot vect(0,0,1);
		if (DotP != 0.0 && DotP < 1.0)
		{
			Offset = sqrt(1.0 - square(DotP)) * CylinderComponent(CollisionComponent).CollisionRadius/DotP;
		}
		if ( class<GPWeapon>(InventoryClass) != None )
		{
			
			//Offset += class<GPWeapon>(InventoryClass).default.DroppedPickupOffsetZ;
		}
	  
		PickupMesh.SetTranslation(vect(0,0,-1) * Offset);
		if(PickupParticles != None)
		{
			PickupParticles.SetTranslation(vect(0,0,-1) * Offset);
		}
	}
}

auto state Pickup
{
	function bool EverythingValid(Pawn Other)
	{
		// make sure its a live player and it is Gandhi
		if (Other == None || !Other.bCanPickupInventory || 
		   (Other.DrivenVehicle == None && Other.Controller == None) ||
		   (Other.Class != class'GPPlayerPawn'))
		{
			return false;
		}

		// make sure thrower doesn't run over own weapon
		if ( (Physics == PHYS_Falling) && (Other == Instigator) && (Velocity.Z > 0) )
		{
			return false;
		}

		// make sure not touching through wall
		//if ( !FastTrace(Other.Location, Location) )
		//{
		//	SetTimer( 0.5, false, nameof(RecheckValidTouch) );
		//	return false;
		//}
	
		// make sure game will let player pick me up
		if (WorldInfo.Game.PickupQuery(Other, Inventory.class, self))
		{
			return true;
		}
		return false;
	}

	/*
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch(Pawn Other)
	{
		return (bPickupable) ? EverythingValid(Other) : false;
		//return (bPickupable) ? Super.ValidTouch(Other) : false;
	}

	simulated event Landed(vector HitNormal, Actor FloorActor)
	{
		Global.Landed(HitNormal, FloorActor);
		if (Role == ROLE_Authority && !bPickupable)
		{
			bPickupable = true;
			CheckTouching();
		}
	}
}

State FadeOut
{

	simulated event Tick(FLOAT DeltaSeconds)
	{
		if ( (WorldInfo.NetMode == NM_DedicatedServer) || (PickupMesh == None) )
		{
			Disable('Tick');
		}
		else 
		{
			PickupMesh.SetScale(FMax(0.01, PickupMesh.Scale - StartScale * DeltaSeconds));
		}
	}

	simulated function BeginState(Name PreviousStateName)
	{
		bFadeOut = true;
		if ( PickupMesh != None )
		{
			StartScale = PickupMesh.Scale;
		}

		if( PickupParticles != None )
		{
			PickupParticles.DeactivateSystem();
		}

		LifeSpan = 1.0;
	}
}

defaultproperties
{
	LifeSpan = 0.0;
	Begin Object Class=DynamicLightEnvironmentComponent Name=DroppedPickupLightEnvironment
		bDynamic=FALSE
		bCastShadows=FALSE
		AmbientGlow=(R=0.2,G=0.2,B=0.2,A=1.0)
	End Object
	MyLightEnvironment=DroppedPickupLightEnvironment
	Components.Add(DroppedPickupLightEnvironment)
	bPickupable=true
	bDestroyedByInterpActor=TRUE
}