module magra.actorlist;

import std.range;
import std.algorithm;
import std.exception;

import magra.actor;

class ActorList
{
    Actor[] actors;
    bool paused = false;
    bool ticking = false;
    
    void spawn(Actor actor)
    {
        enforce(actor !is null, "Spawned a null actor");
    
        actors ~= actor;
        actor.container = this;
    }
    
    void tick()
    {
        enforce(!ticking, "Ticked an already-ticking ActorList");
        
        ticking = true;
        
        foreach(ref actor; actors)
        {
            if(actor.tick() == false)
                actor = null;
        }
        
        actors = actors.filter!("a !is null").array;
        ticking = false;
    }

    auto actorsOf(T = Actor)()
    {
        return actors.map!(a => cast(T) a)
                    .filter!(a => a !is null);
    }
    
    void clear(T = Actor)()
    {
        enforce(!ticking, "Cleared from a ticking ActorList");
        
        //NOTE: This call is causing an internal compiler error.
        //This follow code is a workaround, but eventually we want
        //this.
        //actors = actors.filter!(a => cast(T) a is null).array;
        Actor[] newActors;
        
        foreach(actor; actors)
        {
            if(cast(T) actor is null)
                newActors ~= actor;
        }
        
        actors = newActors;
    }
}
