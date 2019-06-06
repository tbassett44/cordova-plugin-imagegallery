var exec = require('cordova/exec');
exports.show=function(options,success,error){
	if (!options) {
		options = {};
	}
	var params = {
		maximumImagesCount: options.maximumImagesCount ? options.maximumImagesCount : 15,
		width: 0,//legacy, not supported in ios
		height:0,//legacy, not supported in ios
		quality: options.quality ? options.quality : 100	
	};
	exec(success, error, "CDVImageGallery", "show", [params]);
}