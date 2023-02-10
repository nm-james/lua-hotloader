if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config()
}

const express = require('express');
const app = express();
const router = express.Router();

const bcrypt = require('bcrypt');
const passport = require('passport');
const flash = require('express-flash');
const session = require("express-session");
const methodOverride = require('method-override');
const path = require('path');
const fs = require('fs');

const initializePassport = require("./passport-config");
const database = require("./database");
const { type } = require('os');
const e = require('express');
let users = []
const initMySql = async () => {
    const newUsers = await database.init()
    users = newUsers
}
initMySql()

const hasEmailAuth = async (email) => {
    for (var x in users)
        if (users[x].email == email) {
            return users[x]
        }
}

const hasIdAuth = async (id) => {
    for (var x in users)
        if (users[x].id == id) {
            return users[x]
        }
}

initializePassport( 
    passport, 
    email => users.find(user => user.email === email),
    id => users.find(user => user.id === id) 
);


app.set('view-engine', 'ejs');
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(flash());
app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false
}));
app.use(express.static(__dirname + '/public'));
app.use(passport.initialize());
app.use(passport.session());
app.use(methodOverride('_method'));
app.use('/css', express.static(path.join(__dirname, 'node_modules/bootstrap/dist/css')))
app.use('/js', express.static(path.join(__dirname, 'node_modules/bootstrap/dist/js')))
app.use('/js', express.static(path.join(__dirname, 'node_modules/jquery/dist')))

const gamemodePath = path.join(__dirname, 'data', 'rts');

const countObject = ( object ) => {
    return Object.keys(object).length
}

function isTypeOfEntity( dirPath, file, type )
{
    let folderStructure = dirPath.split('\\')
    let isEntities = dirPath.search(type)

    if (isEntities == -1 || folderStructure[0] === '/'+type) {
        return false
    }
    else
    {
        if (folderStructure[folderStructure.length-1].search('/') > -1) {
            let newFolder = folderStructure[folderStructure.length-1].split('/')
            let entityClass = newFolder[1].split('.lua')[0]
            let id = 2
            if (type === 'entities') {
                id = 1
            }
            if (newFolder[newFolder.length - 1].search('.lua') > -1) {
                return [true, [entityClass, id], false]
            }
            else
            {
                return [true, [entityClass, id], true]
            }
        }
    }
    return false
}

var waitingDirectories = []
const getAllFiles = function(originalPath, dirPath, arrayOfFiles, shouldRemoveFirstIndex) {
    dirPath = dirPath || ''
    if (dirPath === '')
        files = fs.readdirSync(originalPath)
    else
        files = fs.readdirSync(originalPath + '/' + dirPath)
    arrayOfFiles = arrayOfFiles || {}

    if (shouldRemoveFirstIndex)
        waitingDirectories.shift()


    files.forEach(function(file) {
        let combinedDirString = dirPath + "/" + file
        let combinedDir = fs.statSync(originalPath + "/" + combinedDirString)
        let isEntity = isTypeOfEntity(combinedDirString, file, 'entities')
        let isSWEP = isTypeOfEntity(combinedDirString, file, 'weapons')

        if (isEntity[0] === true) {
            if (isEntity[2] === true) {
                var newFiles = fs.readdirSync(originalPath + '/' + dirPath + '/' + file)
                newFiles.forEach((f) => {
                    arrayOfFiles[countObject(arrayOfFiles)] = [path.join(dirPath, file, f), isEntity[1][0], isEntity[1][1] ]
                })

            } else {
                arrayOfFiles[countObject(arrayOfFiles)] = [path.join(dirPath, file), isEntity[1][0], isEntity[1][1]]
            }
        }
        else if (isSWEP[0] === true)
        {
            if (isSWEP[2] === true) {
                var newFiles = fs.readdirSync(originalPath + '/' + dirPath + '/' + file)
                newFiles.forEach((f) => {
                    arrayOfFiles[countObject(arrayOfFiles)] = [path.join(dirPath, file, f), isSWEP[1][0], isSWEP[1][1] ]
                })

            } else {
                arrayOfFiles[countObject(arrayOfFiles)] = [path.join(dirPath, file), isSWEP[1][0], isSWEP[1][1]]
            }
        }
        else
        {
            if (combinedDir.isDirectory()) {
                waitingDirectories.push(path.join(dirPath, file))
            } else {
                arrayOfFiles[countObject(arrayOfFiles)] = [path.join(dirPath, file), "", -1]
            }
        }
        
    })

    if (waitingDirectories.length > 0)
        return getAllFiles(originalPath, waitingDirectories[0], arrayOfFiles, true)
    return arrayOfFiles
}

function getFilesizeInBytes(filename) {
    var stats = fs.statSync(filename);
    var fileSizeInBytes = stats.size;
    return fileSizeInBytes;
}

var fileCached = "";
var cachedFileSize = {};
app.get('/', function(req, res, next)
{
    var key = req.query.productKey || ''
    if (key === '') {
        res.json( '{"isRunning": true}' )
        return
    }

    // check if key is valid

    const files = getAllFiles( gamemodePath )
    for (x in files)
    {
        let file = files[x][0]
        let size = getFilesizeInBytes(path.join(gamemodePath, file))
        cachedFileSize[file] = size
    }
    const fileConverted = JSON.stringify(files)
    fileCached = fileConverted
    res.json( fileConverted )
});
 
var options = {
    root: path.join(__dirname)
};

app.get('/download', function(req, res, next)
{
    var fileName = req.query.file
    fs.readFile(path.join(gamemodePath, fileName), (err, data) => {
        let json = {}
        json.code = data.toString()
        json.file = fileName

        res.send( json )
    })
});

app.get('/shouldUpdate', function(req, res)
{
    const files = getAllFiles( gamemodePath )
    const fileConverted = JSON.stringify(files)

    if (fileCached === fileConverted)
    {
        const convertedCache = JSON.parse(fileCached)
        let fateDecider = false
        for (x in files)
        {
            let file = files[x][0]
            let size = getFilesizeInBytes(path.join(gamemodePath, file))
            let cachedSize = cachedFileSize[file]

            if (size !== cachedSize)
                fateDecider = true
        }
        res.send( '{"ShouldUpdate": ' + fateDecider + '}' )
    }
    else
    {
        res.send( '{"ShouldUpdate": true}' )
        fileCached = files
    }
        
})

app.listen(3000);

