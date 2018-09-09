module lightwave.particle;

import magra.base;
import magra.renderer;
import lightwave.resources;
import lightwave.gravsource;
import xypoint;
import std.math, std.algorithm;

void drawParticle(XYPoint center, float radius, RGBA color)
{
    int vertexLength = particleQB.vao.totalAttributeLength;
    static float[] bufferData;

    if(bufferData.length == 0)
        bufferData.length = vertexLength * 4;

    size_t vStart = 0;

    enum float[] xtab = [0, 1, 1, 0];
    enum float[] ytab = [1, 1, 0, 0];
    
    foreach(int i; 0 .. 4)
    {
        float x = xtab[i];
        float y = ytab[i];
        float vx = center.x + radius * 2 * (x - .5);
        float vy = center.y + radius * 2 * (y - .5);
        bufferData[vStart .. vStart + vertexLength] = [vx, vy, x, y, color.r, color.g, color.b, color.a];
        vStart += vertexLength;
    }

    particleQB.addElement(bufferData);
}

class AParticle : Actor
{
    XYPoint pos;
    XYPoint vel;
    PositionQueue pqueue;
    float radius = 2.5;
    AGravSource hit = null;
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

        //If we've hit a Gravity source already, "sink" into that source
        //and then disappear.
        if(hit)
        {
            deathClock -= 1.0 / 10.0;
            auto alpha = fmax(deathClock, 0.0);
            
            //particleLayer.add(new CParticle(dot, pos, 1.0, 0.0, 1.0, alpha * alpha, 0.66));
            //glowLayer.add(new CParticle(glow, pos, 1.0, 0.0, 1.0, alpha * alpha * .5, 1.1));
            
            return deathClock > 0.0;
        }
        
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
                    hit = source;
                    vel = polarCoord(1.0, (pos - source.pos).ang);
                }
            }
        }

        if(pos.mag() > 1024)
            return false;
        
        //particleLayer.add(new TParticle(dot, pqueue, vel.ang, sat, val, 1.0, 0.66));
        drawWithTrail();

        if(curGrav.mag > .03)
        {
            //Should scale from 0% at .2 to 100% at .4
            auto glowAmount = sqrt(fmin((curGrav.mag - .03) / .35, 1.0));
            
            //glowLayer.add(new CParticle(glow, pos, vel.ang, 1.0, 1.0, glowAmount, 1.1));
        }
        
        return true;
    }

    void drawWithTrail()
    {
        //Color is determined by the direction of movement.
        //The saturation is determined by the speed.
        auto val = fmin(.66 + (vel.mag / 2.5), 1.0);
        auto sat = fmin(vel.mag / 1.0, 1.0);
        
        //Draw the trail, back to front.
        foreach(i; 0 .. pqueue.numPositions)
        {
            float alpha = (cast(float) (i + 1) / pqueue.numPositions);

            if(i != pqueue.numPositions - 1)
                alpha *= .5;
            
            drawParticle(pqueue.getPosition(i), radius, RGBA.fromHSVA(vel.ang, sat, val, alpha));
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
