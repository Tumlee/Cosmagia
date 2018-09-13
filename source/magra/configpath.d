module magra.configpath;

import std.stdio;
import std.path;
import std.file;
import std.exception;
import std.array;
import std.string;
import core.stdc.stdlib;

private enum string appName = "lightwave";

//Ensure that the configuration directory exists, and that the mandatory
//files exist. If they don't, copy them from the bin/defaultconfig folder.
void createConfigDirs()
{
    string configPath = getConfigPath();

    //Create each required directory and throw an exception is there is an error.
    //Note that mkdirRecurse does nothing if the directory already exists, so
    //we don't have to worry about checking if the directory is already there.
    if(collectException!FileException(mkdirRecurse(configPath)))
        throw new Exception("Error creating required configuration directory " ~ configPath);
}

private void copyRequiredFile(string filename)
{
    string fromPath = chainPath(thisExePath.dirName, "defaultconfig", filename).array;
    string toPath = chainPath(getConfigPath(), filename).array;
    
    if(!exists(toPath))
    {
        if(collectException!FileException(copy(fromPath, toPath)))
            throw new Exception("Failed to copy required file to configuration directory" ~ filename);
    }
}

//Get the path to where all configuration files are saved.
string getConfigPath()
{
    version(linux)
        return expandTilde("~/.config/" ~ appName);
        
    else version(Windows)
        return getenv("APPDATA").fromStringz.idup ~ "/" ~ appName;
        
    else version(OSX)
        return expandTilde("~/Library/Application Support/" ~ appName);

    else
        static assert(0, "This operating system is currently not supported");
}

string inConfigPath(string filename)
{
    return chainPath(getConfigPath(), filename).array;
}
