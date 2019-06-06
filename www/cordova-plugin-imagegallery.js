var exec = require('cordova/exec');

exports.show = function(arg0, success, error) {
    exec(success, error, "cordova-plugin-imagegallery", "show", [arg0]);
};
