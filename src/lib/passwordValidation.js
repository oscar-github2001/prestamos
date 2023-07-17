const bcrypt = require('bcryptjs');

const passwordValidation = {};

passwordValidation.encryptPassword = async (password) => {
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(password, salt);
    return hash;
}

passwordValidation.comparePassword = async (password, sqlPassword) => {
    try {
        return await bcrypt.compare(password, sqlPassword);
    } catch (error) {
        console.log(error);
    }
}

module.exports = passwordValidation;
