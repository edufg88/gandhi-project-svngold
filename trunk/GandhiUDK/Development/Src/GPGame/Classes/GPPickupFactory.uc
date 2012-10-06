class GPPickupFactory extends PickupFactory
	Abstract
	HideCategories(NavigationPoint,VehicleUsage,Physics,Debug,Object);

// Dynamic light environment
var(PickupFactory) const DynamicLightEnvironmentComponent LightEnvironment;
// Base static mesh component
var(PickupFactory) const StaticMeshComponent BaseStaticMesh;
// Glow static mesh component
var(PickupFactory) const StaticMeshComponent GlowStaticMesh;
// Pick up static mesh component
var(PickupFactory) const StaticMeshComponent PickupStaticMesh;
// Light component
var(PickupFactory) const LightComponent Light;
// Repsawn time
var(PickupFactory) const float RespawnTime;
// Pick up static mesh rotation rate
var(PickupFactory) const Rotator PickupStaticMeshRotationRate;
// Pick up static mesh sine floating height
var(PickupFactory) const float PickupStaticMeshFloatingHeight;

var protected Vector DefaultPickupStaticMeshTranslation;

/**
 * Called when the pick up factory is instanced
 *
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Grab the static mesh translation stored in the archetype
	if (PickupStaticMesh != None)
	{
		DefaultPickupStaticMeshTranslation = PickupStaticMesh.Translation;
	}
}

/**
 * Initializes the pick up factory
 *
 */
simulated function InitializePickup();

/**
 * Sets the initial state of the pick up factory
 * 
 */
simulated event SetInitialState()
{
	//`Log("PF - SetInitialState");
	// Only the set initial state function in the NavigationPoint is useful
	Super(NavigationPoint).SetInitialState();
}

/**
 * Sets the pick up mesh
 * 
 */
simulated function SetPickupMesh()
{
	// If the pick up is hidden, then hide the mesh
	if (bPickupHidden)
	{
		SetPickupHidden();
	}
	// Otherwise reveal the mesh
	else
	{
		SetPickupVisible();
	}
}

/**
 * Spawns a copy of the pick up for a pawn
 *
 * @param			Recipient			Pawn to receive the copy of the pick up
 */
function SpawnCopyFor(Pawn Recipient);

/** 
 * Give pickup to player 
 *
 * @param		Pawn		Pawn to give the pick up to
 */
function GiveTo(Pawn Pawn)
{	
	//`Log("PF - Give to Pawn");
	PickedUpBy(Pawn);
}

/**
 * Returns the time it takes for this pick up to respawn
 *
 * @return			Returns the time it takes for this pick up to respawn
 */
function float GetRespawnTime()
{
	return RespawnTime;
}

/**
 * Called when this pick up factory is updated
 *
 * @param		DeltaTime			Time since the last tick
 */
simulated function Tick(float DeltaTime)
{
	// Make the pick up mesh rotate and move up and down
	if (PickupStaticMesh != None)
	{
		PickupStaticMesh.SetRotation(PickupStaticMesh.Rotation + (PickupStaticMeshRotationRate * DeltaTime));
		PickupStaticMesh.SetTranslation(DefaultPickupStaticMeshTranslation + (Vect(0.f, 0.f, 1.f) * Sin(WorldInfo.TimeSeconds) * PickupStaticMeshFloatingHeight));
	}
}

/**
 * Sets the respawn time
 *
 */
function SetRespawn()
{
	// Start sleeping if there is a respawn time
	if (GetRespawnTime() > 0.f)
	{
		StartSleeping();
	}
	// Otherwise, just disable the pick up factory
	else
	{
		GotoState('Disabled');
	}
}

/**
 * Returns true if the pick up can be picked up by a pawn
 *
 * @param			Other			The pawn trying to pick up this pick up
 * @return							Returns true if the pick up can be picked up by the pawn
 */
function bool CanPickup(Pawn Other)
{
	//`Log("PF - Can Pick UP");

	return true;
}

/**
 * When the pick up factory is in this state, the pick up is ready to be picked up
 *
 */
auto state Pickup
{
	/**
	 * Validate touch (if valid return true to let other pick me up and trigger event).
	 *
	 * @param		Other			The pawn trying to pick up this pick up
	 */
	function bool ValidTouch(Pawn Other)
	{
		//`Log("PF - Valid Touch");

		/*
		 * if (Other == None || !Other.bCanPickupInventory)
		{
			return false;
		}
		else if (Other.Controller == None)
		{
			// re-check later in case this Pawn is in the middle of spawning, exiting a vehicle, etc
			// and will have a Controller shortly
			SetTimer( 0.2, false, nameof(RecheckValidTouch) );
			return false;
		}
		// make sure not touching through wall
		else if ( !FastTrace(Other.Location, Location) )
		{
			SetTimer( 0.5, false, nameof(RecheckValidTouch) );
			return false;
		}

		// make sure game will let player pick me up
		if (WorldInfo.Game.PickupQuery(Other, InventoryType, self))
		{
			return true;
		}
		return false;*/

		if (CanPickup(Other))
		{
			return true;
		}

		return false;
	}
}

/**
 * When the pick up is in this state, the pick up is waiting to be respawned
 *
 */
state Sleeping
{
Begin:
	// Sleep for a small amount of time
	Sleep(GetRespawnTime() - RespawnEffectTime);
Respawn:
	// Respawn and go back to the pick up state
	RespawnEffect();
	Sleep(RespawnEffectTime);
	GotoState('Pickup');
}

defaultproperties
{
	Components.Remove(Sprite)
	Components.Remove(Sprite2)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment
	
	Begin Object Class=DrawLightRadiusComponent Name=MyDrawLightRadius
	End Object
	Components.Add(MyDrawLightRadius)

	Begin Object Class=DrawLightRadiusComponent Name=MyDrawLightSourceRadius
		SphereColor=(R=231,G=239,B=0,A=255)
	End Object
	Components.Add(MyDrawLightSourceRadius)

	Begin Object Class=PointLightComponent Name=MyPointLightComponent
		CastShadows=true
		CastStaticShadows=true
		CastDynamicShadows=false
		bForceDynamicLight=false
		UseDirectLightMap=true
		LightingChannels=(BSP=true,Static=true,Dynamic=true,bInitialized=true)
		PreviewLightRadius=MyDrawLightRadius
		PreviewLightSourceRadius=MyDrawLightSourceRadius
	End Object
	Components.Add(MyPointLightComponent)
	Light=MyPointLightComponent

	Begin Object Class=StaticMeshComponent Name=MyBaseStaticMeshComponent
		LightEnvironment=MyLightEnvironment
	End Object
	Components.Add(MyBaseStaticMeshComponent)
	BaseStaticMesh=MyBaseStaticMeshComponent

	Begin Object Class=StaticMeshComponent Name=MyGlowStaticMeshComponent
		LightEnvironment=MyLightEnvironment
	End Object
	Components.Add(MyGlowStaticMeshComponent)
	GlowStaticMesh=MyGlowStaticMeshComponent

	Begin Object Class=StaticMeshComponent Name=MyPickupStaticMeshComponent
		LightEnvironment=MyLightEnvironment
	End Object
	Components.Add(MyPickupStaticMeshComponent)
	PickupStaticMesh=MyPickupStaticMeshComponent
	PickupMesh=MyPickupStaticMeshComponent

	RespawnTime=5.f
	PickupStaticMeshRotationRate=(Yaw=8192)
	PickupStaticMeshFloatingHeight=8.f
}