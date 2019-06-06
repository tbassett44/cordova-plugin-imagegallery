import UIKit
import Gallery
import AVFoundation
import AVKit
@objc(CDVImageGallery) class CDVImageGallery : CDVPlugin,GalleryControllerDelegate {
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor();
    var returncommand: CDVInvokedUrlCommand!;
    var args: CDVImageGalleryOptions!;
    var quality: Float!;
    struct CDVImageGalleryOptions{
        var quality: Float;
        var mode: String;
        var maxImages: Int;
        init() {
            quality = 1.0
            maxImages = 10
            mode = "LibraryOnly"
        }
    }
    @objc(show:)
    func show(_ command: CDVInvokedUrlCommand) {
        returncommand=command;
      let gallery = GalleryController()
        gallery.delegate = self
        //configure settings!
        args=CDVImageGalleryOptions();
        args.maxImages=(command.arguments[0] as AnyObject).value(forKey: "maximumImagesCount") as! Int
        Config.Camera.imageLimit = args.maxImages
        print(args)
        if(args.mode=="LibraryOnly"){
            Config.tabsToShow = [.imageTab]
        }
        self.viewController.present(gallery, animated: true, completion: nil)
  }
  func galleryControllerDidCancel(_ controller: GalleryController) {
      controller.dismiss(animated: true, completion: nil)
      gallery = nil
    let pluginResult = CDVPluginResult(
        status: CDVCommandStatus_ERROR,
        messageAs: "Closed"
    )
    self.commandDelegate!.send(
        pluginResult,
        callbackId: self.returncommand.callbackId
    )
  }

  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
      controller.dismiss(animated: true, completion: nil)
      gallery = nil
      
      
//      editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
//          if let tempPath = tempPath {
//              let controller = AVPlayerViewController()
//              controller.player = AVPlayer(url: tempPath)
//
//              self.viewController.present(controller, animated: true, completion: nil)
//          }
//      }
  }
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    func getDirectoryPath() -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("temp")
        let url = NSURL(string: path)
        return url!
    }
    func saveImageDocumentDirectory(image: UIImage, imageName: String) -> String{
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("temp")
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let url = NSURL(string: path)
        let imagePath = url!.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        let imageData = UIImageJPEGRepresentation(image, CGFloat(self.quality ?? 1.0))
        //let imageData = UIImagePNGRepresentation(image)
        fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil);
        return urlString;
    }
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
  func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    //return images!
    controller.dismiss(animated: true, completion: nil)
    let thisitem=self;
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            let returnimages=resolvedImages.compactMap({ $0 })
            var imagelist=[] as [String]
            for rimage in returnimages {
                imagelist.append(self!.saveImageDocumentDirectory(image: rimage, imageName:thisitem.randomString(length: 16)+".jpg" ))
            }
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: imagelist
            )
            thisitem.commandDelegate!.send(
                pluginResult,
                callbackId: thisitem.returncommand.callbackId
            )
        })
  }
}
