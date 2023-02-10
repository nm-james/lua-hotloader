const LocalStrategy = require('passport-local').Strategy
const bcrypt = require('bcrypt')

function initialize( passport, getUserByEmail, getUserById ) {
    const authenticateUser = async (email, password, finished) => {
        const user = await getUserByEmail(email)
        if (user == null) {
            return finished(null, false, { message: 'No user with that email has been found.' })
        }
        try {
            if (await bcrypt.compare(password, user.password)) {
                return finished(null, user)
            } else {
                return finished(null, false, { message: 'The email or password is incorrect'})
            }
        } catch (e) {
            return finished(e)
        }
    }

    passport.use(new LocalStrategy({ usernameField: 'email' }, authenticateUser))
    passport.serializeUser((user, finished) => finished(null, user.id))
    passport.deserializeUser((id, finished) => {
        return finished(null, getUserById(id))
    })

}

module.exports = initialize