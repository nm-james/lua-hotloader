const sql = require('mysql');
let con = sql.createConnection({
    host: 'localhost',
    user: 'root',
    port: 3307,
    password: 'NMJames2004'
});

function checkDatabases() {
    const createScheme = 'CREATE DATABASE IF NOT EXISTS dbPractice'
    

    const isGoodToGo = new Promise( (resolve, err) => {
        con.query(createScheme, (err, result) => {
            if (err) throw err;
            con = sql.createConnection({
                host: 'localhost',
                user: 'root',
                port: 3307,
                password: 'NMJames2004',
                database: 'dbPractice'
            });
            resolve()
        });
    } )

    return isGoodToGo
}

const dataTables = [ "users" ]
const dataTableValues = [
    `(
        id INT AUTO_INCREMENT,
        name VARCHAR(255),
        email VARCHAR(255),
        password VARCHAR(255),
        date VARCHAR(255),
        isNetworkAdmin BOOLEAN,
        PRIMARY KEY (id)
    )`
]

async function checkTables() {
    for (let i = 0; i < dataTables.length; i++) {
        const tableCheck = "CREATE TABLE IF NOT EXISTS " + dataTables[i] + dataTableValues[i]
        con.query(tableCheck, (err, result) => {
            if (err) throw err;
            console.log("dbPractice's " + dataTables[i] + " HAVE BEEN INITIALIZED!")
        });
    }

    const isGoodToGo = new Promise( (resolve, err) => {
        setTimeout(() => {
            console.log("dbPractice's TABLES HAVE BEEN INITIALIZED!")
            resolve()
        }, 1200)
    } )
    return isGoodToGo
}

async function getUsers() {
    let getUsers = new Promise( (resolve, err) => {
        con.query('SELECT * FROM users', (erre, row) => {
            if (erre) throw erre;
            const users = []
            for (var i of row) 
                users.push(i);   
            resolve(users)
        })
    })

    return getUsers
}

async function initializeSQL() {
    await checkDatabases();
    await checkTables();
    const userValue = new Promise( (resolve, err) => {
        setTimeout( async () => {
            const users = await getUsers()
            resolve(users)
        }, 1500)
    })

    return userValue
}


function addNewUser( newUser ) {
    console.log(newUser);
    const addUser = new Promise( (resolve, err) => {
        con.query('INSERT INTO users SET ?', newUser, (erre, res) => {
            if (erre) throw erre;
            resolve()
        })
    })
    addUser.then( () => {
        console.log("added user!")
    })
    return addUser
}

module.exports = {
    init: initializeSQL,
    user: {
        addUser: addNewUser,
        updateUsers: getUsers,
    },
    
}





// function that just prints the data that is wanted
function getData( name ) {
    let wantedName = name;

    // ask for the data
    con.query("SELECT * FROM users WHERE name = '" + wantedName + "'", function(error, data){
        if (error) throw error;
        console.log(data)
    });
}

let test = initializeSQL()
test.then(() => {
    getData("test'; SELECT * FROM 'users")
})