module lightwave.particle;

import magra.base;
import magra.renderer;
import lightwave.resources;
import lightwave.gravsource;
import xypoint;
import std.math, std.algorithm;

void drawParticle(QuadBuffer qbuf, XYPoint center, float radius, XYPoint vel, float alpha)
{
    float wx0 = center.x - radius;
    float wy0 = center.y - radius;
    float wx1 = center.x + radius;
    float wy1 = center.y + radius;

    qbuf.addElement([   wx0, wy0, 0, 0, vel.x, vel.y, alpha,
                        wx1, wy0, 1, 0, vel.x, vel.y, alpha,
                        wx1, wy1, 1, 1, vel.x, vel.y, alpha,
                        wx0, wy1, 0, 1, vel.x, vel.y, alpha]);
}

class AParticle : Actor
{
    XYPoint pos;
    XYPoint vel;
    PositionQueue pqueue;
    float radius = 2.5;
    float deathClock = 1.0;

    this(XYPoint p, XYPoint v)
    {
        pos = p;
        vel = v;
        pqueue = new PositionQueue(6);
    }

    pure XYPoint gravVector(AGravSource source)
    {
        auto r = source.pos - pos;
        return polarCoord(source.mass / (r.mag * r.mag), r.ang);
    }
    
    XYPoint currentGravity()
    {
        return gravitySources
                .map!(source => gravVector(source))
                .sum(XYPoint(0,0));
    }

    override bool tick()
    {
        enum gravityIterations = 2;

        XYPoint curGrav;
        
        foreach(i; 0 .. gravityIterations)
        {
            curGrav = currentGravity();
            
            vel += curGrav / gravityIterations;
            pos += vel / gravityIterations;

            pqueue.pushPosition(pos);

            foreach(source; gravitySources)
            {
                if((pos - source.pos).mag < radius + source.radius)
                {
                    source.vel += vel;
                    return false;
                }
            }
        }

        if(pos.mag() > 1024)
            return false;
        
        drawWithTrail(curGrav);
        return true;
    }

    void drawWithTrail(XYPoint curGrav)
    {        
        //Draw the trail, back to front.
        foreach(i; 0 .. pqueue.numPositions)
        {
            float alpha = (cast(float) (i + 1) / pqueue.numPositions);

            if(i != pqueue.numPositions - 1)
                alpha *= .5;
            
            drawParticle(particleQB, pqueue.getPosition(i), radius, vel, alpha);
        }

        if(curGrav.mag > .025)
        {
            //Should scale from 0% at .2 to 100% at .4
            auto glowAmount = sqrt(fmin((curGrav.mag - .025) / .2, 1.0));
            drawParticle(glowQB, pos, radius * 4, vel, glowAmount);
        }
    }
}

//A round-robin queue of positions a particle has been in.
//This is used for motion-blur effects.
class PositionQueue
{
    private XYPoint[] positions;
    private ulong maxElements;
    private ulong current;

    this(uint mElements)
    {
        maxElements = mElements;
    }

    @property ulong numPositions()
    {
        return positions.length;
    }

    void pushPosition(XYPoint newPoint)
    {
        if(positions.length < maxElements)
        {
            positions ~= newPoint;
            current = positions.length - 1;
        }
        else
        {
            current = (current + 1) % maxElements;
            positions[current] = newPoint;
        }
    }

    //Gets the appropriate position where x=(numPositions-1) is the current position.
    //x should never be >= numPositions
    XYPoint getPosition(ulong x)
    {
        assert(x < numPositions);

        return positions[(x + current + 1) % numPositions];
    }
}
