var exec = require('cordova/exec');
exports.hasReadPermission = function(callback) {
  return exec(callback, null, "CDVImageGallery", "hasReadPermission", []);
};
exports.requestReadPermission = function(callback, failureCallback) {
  return exec(callback, failureCallback, "CDVImageGallery", "requestReadPermission", []);
};
exports.show=function(success,error,options){
	if (!options) {
		options = {};
	}
	var params = {
		mode:(options.mode)?options.mode:'LibraryOnly',
        gridSize: options.gridSize ? options.gridSize : 3,
        cellSpacing: options.cellSpacing ? options.cellSpacing : 2,
        maxDuration: options.maxDuration ? options.maxDuration : 2,
        maximumImagesCount: options.maximumImagesCount ? options.maximumImagesCount : 15,
		width: 0,//legacy, not supported in ios
		height:0,//legacy, not supported in ios
		quality: options.quality ? options.quality : 100
	};
	exec(success, error, "CDVImageGallery", "show", [params]);
}