module xypoint;

import std.stdio;
import std.string;
import std.conv;
import std.math;
import xyline;

struct XYPoint
{
    float x, y;
    
    pure this(float xx, float yy)
    {
        x = xx;
        y = yy;
    }
    
    XYPoint opUnary(string op : "-")() const
    {
        return XYPoint(-x, -y);
    }
    
    @property pure float mag() const
    {        
        return hypot(x, y);
    }
    
    @property pure float ang() const
    {
        return atan2(y, x);
    }
    
    @property pure float cos() const
    {
        return x / mag;
    }
    
    @property pure float sin() const
    {
        return y / mag;
    }
    
    @property void mag(float newMag)
    {
	    auto mult = newMag / mag;

	    x *= mult;
	    y *= mult;
    }

    @property void ang(float newAng)
    {
	    //Save the magnitude.
	    auto magn = mag;

	    x = magn * ang.cos;
	    y = magn * ang.sin;
    }

    void reDistance(float magn, XYPoint anchor = origin)
    {
	    auto diff = this - anchor;
	    auto mult = magn / diff.mag;

	    x = anchor.x + (mult * diff.x);
	    y = anchor.y + (mult * diff.y);
    }

    void reAngle(float newAngle, XYPoint anchor = origin)
    {
	    //Save the distance between the two points.
	    auto distance = (this - anchor).mag;

	    x = anchor.x + (distance * newAngle.cos);
	    y = anchor.y + (distance * newAngle.sin);
    }
    
    void rotate(float addAngle, XYPoint anchor = origin)
    {
        reAngle(this.ang + addAngle, anchor);
    }

    pure XYPoint slide(XYPoint other) const
    {
	    auto diffAng = other.ang - ang;
	    auto newMag = mag * diffAng.cos;
	    
	    return XYPoint(newMag * other.cos, newMag * other.sin);
    }

    pure float slideMag(XYPoint other) const
    {
	    return mag * (other.ang - ang).cos;
    }

    pure XYPoint perp() const
    {
	    return XYPoint(-y, x);
    }

    pure XYPoint unit() const
    {
	    return XYPoint(cos, sin);
    }
    
    pure XYPoint opBinary(string op)(XYPoint rhs) const
    {
        static if(op == "+")
	        return XYPoint(x + rhs.x, y + rhs.y);
	        
	    else static if(op == "-")
	        return XYPoint(x - rhs.x, y - rhs.y);

        else static if(op == "*")
	        return XYPoint(x * rhs.x, y * rhs.y);
	        
	    else static if(op == "/")
	        return XYPoint(x / rhs.x, y / rhs.y);
	        
	    else static assert(0, "Operator not implemented for XYPoint"); 
    }

    pure XYPoint opBinary(string op)(float rhs) const
    {
        static if(op == "*")
	        return XYPoint(x * rhs, y * rhs);
	        
	    else static if(op == "/")
	        return XYPoint(x / rhs, y / rhs);
	        
	    else static assert(0, "Operator not implemented for XYPoint");
    }
    
    pure void opAssign(XYPoint rhs)
    {
        x = rhs.x;
        y = rhs.y;
    }
    
    pure void opOpAssign(string op)(XYPoint rhs)
    {
        this = opBinary!(op)(rhs);
    }
    
    pure void opOpAssign(string op)(float rhs)
    {
        this = opBinary!(op)(rhs);
    }
    
    static const XYPoint origin = XYPoint(0, 0);
}

pure XYPoint polarCoord(float mag, float ang)
{
    return XYPoint(mag * ang.cos, mag * ang.sin);
}

XYPoint xy(float xx, float yy)()
{
    return XYPoint(xx, yy);
}
