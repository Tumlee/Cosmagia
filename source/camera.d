module lightwave.camera;

import xypoint;
import lightwave.resources;

XYPoint camOrigin;
XYPoint camRange;

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
}

