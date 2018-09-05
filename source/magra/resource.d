module magra.resource;

import magra.globals;
import magra.glutil;

import std.string;
import std.exception;
import std.file;
import std.path;

string getResourcesPath()
{
    static string generatedPath = null;

    if(generatedPath is null)
        generatedPath = thisExePath.dirName ~ "/resources/";

    return generatedPath;
}
    

Texture2D loadTexture(string filename, int textureUnit)
{
    Texture2D newTex = new Texture2D(textureUnit);

    string absolutePath = getResourcesPath ~ filename;
    
    if(!newTex.load(absolutePath))
        throw new Exception("Failed to load texture from " ~ absolutePath);
    
    return newTex;
}

//FIXME-GLFW: This is to be handled by OpenAL later on.
/*Mix_Chunk* loadSound(const char[] filename)
{
    return Mix_LoadWAV(("resources/" ~ filename).toStringz);
}*/

/*Mix_Music* loadMusic(const char[] filename)
{
    return Mix_LoadMUS(("resources/" ~ filename).toStringz);
}*/
