module lightwave.gravsource;
import magra.base;
import lightwave.resources;
import magra.renderer;
import xypoint;
import std.array, std.math;

void drawGrav(XYPoint center, float radius, RGBA color)
{
    float wx0 = center.x - radius * 1.5;
    float wy0 = center.y - radius * 1.5;
    float wx1 = center.x + radius * 1.5;
    float wy1 = center.y + radius * 1.5;

    gravQB.addElement([ wx0, wy0, 0, 0, color.r, color.g, color.b, color.a,
                        wx1, wy0, 1, 0, color.r, color.g, color.b, color.a,
                        wx1, wy1, 1, 1, color.r, color.g, color.b, color.a,
                        wx0, wy1, 0, 1, color.r, color.g, color.b, color.a]);
}

class AGravSource : Actor
{
    XYPoint pos;
    XYPoint vel; //Not used as an actual velocity, used for glow effects.
    float mass;
    float radius = 7.0;
    float lifeTime = 0.0;
    
    this(float x, float y)
    {
        mass = 32.0;
        pos.x = x;
        pos.y = y;
        vel = XYPoint(0,0);
    }
    
    override bool tick()
    {
        lifeTime += 1.0 / 60.0;

        vel *= .92;

        auto sat = fmin(vel.mag / 4.0, 1.0);

        drawGrav(pos, fmin(sin(lifeTime * 7.0) * .1 + 1.1 + (vel.mag / 6.0), 10.0) * radius,
                    RGBA.fromHSVA(vel.ang, sat, 1.0, 1.0));

        drawGrav(pos, fmin(sin(lifeTime * 7.0) * .1 + 1.1 + (vel.mag / 6.0), 10.0) * radius * .7,
                    RGBA.fromHSVA(vel.ang, sat * .2, 1.0, 1.0));
                    
        return true;
    }
}

//A pre-compilred list of all gravity sources, so that we don't have to iterate
//using actorsOf unnecessarily.
AGravSource[] gravitySources;

void updateGravitySources()
{
    gravitySources = actors.actorsOf!AGravSource.array;
}
