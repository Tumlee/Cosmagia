module magra.glutil;

import std.exception;
import std.string;
import std.conv;
import std.stdio;
import derelict.opengl;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

//FIXME: All of these objects should have cleanup in their destructors.
class VAO
{
    struct Attribute
    {
        this(string n, int e, GLuint i)
        {
            name = n;
            numElements = e;
            index = i;
        }

        string name;
        int numElements;
        GLuint index;
    }

    Attribute[] attributes;
    
    GLuint id = 0;

    //Keeps track of the currently bound VAO, to prevent unnecessary binding.
    private static VAO currentlyBound = null;

    this()
    {
        glGenVertexArrays(1, &id);
    }

    void bind()
    {
        if(currentlyBound is this)
            return;
        
        glBindVertexArray(id);
        currentlyBound = this;
    }

    void addAttribute(string name, GLuint index, int size, ShaderProgram program)
    {
        attributes ~= Attribute(name, size, index);
        program.bindAttribute(name, index);
    }

    int totalAttributeLength()
    {
        int total = 0;

        foreach(attribute; attributes)
            total += attribute.numElements;

        return total;
    }

    void enableAttributes(ShaderProgram program, VBO vbo)
    {
        bind();
        vbo.bind();
        
        //Find the total size of all the attributes.
        size_t totalElements = 0;

        foreach(attribute; attributes)
            totalElements += attribute.numElements;

        size_t offset = 0;

        foreach(attribute; attributes)
        {
            GLuint attrib = attribute.index;

            if(attrib == -1)
            {
                writefln("Attribute %s is -1!", attribute.name);
                throw new Exception("Bad attribute");
            }

            glVertexAttribPointer(attrib, attribute.numElements, GL_FLOAT, false,
                                    cast(int) (totalElements * float.sizeof), cast(void*) (float.sizeof * offset));
                                    
            offset += attribute.numElements;
            glEnableVertexAttribArray(attrib);
        }
    }

    ~this()
    {
        glDeleteVertexArrays(1, &id);
    }
}

class VBO
{
    //Internal ID actually used by OpenGL
    GLuint id = 0;

    //Keeps track of the currently bound VBO, to prevent unnecessary binding.
    private static VBO currentlyBound = null;

    VAO owner;
    
    this(VAO newOwner)
    {
        assert(newOwner !is null);
        
        owner = newOwner;
        glGenBuffers(1, &id);
    }

    void bind()
    {
        owner.bind();
        
        if(currentlyBound is this)
            return;
        
        glBindBuffer(GL_ARRAY_BUFFER, id);
        currentlyBound = this;
    }

    void buffer(const float[] vertices, int drawMode)
    {
        bind();
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, cast(void*) vertices, drawMode);
    }
}

class EBO
{
    GLuint id = 0;
    private static EBO currentlyBound = null;
    VAO owner;

    this(VAO newOwner)
    {
        assert(newOwner !is null);

        owner = newOwner;
        glGenBuffers(1, &id);
    }

    void bind()
    {
        owner.bind();

        if(currentlyBound is this)
            return;

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
        currentlyBound = this;
    }

    void buffer(const uint[] data, int drawMode)
    {
        bind();
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, data.length * uint.sizeof, cast(void*) data, drawMode);
    }

    void draw(int numElements)
    {
        bind();
        glDrawElements(GL_TRIANGLES, numElements, GL_UNSIGNED_INT, null);
    }
}

class ShaderProgram
{
    GLuint id = 0;
    private char[] compileLog;
    private char[] linkLog;

    private static ShaderProgram currentlyUsed = null;

    this()
    {
        id = glCreateProgram();
    }

    bool attach(string code, GLenum shaderType)
    {
        auto shader = compileShader(code, shaderType);
        
        if(!shader) //Compilation failed?
            return false;

        glAttachShader(id, shader);
        return true;
    }

    GLuint compileShader(string code, GLenum shaderType)
    {
        auto shader = glCreateShader(shaderType);
        auto cCode = code.toStringz;

        glShaderSource(shader, 1, &cCode, null);
        glCompileShader(shader);
        
        GLint result;
        GLint logLength;
        
        glGetShaderiv(shader, GL_COMPILE_STATUS, &result);

        if(result == GL_FALSE)     //Failed to compile.
        {       
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
            compileLog.length = logLength;
            glGetShaderInfoLog(shader, logLength, null, compileLog.ptr);
            return 0;
        }

        return shader;
    }


    bool link()
    {
        GLint result;
        GLint logLength;
        
        glLinkProgram(id);

        glGetProgramiv(id, GL_LINK_STATUS, &result);
        
        if(result == GL_FALSE)     //Failed to compile.
        {       
            glGetProgramiv(id, GL_INFO_LOG_LENGTH, &logLength);
            linkLog.length = logLength;
            glGetProgramInfoLog(id, logLength, null, linkLog.ptr);

            return false;
        }

        return true;
    }
    
    string getCompileLog()
    {
        return compileLog.idup;
    }

