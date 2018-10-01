//This module handles transfering data from the host (CPU) to the device (GPU) as
//well as setting up and executing kernels that handle gravitational calculations
//for all of the particles.
module cosmagia.devicedata;

import magra.globals;
import cosmagia.clutil;
import cosmagia.actors.particle;
import cosmagia.actors.gravsource;
import std.algorithm;
import std.range;

struct ParticleData
{
    float posx;
    float posy;
    float velx;
    float vely;
    float radius;
}

struct ParticleMovestep
{
    float posx;
    float posy;
    float velx;
    float vely;
    uint collision;
}

struct GravityData
{
    float posx;
    float posy;
    float mass;
    float radius;
}

//GPU-side particle and particle movement data.
private CLMemory!ParticleData devicePData;
private CLMemory!ParticleMovestep deviceMData;

enum uint numMovesteps = 2;

//If true, we do not call and OpenCL functions and use the CPU to calculate everything.
bool cpuFallbackMode = false;

//Gravity data arrays or the host and device.
//Unlike with particle sources, this is only ever called
//when gravity sources are added, deleted, moved, or changed.
private GravityData[] hostGData;
private CLMemory!GravityData deviceGData;

private CLKernel gravityKernel;

//Equal to CL_DEVICE_MAX_WORK_GROUP_SIZE so that we are always using
//the maximum number of work items per work group.
private size_t particleChunkSize;

void initDeviceData()
{
    if(cpuFallbackMode)
        return;

    particleChunkSize = getChosenCLDeviceInfo!size_t(CL_DEVICE_MAX_WORK_GROUP_SIZE)[0];
    
    devicePData = new CLMemory!ParticleData;
    deviceGData = new CLMemory!GravityData;
    deviceMData = new CLMemory!ParticleMovestep;

    gravityKernel = new CLKernel("gravity", "moveParticles");
}

void stepParticles()
{
    if(cpuFallbackMode)
        return;
    
    //OPTIMIZE: This does not seem to be causing any performance issues for now,
    //but we should try to avoid using actorsOf here if possible.
    auto particles = actors.actorsOf!(AParticle)();
    size_t numParticles = actors.countActorsOf!(AParticle)();

    if(numParticles == 0)
        return;

    //Reallocate devicePData if there isn't enough room to fit all the particles.
    //Expand the deviceMData array to match.
    while(numParticles > devicePData.length)
    {
        size_t numDeviceParticles = max(particleChunkSize, devicePData.length * 2);
        devicePData.allocate(numDeviceParticles, CL_MEM_WRITE_ONLY | CL_MEM_ALLOC_HOST_PTR);
        deviceMData.allocate(devicePData.length * numMovesteps, CL_MEM_READ_ONLY | CL_MEM_ALLOC_HOST_PTR);
    }

    devicePData.mmap(CL_MAP_WRITE);

    foreach(slot, particle; particles.enumerate)
    {
        ParticleData pdata;
        pdata.posx = particle.pos.x;
        pdata.posy = particle.pos.y;
        pdata.velx = particle.vel.x;
        pdata.vely = particle.vel.y;
        pdata.radius = particle.radius;
        devicePData[slot] = pdata;
        particle.dataSlot = slot;
    }

    devicePData.unmmap();

    //Run the kernel. To avoid situations where we end up with a very
    //small groupsize, we pad the data to the nearest 256, rounding up.
    gravityKernel.setArgs(devicePData, deviceGData, cast(uint) gravitySources.length, deviceMData, numMovesteps);
    gravityKernel.enqueue([numParticles.roundUpToNearest(particleChunkSize)]);

    //Open movement data for reading so Particles can read the data.
    deviceMData.mmap(CL_MAP_READ);
}

void finalizeStepParticles()
{
    if(cpuFallbackMode || !deviceMData.isMMapped())
        return;

    deviceMData.unmmap();
}

ref const(ParticleMovestep) getMovestep(const AParticle particle, size_t step) nothrow
{
    return deviceMData[particle.dataSlot * numMovesteps + step];
}

size_t roundUpToNearest(size_t value, size_t interval)
{
    return (value - 1) + interval - ((value - 1) % interval);
}

void syncGravitySources()
{
    if(cpuFallbackMode)
        return;
        
    //Ensure there is enough space to fit all the gravity sources.
    while(gravitySources.length > deviceGData.length)
        deviceGData.allocate(max(64, deviceGData.length * 2), CL_MEM_WRITE_ONLY | CL_MEM_ALLOC_HOST_PTR);

    deviceGData.mmap(CL_MAP_WRITE);

    foreach(slot, source; gravitySources)
    {
        GravityData gdata;
        gdata.posx = source.pos.x;
        gdata.posy = source.pos.y;
        gdata.mass = source.mass;
        gdata.radius = source.radius;
        deviceGData[slot] = gdata;
        source.dataSlot = slot;
    }

    deviceGData.unmmap();
}
