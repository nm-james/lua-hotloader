#include "gmod-headers/include/GarrysMod/Lua/Interface.h"
#include "http-request/include/HTTPRequest.hpp"
#include "json/single_include/nlohmann/json.hpp"
#include <string>
#include <map>
#include <typeinfo>
#include <filesystem>
#include <iostream>
#include <vector>

#pragma comment(lib, "Ws2_32.lib")

using namespace GarrysMod::Lua;
using namespace std;
using std::filesystem::directory_iterator;
using json = nlohmann::json;
json fileParsed;

json getFileNames(const string keyIdentifier)
{
    http::Request fileNamesRequest{ "http://localhost:3000/?productKey="+keyIdentifier };
    const string body = "";
    const auto fileNames = fileNamesRequest.send("GET");
    string fileNamesJSON = string{fileNames.body.begin(), fileNames.body.end()};
    json parsedJSON = json::parse(fileNamesJSON);

    return parsedJSON;
}

string getFileCode(const string fileName)
{
    http::Request downloadFile{ "http://localhost:3000/download?file="+fileName};
    const string body = "{}";
    const auto response = downloadFile.send("GET", body, {
        {"Content-Type", "application/json"}
        });
    string result = { response.body.begin(), response.body.end() };
    return result;
}

LUA_FUNCTION(initiaizeFiles)
{
    string keyIdentifier = LUA->CheckString(1);
    json fileNames = getFileNames(keyIdentifier);
    for (auto it = fileNames.begin(); it != fileNames.end(); ++it)
    {
        auto fileDataThinog = it.value();
        string variableName = "falcon_temporary";

         for (auto i = fileDataThinog.begin(); i != fileDataThinog.end(); ++i)
         {
             auto fileData = i.value();
             string fileDataString = fileData;
             fileParsed = json::parse(fileDataString);

             for (auto x = fileParsed.begin(); x != fileParsed.end(); ++x) {
                 auto fileDataAgain = x.value();
                 string fileName = fileDataAgain[0];
                 string entityClass = fileDataAgain[1];
                 double entityID = fileDataAgain[2];


                 string fileContents = getFileCode(fileName);
                 auto fileContentsObject = json::parse(fileContents);

                 string finalCode = "";
                 string filePath = fileContentsObject["file"];
                 if (filePath.find("cl_") != string::npos || filePath.find("cl_init") != string::npos) { continue; }

                 string code = fileContentsObject["code"];
                 if (entityClass != "") {
                     if (entityID == 1.0) {
                         finalCode = "local ENT = scripted_ents.Get( '" + entityClass + "' ) or {} ENT.Base = ENT.Base or 'base_gmodentity' ENT.Type = ENT.Type or 'anim'   " + code + "  scripted_ents.Register( ENT, '" + entityClass + "' )";
                     }
                     else
                     {
                         finalCode = "local SWEP = weapons.Get( '" + entityClass + "' ) or {} SWEP.Base = SWEP.Base or 'weapon_base'   " + code + "  weapons.Register(SWEP, '" + entityClass + "')";
                     }
                 }
                 else
                 {
                     finalCode = code;
                 }

                 LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
                 LUA->GetField(-1, "print");
                 LUA->PushString("Running SERVER file!:");
                 LUA->PushString(filePath.c_str());
                 LUA->Call(2, 0);

                 LUA->GetField(-1, "CompileString");

                 LUA->PushString(finalCode.c_str());
                 LUA->PushString(filePath.c_str());
                 LUA->PushBool(true);
                 LUA->Call(3, 1);

                 LUA->PushString(variableName.c_str());
                 LUA->Push(-2);
                 LUA->SetTable(-4);
                 LUA->Pop();


                 LUA->GetField(-1, variableName.c_str());
                 LUA->Call(0, 0);
                 LUA->Pop();
             }

         }

          LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
          LUA->PushString(variableName.c_str());
          LUA->PushNil();
          LUA->SetTable(-3);
          LUA->Pop();
    }

    return 0;
}

LUA_FUNCTION(getClientFiles)
{
    int runningInt = 0;
    int jsonSize = fileParsed.size();
    json jsonObject;

    for (auto i = fileParsed.begin(); i != fileParsed.end(); ++i)
    {
        auto fileDataAgain = i.value();
        string fileName = fileDataAgain[0];
        string entityClass = fileDataAgain[1];
        double entityType = fileDataAgain[2];

        string fileContents = getFileCode(fileName);
        json fileContentsObject = json::parse(fileContents);
        string filePath = fileContentsObject["file"];

        if (filePath.find("sv_") != string::npos || filePath.find("init") != string::npos && filePath.find("cl_init") == string::npos) { continue; }
        string code = fileContentsObject["code"];


        json dataObject;
        dataObject["Code"] = code;
        dataObject["Path"] = filePath;
        dataObject["Entity"] = entityClass;
        dataObject["EntityID"] = entityType;




        jsonObject[runningInt] = dataObject;
        runningInt += 1;
    }


    string runningJSONClientFiles = jsonObject.dump();
    
    LUA->PushString(runningJSONClientFiles.c_str());
    return 1;
}

GMOD_MODULE_OPEN()
{
    // Defining scope
    LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
    LUA->PushString("initiaizeFiles");
    LUA->PushCFunction(initiaizeFiles);
    LUA->SetTable(-3);
    LUA->Pop();

    LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
    LUA->PushString("getClientFiles");
    LUA->PushCFunction(getClientFiles);
    LUA->SetTable(-3);
    LUA->Pop();

    return 0;
}

GMOD_MODULE_CLOSE()
{
    return 0;
}

int main()
{

    return 1;
}