    string getLinkLog()
    {
        return linkLog.idup;
    }

    void use()
    {
        if(currentlyUsed is this)
            return;

        currentlyUsed = this;
        
        glUseProgram(id);
    }

    void bindAttribute(string name, GLuint index)
    {
        glBindAttribLocation(id, index, name.toStringz);
    }

    //Functions that deal with the setting of uniforms.
    private GLuint[string] uniformLocationCache;

    GLuint getUniformLocation(string name)
    {
        use();

        if(name in uniformLocationCache)
            return uniformLocationCache[name];

        auto result = glGetUniformLocation(id, name.toStringz);

        //Note, this will cache the result even if the call to
        //glGetUniformLocation() fails. This may or may not be optimal.
        uniformLocationCache[name] = result;
        return result;
    }

    //Functions that set the values of uniforms.
    //Not all of the functions will be covered because there are a lot of them.
    //This should be most of the common ones, though.
    void setUniform(string name, int i1)
    {
        auto loc = getUniformLocation(name);

        if(loc != -1)
            glUniform1i(loc, i1);
    }

    void setUniform(string name, float f1)
    {
        auto loc = getUniformLocation(name);

        if(loc != -1)
            glUniform1f(loc, f1);
    }

    void setUniform(string name, float f1, float f2)
    {
        auto loc = getUniformLocation(name);

        if(loc != -1)
            glUniform2f(loc, f1, f2);
    }

    void setUniform(string name, float f1, float f2, float f3)
    {
        auto loc = getUniformLocation(name);

        if(loc != -1)
            glUniform3f(loc, f1, f2, f3);
    }

    void setUniform(string name, float f1, float f2, float f3, float f4)
    {
        auto loc = getUniformLocation(name);

        if(loc != -1)
            glUniform4f(loc, f1, f2, f3, f4);
    }
}

class Texture2D
{
    uint id = 0;
    
    //Keeps track of the currently bound Texture2D, to prevent unnecessary binding.
    private static Texture2D currentlyBound = null;

    private GLenum textureUnit;

    this(int newTextureUnit)
    {
        textureUnit = GL_TEXTURE0 + newTextureUnit;
        
        glActiveTexture(textureUnit);
        glGenTextures(1, &id);

        //Set sane defaults for wrapping and filtering.
        setWrapping(GL_REPEAT, GL_REPEAT);
        setFiltering(GL_LINEAR, GL_LINEAR);
    }

    void bind()
    {
        if(currentlyBound is this)
            return;

        glActiveTexture(textureUnit);
        glBindTexture(GL_TEXTURE_2D, id);
        currentlyBound = this;
    }   

    void setWrapping(GLenum sWrap, GLenum tWrap)
    {
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, sWrap);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, tWrap); 
    }

    void setFiltering(GLenum magFilter, GLenum minFilter)
    {
        bind();

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
    }

    void setBorderColor(float r, float g, float b, float a)
    {
        float[4] color = [r, g, b, a];
        bind();
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, color.ptr);
    }
    
    //NOTE: This function pulls heavily from r3dux.org/tag/ilutglloadimage
    bool load(string fileName)
    {
        uint image;
        ilGenImages(1, &image);
        ilBindImage(image);
        
        auto success = ilLoadImage(fileName.toStringz);

        if(success)
        {
            ILinfo imageInfo;
            iluGetImageInfo(&imageInfo);

            if(imageInfo.Origin == IL_ORIGIN_UPPER_LEFT)
                iluFlipImage();
        
            if(!ilConvertImage(IL_RGBA, IL_FLOAT))
                throw new Exception("Image conversion failed, reason: " ~ ilGetError().to!string);

            bind();

            //Generate the texture.
            //FIXME: What if there is already a texture in place here?
            auto imageFormat = ilGetInteger(IL_IMAGE_FORMAT);
            auto imageWidth = ilGetInteger(IL_IMAGE_WIDTH);
            auto imageHeight = ilGetInteger(IL_IMAGE_HEIGHT);

            glTexImage2D(GL_TEXTURE_2D, 0, imageFormat, imageWidth, imageHeight, 0, imageFormat, GL_FLOAT, ilGetData());
        }
        else
        {
            throw new Exception("Image loading failed, reason: " ~ ilGetError().to!string);
        }

        ilDeleteImages(1, &image);
        return true;
    }

    bool generate(float[] data, int w, int h, GLenum format)
    {
        bind();
        glTexImage2D(GL_TEXTURE_2D, 0, format, w, h, 0, format, GL_FLOAT, cast(void*) data);

        return true;
    }
}

//GLenum minSeverity = DEBUG_SEVERITY_MEDIUM;

extern(C) void errorCallback(   GLenum source,
                                GLenum type,
                                GLuint id,
                                GLenum severity,
                                GLsizei length,
                                const char* message,
                                const void* userParam) nothrow
{
    if(severity == 33387)
        return;

    try
    {
        writeln(severity, ": ", message.to!string);
    }
    catch(Exception)
    {
        return;
    }
}
