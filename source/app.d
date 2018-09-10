import magra.base;
import xypoint;
import std.conv;
import std.math;
import lightwave.gravsource, lightwave.particle;
import lightwave.resources;
import lightwave.camera;
import derelict.glfw3;

float backgroundTime = 0.0;

void drawBG()
{
    int vertexLength = starQB.vao.totalAttributeLength;
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
        float vx = (x * 2 - 1);
        float vy = (y * 2 - 1);
        bufferData[vStart .. vStart + vertexLength] = [vx, vy, x, y, 1.0, 1.0, 1.0, 1.0];
        vStart += vertexLength;
    }

    starQB.addElement(bufferData);
}

void myTicker()
{
    backgroundTime += 1.0 / 60.0;

    //backLayer.add(new BGDrawer(backgroundTime));
    drawBG();

    changeZoomLevel(XYPoint(mouse.x, mouse.y), pow(1.1, -mouse.wheely));
    
    if(keyboard[GLFW_KEY_ESCAPE].isFresh)
        gameLoop.quitting = true;

    if(mouse[GLFW_MOUSE_BUTTON_LEFT].isFresh)
    {
        auto worldCoordinate = screenToWorldCoordinate(XYPoint(mouse.x, mouse.y));
        actors.spawn(new AGravSource(worldCoordinate.x, worldCoordinate.y));
        updateGravitySources();
    }

    if(keyboard[GLFW_KEY_R].isDown)
    {
        import std.random;
        auto rpos = XYPoint(uniform(-512, 512), uniform(-512, 512));
        auto rvel = XYPoint(uniform(-4, 4), uniform(-4, 4));

        actors.spawn(new AParticle(rpos, rvel));
    }

    if(keyboard[GLFW_KEY_W].isFresh)
    {
        import std.random;

        for(float r = 0; r < 3.141 * 2; r += .01)
        {
            import std.math;
            float x = cos(r);
            float y = sin(r);
            actors.spawn(new AParticle(XYPoint(x, y) * 256, XYPoint(0,0)));
        }
    }
        
    if(keyboard[GLFW_KEY_DELETE].isFresh)
    {
        actors.clear!()();
        updateGravitySources();
    }
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
    initCamera();
    
    gameLoop.tickRate = 60.0;
    gameLoop.preTick = &myTicker;
    gameLoop.run();
}
