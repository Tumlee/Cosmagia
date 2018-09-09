module lightwave.camera;

import xypoint;
import lightwave.resources;
import magra.renderer;

XYPoint camOrigin;
XYPoint camRange;

void initCamera()
{
    camOrigin = XYPoint(0, 0);
    camRange = XYPoint(200.0 * screenwidth / screenheight, 200.0);
    syncCamera();
}

XYPoint worldToScreenCoordinate(XYPoint worldCoordinate)
{
    return (worldCoordinate - camOrigin) / camRange;
}

XYPoint screenToWorldCoordinate(XYPoint screenCoordinate)
{
    return (screenCoordinate * camRange) + camOrigin;
}

void changeZoomLevel(XYPoint screenPivot, float factor)
{
    //The main idea behind changing the zoom level around a pivot point is that
    //the mouse should stay focused on the same object (or world coodinate) after the zoom takes place.
    XYPoint newCamRange = camRange * factor;

    //Both the new and old values for screenPivot should map to the same worldCoodinate.
    //For this, we have to find a new camera origin such that:
    // (screenPivot * camRange) + camOrigin == (screenPivot * newCamRange) + newCamOrigin
    XYPoint newCamOrigin = (screenPivot * (camRange - newCamRange)) + camOrigin;

    camOrigin = newCamOrigin;
    camRange = newCamRange;
    syncCamera();
}

//Syncs camOrigin and camRange to the GPU as uniforms.
void syncCamera()
{
    //Go through each layer that pays attention to the camera and update
    //the uniforms.
    foreach(qbuf; [particleQB, glowQB, gravQB])
    {
        qbuf.program.setUniform("camRange", camRange.x, camRange.y);
        qbuf.program.setUniform("camOrigin", camOrigin.x, camOrigin.y);
    }
}
