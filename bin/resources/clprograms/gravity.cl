typedef struct
{
    float posx;
    float posy;
    float velx;
    float vely;
    float radius;
} ParticleData;

typedef struct
{
    float posx;
    float posy;
    float velx;
    float vely;
    uint collision;
} ParticleMovestep;

typedef struct
{
    float posx;
    float posy;
    float mass;
    float radius;
} GravityData;

kernel void moveParticles(  global ParticleData* particles,
                            global GravityData* gravitySources,
                            uint numGravitySources,
                            global ParticleMovestep* movesteps,
                            uint numSteps)
{
    uint pindex = get_global_id(0);
    global ParticleData* particle = &particles[pindex];
    float posx = particle->posx;
    float posy = particle->posy;
    float velx = particle->velx;
    float vely = particle->vely;
    uint collision = -1;

    for(int s = 0; s < numSteps; s++)
    {
        float accelx = 0.0f;
        float accely = 0.0f;
        
        for(int g = 0; g < numGravitySources; g++)
        {
            global GravityData* source = &gravitySources[g];

            //Calculate gravitational pull and distance.
            //Note that to avoid a sqrt() operation, we divide by dsquared, since
            //gravitational force is inverse to distance squared.
            float dx = source->posx - posx; 
            float dy = source->posy - posy;
            float ang = atan2(dy, dx);
            float dsquared = (dx * dx) + (dy * dy);
            float mag = source->mass / dsquared;

            accelx += mag * cos(ang);
            accely += mag * sin(ang);

            float combinedRadius = particle->radius + source->radius;

            //Particle is touching a gravitational source.
            if((combinedRadius * combinedRadius) > dsquared)
                collision = g;
        }

        velx += accelx / numSteps;
        vely += accely / numSteps;
        posx += velx / numSteps;
        posy += vely / numSteps;

        global ParticleMovestep* step = &movesteps[(pindex * numSteps) + s];

        step->posx = posx;
        step->posy = posy;
        step->velx = velx;
        step->vely = vely;
        step->collision = collision;
    }
}
