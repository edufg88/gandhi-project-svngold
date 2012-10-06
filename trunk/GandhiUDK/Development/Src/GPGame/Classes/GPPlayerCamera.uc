class GPPlayerCamera extends Camera;

// Reference to the camera properties
var GPCameraProperties CameraProperties;
var GPTPCameraProperties TPCameraProperties;
var GPShoulderCameraProperties SHCameraProperties; 
var GPShoulderCameraProperties SHLeftCoverCameraProperties; 

// Required for smooth camera movement
var Vector CurrentCamLocation;
var Vector DestinationCamLocation;
var Rotator CurrentCamOrientation;
var Rotator DestinationCamOrientation;

/**
 * Query ViewTarget and outputs Point Of View.
 *
 * @param		OutVT			ViewTarget to use.
 * @param		DeltaTime		Delta Time since last camera update (in seconds).
 */
function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local GPPlayerPawn GPPlayerPawn;
	local Pawn Pawn;
	local Vector V, HitLocation, HitNormal;
	local vector CamStart;
	local float DesiredCameraZOffset;

	
	if (CameraProperties == None)
	{
		Super.UpdateViewTarget(OutVT, DeltaTime);
	}

	// Don't update outgoing viewtarget during an interpolation 
	if (PendingViewTarget.Target != None && OutVT == ViewTarget && BlendParams.bLockOutgoing)
	{
		return;
	}

	Pawn = Pawn(OutVT.Target);
	GPPlayerPawn = GPPlayerPawn(Pawn);
	if (Pawn != None)
	{
		CamStart = Pawn.Location;
		DesiredCameraZOffset = 1.2 * Pawn.GetCollisionHeight() + Pawn.Mesh.Translation.Z;
		CamStart.Z += DesiredCameraZOffset;

		if (GPPlayerPawn.IsAiming)
		{
			if(GPPlayerPawn.IsInState('CoverEdging') && GPPlayerController(GPPlayerPawn.Controller).LastStrafe < 0) CameraProperties = SHLeftCoverCameraProperties;
			else CameraProperties = SHCameraProperties;
		}
		else
		{
			CameraProperties = TPCameraProperties;
		}

		// If the camera properties have a valid pawn socket name, then start the camera location from there
		if (Pawn.Mesh != None && Pawn.Mesh.GetSocketByName(CameraProperties.PawnSocketName) != None)
		{
			Pawn.Mesh.GetSocketWorldLocationAndRotation(CameraProperties.PawnSocketName, DestinationCamLocation, DestinationCamOrientation);
		}
		// Otherwise grab it from the target eye view point
		else
		{
			OutVT.Target.GetActorEyesViewPoint(DestinationCamLocation, DestinationCamOrientation);
		}

		// If the camera properties forces the camera to always use the target rotation, then extract it now
		if (CameraProperties.UseTargetRotation)
		{
			OutVT.Target.GetActorEyesViewPoint(V, DestinationCamOrientation);
		}

		// Add the camera offset
		DestinationCamOrientation += CameraProperties.CameraRotationOffset;
		// Calculate the potential camera location
		DestinationCamLocation += (CameraProperties.CameraOffset >> DestinationCamOrientation);		

		// Trace out to see if the potential camera location will be acceptable or not


		// Smooth location transition
		if (DestinationCamLocation != CurrentCamLocation)
		{
			CurrentCamLocation = VInterpTo(CurrentCamLocation, DestinationCamLocation, DeltaTime, 10);
		}

		// Smooth rotation transition
		if (DestinationCamOrientation != CurrentCamOrientation)
		{
			CurrentCamOrientation = RInterpTo(CurrentCamOrientation, DestinationCamOrientation, DeltaTime, 10);
		}

		OutVT.POV.Location = CurrentCamLocation;
		OutVT.POV.Rotation = CurrentCamOrientation;

		if (Trace(HitLocation, HitNormal, OutVT.POV.Location, CamStart, false, vect(12,12,12)) != None)
		{
			OutVT.POV.Location = HitLocation;
		}
	}
}

defaultproperties
{
	SHCameraProperties=GPShoulderCameraProperties'GP_Archetypes.Camera.GPShoulderCameraProperties'
	SHLeftCoverCameraProperties=GPShoulderCameraProperties'GP_Archetypes.Camera.GPLeftShoulderCameraProperties'
	TPCameraProperties=GPTPCameraProperties'GP_Archetypes.Camera.GPTPCameraProperties'
	CameraProperties=GPCameraProperties'GP_Archetypes.Camera.GPTPCameraProperties'
}