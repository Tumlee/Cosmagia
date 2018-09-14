module magra.renderer;

import std.file;
import std.format;
import std.algorithm;
import std.math;
public import derelict.opengl;
import derelict.glfw3.glfw3;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;
import magra.glutil;
import magra.callbacks;
//import midirouter.fonts;

int screenwidth, screenheight;
GLFWwindow* window;

void initGLContext(bool fullscreen, int width, int height)
{
    //Load all the relevant libraries with Derelict.
    DerelictGL3.load();
    DerelictGLFW3.load();
    DerelictIL.load();
    DerelictILU.load();

    //Initialize GLFW.
    if(glfwInit() == false)
        throw new Exception("Failed to initialize GLFW");

    glfwSetErrorCallback(&glfwErrorCallback);

    glfwWindowHint(GLFW_SAMPLES, 1);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, true);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    //Create the GLFW window.
    if(fullscreen)
    {
        setFullscreenVideoMode();
    }
    else
    {
        setWindowedVideoMode(width, height);
    }
    
    if(window is null)
        throw new Exception("Failed to create a GLFW window");

    //Finalize loading of all rendering-related libraries.
    glfwMakeContextCurrent(window);
    DerelictGL3.reload();
    ilInit();
    iluInit();

    //Enable debugging output for OpenGL
    debug glEnable(GL_DEBUG_OUTPUT);
    debug glDebugMessageCallback(&errorCallback, null);

    //Enable basic blending.
    glEnable(GL_BLEND);
}

//Finds the best video mode to use for fullscreen and uses that.
void setFullscreenVideoMode()
{    
    int numModes;
    const GLFWvidmode* modes = glfwGetVideoModes(glfwGetPrimaryMonitor(), &numModes);
    GLFWvidmode bestMode = modes[0];

    foreach(i; 0 .. numModes)
    {
        auto mode = modes[i];

        if(mode.width * mode.height > bestMode.width * bestMode.height)
            bestMode = mode;
    }

    screenwidth = bestMode.width;
    screenheight = bestMode.height;
    window = glfwCreateWindow(screenwidth, screenheight, "Cosmagia", glfwGetPrimaryMonitor(), null);    
}

void setWindowedVideoMode(int w, int h)
{
    screenwidth = w;
    screenheight = h;

    window = glfwCreateWindow(screenwidth, screenheight, "Cosmagia", null, null);
}

class QuadBuffer
{
    VAO vao;
    VBO vbo;
    EBO ebo;
    Texture2D[] textures;
    ShaderProgram program;
    
    GLuint[] eboData;
    float[] vboData;
    size_t currentLength = 0;
    size_t currentElement = 0;

    //Information about the blending mode that should be used while drawing.
    GLenum sBlendMode = GL_SRC_ALPHA;
  	GLenum dBlendMode = GL_ONE_MINUS_SRC_ALPHA;

    this()
    {
        vao = new VAO;
        vbo = new VBO(vao);
        ebo = new EBO(vao);
        program = new ShaderProgram;
    }

    void expandCapacity(size_t extra)
    {        
        auto oldEboLength = eboData.length;
        
        eboData.length = eboData.length + (extra * 6);
        vboData.length = vboData.length + (extra * quadLength);
        
        //OPTIMIZE: I wanted to have this carry over the EBO pattern from
        //before the capacity is expanded, but for some reason eboData is getting
        //trashed somewhere outside of this function.
        foreach(i; 0 .. eboData.length)
        {
            enum uint[] quadPattern = [0, 1, 2, 0, 2, 3];
            eboData[i] = cast(uint) (quadPattern[i % $] + (i / quadPattern.length) * 4);
        }

        currentLength += extra;

        //Might as well buffer EBO data now.
        ebo.buffer(eboData, GL_STATIC_DRAW);
    }

    void addAttribute(string name, GLuint index, int size)
    {
        vao.addAttribute(name, index, size, program);
    }

    void addElement(const float[] data)
    {
        if(currentElement == currentLength)
        {
            if(currentLength == 0)
                expandCapacity(128);
                
            else
                expandCapacity(currentLength);
        }

        assert(data.length == quadLength);

        auto vboTarget = vboData[currentElement * quadLength.. $];

        foreach(i; 0 .. data.length)
            vboTarget[i] = data[i];

        currentElement++;
    }

    void setupShader(string vFile, string fFile)
    {
        string vCode = readText(vFile);
        string fCode = readText(fFile);

        if(!program.attach(vCode, GL_VERTEX_SHADER))
            throw new Exception(format("VERTEX SHADER COMPILE FAILED\n%s", program.getCompileLog()));

        if(!program.attach(fCode, GL_FRAGMENT_SHADER))
            throw new Exception(format("FRAGMENT SHADER COMPILE FAILED\n%s", program.getCompileLog()));

        if(!program.link())
            throw new Exception(format("GLSL LINKING FAILED\n%s", program.getLinkLog()));
        
        program.use();
        vao.enableAttributes(program, vbo);
    }

