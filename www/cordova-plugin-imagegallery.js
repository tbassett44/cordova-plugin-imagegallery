var exec = require('cordova/exec');
exports.show=function(success,error,options){
	if (!options) {
		options = {};
	}
	var params = {
		mode:(options.mode)?options.mode:'LibraryOnly',
		maximumImagesCount: options.maximumImagesCount ? options.maximumImagesCount : 15,
        gridSize: options.gridSize ? options.gridSize : 3,
        cellSpacing: options.cellSpacing ? options.cellSpacing : 2,
        maximumImagesCount: options.maximumImagesCount ? options.maximumImagesCount : 15,
		width: 0,//legacy, not supported in ios
		height:0,//legacy, not supported in ios
		quality: options.quality ? options.quality : 100
	};
	exec(success, error, "CDVImageGallery", "show", [params]);
}