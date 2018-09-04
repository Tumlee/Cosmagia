import magra.base;
import xypoint;
import std.conv;
import lightwave.gravsource, lightwave.particle;
import lightwave.resources;

float backgroundTime = 0.0;

void myTicker()
{
    backgroundTime += 1.0 / 60.0;

    /*backLayer.add(new BGDrawer(backgroundTime));
    
    if(keyboard[SDLK_ESCAPE].isFresh)
        gameLoop.quitting = true;

    if(mouse[1].isFresh)
    {
        actors.spawn(new AGravSource(mouse.x, mouse.y));
        updateGravitySources();
    }

    if(keyboard[SDLK_r].isDown)
    {
        import std.random;
        auto rpos = XYPoint(uniform(0, 1366), uniform(0, 768));
        auto rvel = XYPoint(uniform(-4, 4), uniform(-4, 4));

        actors.spawn(new AParticle(rpos, rvel));
    }

    if(keyboard[SDLK_w].isFresh)
    {
        import std.random;

        foreach(x; 0 .. (1366/4))
        {
            actors.spawn(new AParticle(XYPoint(x * 4, 0), XYPoint(0,0)));
            actors.spawn(new AParticle(XYPoint(x * 4, 768), XYPoint(0,0)));
        }
        
        foreach(y; 0 .. (768/4))
        {
            actors.spawn(new AParticle(XYPoint(0, y * 4), XYPoint(0,0)));
            actors.spawn(new AParticle(XYPoint(1366, y * 4), XYPoint(0,0)));
        }        
    }
        
    if(keyboard[SDLK_DELETE].isFresh)
    {
        actors.clear!()();
        updateGravitySources();
    }*/
}

void main(string[] args)
{
    auto initSettings = new InitSettings;
    
    initSettings.windowTitle = "LightWave";
    initSettings.screenWidth = 1366;
    initSettings.screenHeight = 768;
    initSettings.fullscreen = true;
    initSettings.initializeEngine();

    loadResources();
    
    gameLoop.tickRate = 60.0;
    gameLoop.preTick = &myTicker;
    gameLoop.run();
}
