//This module handles transfering data from the host (CPU) to the device (GPU) as
//well as setting up and executing kernels that handle gravitational calculations
//for all of the particles.
module cosmagia.devicedata;

import magra.globals;
import cosmagia.clutil;
import cosmagia.actors.particle;
import cosmagia.actors.gravsource;

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

//Particle data arrays for the host and device.
private ParticleData[] hostPData;
private CLMemory!ParticleData devicePData;

//Particle movestep data, used as an output.
private ParticleMovestep[] hostMData;
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

void syncParticles()
{
    if(cpuFallbackMode)
        return;
    
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
            {
                hostPData.length = particleChunkSize;
            }
            else
            {
                hostPData.length = hostPData.length * 2;
            }
            
            hostMData.length = hostPData.length * numMovesteps;
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
        devicePData.allocate(hostPData.length, CL_MEM_WRITE_ONLY);

    if(deviceMData.length < hostMData.length)
        deviceMData.allocate(hostMData.length, CL_MEM_READ_ONLY);

    //Send it to the GPU.
    devicePData.write(hostPData[0 .. slot]);

    //Run the kernel. To avoid situations where we end up with a very
    //small groupsize, we pad the data to the nearest 256, rounding up.
    gravityKernel.setArgs(devicePData, deviceGData, cast(uint) gravitySources.length, deviceMData, numMovesteps);
    gravityKernel.enqueue([slot.roundUpToNearest(particleChunkSize)]);
    
    //Read movement data back to the CPU.
    deviceMData.read(hostMData[0 .. slot * numMovesteps]);
}

size_t roundUpToNearest(size_t value, size_t interval)
{
    return (value - 1) + interval - ((value - 1) % interval);
}

ref const(ParticleMovestep) getMovestep(const AParticle particle, size_t step)
{
    return hostMData[particle.dataSlot * numMovesteps + step];
}

void syncGravitySources()
{
    if(cpuFallbackMode)
        return;
        
    size_t slot = 0;

    foreach(source; gravitySources)
    {
        if(slot == hostGData.length)
        {
            if(hostGData.length == 0)
            {
                hostGData.length = 64;
            }
            else
            {
                hostGData.length = hostGData.length * 2;
            }
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
