//This module handles transfering data from the host (CPU) to the device (GPU) as
//well as setting up and executing kernels that handle gravitational calculations
//for all of the particles.
module lightwave.devicedata;

import magra.globals;
import lightwave.clutil;
import lightwave.particle;
import lightwave.gravsource;

struct ParticleData
{
    float posx;
    float posy;
    float velx;
    float vely;
    float radius;
}

struct GravityData
{
    float posx;
    float posy;
    float mass;
    float radius;
}

//Particle data arrays for the host and device.
private ParticleData[] hostPData;
private CLMemory!ParticleData devicePData;

//Gravity data arrays or the host and device.
//Unlike with particle sources, this is only ever called
//when gravity sources are added, deleted, moved, or changed.
private GravityData[] hostGData;
private CLMemory!GravityData deviceGData;

void initDeviceData()
{
    devicePData = new CLMemory!ParticleData;
    deviceGData = new CLMemory!GravityData;
}

void syncParticles()
{
    //OPTIMIZE: This does not seem to be causing any performance issues for now,
    //but we should try to avoid using actorsOf here if possible.
    auto particles = actors.actorsOf!(AParticle)();

    size_t slot = 0;

    foreach(particle; particles)
    {
        //Allocate more room for particle data if needed.
        if(slot == hostPData.length)
        {
            if(hostPData.length == 0)
                hostPData.length = 256;
                
            hostPData.length = hostPData.length * 2;
        }

        hostPData[slot].posx = particle.pos.x;
        hostPData[slot].posy = particle.pos.y;
        hostPData[slot].velx = particle.vel.x;
        hostPData[slot].vely = particle.vel.y;
        hostPData[slot].radius = particle.radius;
        particle.dataSlot = slot;
        slot++;
    }

    //Make sure the copy on the device side has enough room to fit
    //all of the incoming elements.
    if(devicePData.length < hostPData.length)
        devicePData.allocate(hostPData.length);

    //Send it to the GPU.
    devicePData.write(hostPData[0 .. slot]);
}

void syncGravitySources()
{
    size_t slot = 0;

    foreach(source; gravitySources)
    {
        if(slot == hostGData.length)
        {
            if(hostGData.length == 0)
                hostGData.length = 64;

            hostGData.length = hostGData.length * 2;
        }

        hostGData[slot].posx = source.pos.x;
        hostGData[slot].posy = source.pos.y;
        hostGData[slot].mass = source.mass;
        hostGData[slot].radius = source.radius;
        source.dataSlot = slot;
        slot++;
    }

    if(deviceGData.length < hostGData.length)
        deviceGData.allocate(hostGData.length);

    deviceGData.write(hostGData[0 .. slot]);
}
