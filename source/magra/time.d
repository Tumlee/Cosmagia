module magra.time;

public import core.time;
import core.thread;

long currentTimeMS()
{
    return (MonoTime.currTime - MonoTime.zero()).total!"msecs";
}

void delayMS(long ms)
{
    Thread.sleep(dur!"msecs"(ms));
}
