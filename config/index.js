let _        = require("lodash"),
    nconf    = require("nconf"),
    path     = require("path"),
    defaults = require("./defaults.json");

let configPath = path.join(__dirname, '../config');
nconf.env().argv();
nconf.file({file: path.join(configPath, (nconf.get('NODE_ENV') || "development") + ".json")});
nconf.defaults(defaults);

module.exports = nconf;
