module xyline;

import xypoint;
import std.math;

struct XYLine
{
    XYPoint v1, v2;

    //==================================
    //Constructors for the XYLine class.
    //==================================
    pure this(XYPoint vv1, XYPoint vv2)
    {
	    v1 = vv1;
	    v2 = vv2;
    }

    this(float x1, float y1, float x2, float y2)
    {
	    v1 = XYPoint(x1, y1);
	    v2 = XYPoint(x2, y2);
    }

    //=========================================
    //Information getters for the XYLine struct.
    //=========================================
    @property pure float mag() const
    {
	    return (v2 - v1).mag;
    }

    @property pure float ang() const
    {
	    return (v2 - v1).ang;
    }

    @property pure float cos() const
    {
	    return (v2 - v1).cos;
    }

    @property pure float sin() const
    {
	    return (v2 - v1).sin;
    }

    @property pure float dx() const
    {
	    return v2.x - v1.x;
    }

    @property pure float dy() const
    {
	    return v2.y - v1.y;
    }

    @property pure float xSlope() const
    {
	    return dx / dy;
    }

    @property pure float ySlope() const
    {
	    return dy / dx;
    }
    
    @property pure XYLine reverse() const
    {
        return XYLine(v2, v1);
    }

    pure float xAtY(float y) const
    {
	    return v1.x + (xSlope * (y - v1.y));
    }

    pure float yAtX(float x) const
    {
	    return v1.y + (ySlope * (x - v1.x));
    }

    pure XYPoint pos(float pcn) const
    {
	    return (v2 * pcn) + (v1 * (1 - pcn));
    }

    @property pure XYPoint center() const
    {
	    return (v1 + v2) / 2;
    }

    pure int pointSide(XYPoint pt) const
    {
	    float diffAng = ang - XYPoint(v1.x - pt.x, v1.y - pt.y).ang;
	    return diffAng.sin > 0 ? 1 : -1;
    }

    pure float pointDist(XYPoint pt) const
    {
	    XYPoint hypot = v1 - pt;

	    return (hypot.mag * .sin(ang - hypot.ang)).abs;
    }

    pure XYPoint intersect(XYLine other) const
    {
	    if(dx == 0.0)	//This line has a constant x value.
		    return XYPoint(v1.x, other.yAtX(v1.x));

	    if(other.dx == 0.0)
	        return XYPoint(other.v1.x, yAtX(other.v1.x));

        //Neither of the lines are vertical, so we use a slope formula
        //to find out exactly where they intersect.
	    float ySl = other.ySlope - ySlope;
	    float xCross = (yAtX(0.0) - other.yAtX(0.0)) / ySl;

	    return XYPoint(xCross, yAtX(xCross));
    }
    
    pure bool doesIntersect(XYLine other) const
    {
    	if(pointSide(other.v1) == pointSide(other.v2))
		    return false;	//Other line stops short.

	    if(other.pointSide(v1) == other.pointSide(v2))
		    return false;	//This line stops short.
        
        return true;
    }
    
    pure XYLine clipAgainst(XYLine clipLine) const
    {
        XYLine returnLine = this;
    
        if(clipLine.pointSide(v1) != clipLine.pointSide(v2))
        {
            if(clipLine.pointSide(v1) == -1)
                returnLine.v1 = intersect(clipLine);
                
            if(clipLine.pointSide(v2) == -1)
                returnLine.v2 = intersect(clipLine);
        }
        
        return returnLine;
    }
    
    pure bool isFullyClippedBy(XYLine clipLine) const
    {
    	return clipLine.pointSide(v1) == -1 && clipLine.pointSide(v2) == -1;
    }
    
    pure XYLine opBinary(string op)(XYPoint rhs) const
    {
        static if(op == "+")
	        return XYLine(v1 + rhs, v2 + rhs);
	        
	    else static if(op == "-")
	        return XYLine(v1 - rhs, v2 - rhs);
	        
	    else static assert(0, "Operator not implemented for XYLine"); 
    }
}
