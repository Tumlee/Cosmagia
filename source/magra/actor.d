module magra.actor;

import magra.actorlist;

class Actor
{
    ActorList container;
    abstract bool tick();
}