    void draw()
    {
        //Set up the chosen blending mode.
        glBlendFunc(sBlendMode, dBlendMode);
 
        foreach(tex; textures)
            tex.bind();
            
        program.use();
        
        vbo.buffer(vboData[0 .. currentElement * quadLength], GL_STATIC_DRAW);
        ebo.draw(cast(int) (currentElement * 6));
    }

    void addTexture(Texture2D tex)
    {
        textures ~= tex;
    }

    void setBlendMode(GLenum sMode, GLenum dMode)
    {
        sBlendMode = sMode;
        dBlendMode = dMode;
    }

    //The size of four vertexes.
    size_t quadLength()
    {
        return vao.totalAttributeLength * 4;
    }

    void clear()
    {
        currentElement = 0;
    }
}

class RenderingQueue
{
    struct Layer
    {
        QuadBuffer qbuf;
        int layerID;
    }
    
    private Layer[] layers;

    void registerLayer(QuadBuffer qbuf, int layerID)
    {
        //No two layers may share a layerID.
        if(layers.canFind!(layer => layer.layerID == layerID))
            throw new Exception("Tried to register a Layer with an already-existing layerID");

        Layer newLayer;
        newLayer.qbuf = qbuf;
        newLayer.layerID = layerID;
        layers ~= newLayer;

        //Make sure the layers are sorted so that they are drawn in order.
        layers.sort!((a,b) => a.layerID < b.layerID);
    }

    void drawLayers()
    {
        foreach(layer; layers)
            layer.qbuf.draw();
    }

    void clearLayers()
    {
        foreach(layer; layers)
            layer.qbuf.clear();
    }
}


/*class TextRenderer
{
    QuadBuffer qbuf;
    Face face;

    this()
    {
        face = new Face;
        face.loadTTF("saucer.ttf", 128);

        qbuf = new QuadBuffer;   
        qbuf.addAttribute("position", 2, 2);
        qbuf.addAttribute("texCoord", 3, 2);
        qbuf.addAttribute("textColor", 4, 4);
        qbuf.setupShader("textvshader.glsl", "textfshader.glsl");
        qbuf.program.setUniform("fontmap", 0);
        qbuf.setTexture(face.fontmap);
    }

    //Queues text to be drawn on the screen. If the text is above a certain scaling level,
    //then it will be shrunk down until it fits.
    void queueScaledText(string text, float x, float y, float scale, float maxLength, RGBA c1, RGBA c2)
    {
        //In order to make sure the text is drawn consistently across screen resolutions,
        //we will adjust the incoming scale based on screenwidth.
        //This is based on a "baseline" horizontal resolution of 1024
        float actualScale = scale * screenwidth / 1024.0;
        float expectedLength = actualScale * face.getTextScreenLength(text);

        if(expectedLength > maxLength)
        {
            //Find an 'actualScale' that satisfied the equation
            //face.getTextScreenLength(text) * actualScale = maxLength
            actualScale = maxLength / face.getTextScreenLength(text);
        }

        foreach(c; text)
        {
            auto gCoord = face.getGlyphCoord(c);

            if(gCoord.drawable)
            {
                float cx1 = gCoord.cx1;
                float cy1 = gCoord.cy1;
                float cx2 = gCoord.cx2;
                float cy2 = gCoord.cy2;

                float sx1 = x + gCoord.ox * actualScale;
                float sy1 = y + (gCoord.oy - gCoord.sh) * actualScale;
                float sx2 = x + (gCoord.ox + gCoord.sw) * actualScale;
                float sy2 = y + gCoord.oy * actualScale;
                
                qbuf.addElement([   sx1, sy1, cx1, cy2, c1.r, c1.g, c1.b, c1.a,
                                    sx2, sy1, cx2, cy2, c1.r, c1.g, c1.b, c1.a,
                                    sx2, sy2, cx2, cy1, c2.r, c2.g, c2.b, c2.a,
                                    sx1, sy2, cx1, cy1, c2.r, c2.g, c2.b, c2.a]);
            }

            x += gCoord.sa * actualScale;
        }
    }

    void draw()
    {
        qbuf.draw();
    }
}*/

struct RGBA
{
    float r = 0;
    float g = 0;
    float b = 0;
    float a = 1;

    this(float rr, float gg, float bb, float aa = 1)
    {
        r = rr;
        g = gg;
        b = bb;
        a = aa;
    }
}
