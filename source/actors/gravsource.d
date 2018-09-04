module lightwave.gravsource;
import magra.base;
import lightwave.resources;
import xypoint;
import std.array, std.math;

class AGravSource : Actor
{
    XYPoint pos;
    XYPoint vel; //Not used as an actual velocity, used for glow effects.
    float mass;
    float radius = 7.0;
    float lifeTime = 0.0;
    
    this(float x, float y)
    {
        mass = 256.0;
        pos.x = x;
        pos.y = y;
        vel = XYPoint(0,0);
    }
    
    override bool tick()
    {
        lifeTime += 1.0 / 60.0;

        vel *= .92;

        auto sat = fmin(vel.mag / 4.0, 1.0);
    
        //glowLayer.add(new CParticle(glow, pos, vel.ang, sat, 1.0, 1.0, fmin(sin(lifeTime * 7.0) * .1 + 1.1 + (vel.mag / 8.0), 10.0)));
        //glowLayer.add(new CParticle(glow, pos, vel.ang, sat * .2, 1.0, 1.0, .8));
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
