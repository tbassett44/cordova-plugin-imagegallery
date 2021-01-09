import UIKit
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD
import Photos

@objc(CDVImageGallery) class CDVImageGallery : CDVPlugin,GalleryControllerDelegate,LightboxControllerDismissalDelegate {
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor();
    var returncommand: CDVInvokedUrlCommand!;
    var args: CDVImageGalleryOptions!;
    struct CDVImageGalleryOptions{
        var quality: Float;
        var mode: String;
        var maxImages: Int;
        var gridSize: Int;
        var cellSpacing: Int;
        var maxDuration: Int;
        init() {
            quality = 1.0
            maxImages = 10
            gridSize = 3
            cellSpacing = 2
            maxDuration = 100000
            mode = "LibraryOnly"
        }
    }
    @objc(ensurePermissions:)
    func ensurePermissions(_ command: CDVInvokedUrlCommand) {
        if #available(iOS 14.0, *) {
            var pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "ask"
            )
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .notDetermined:
                // ask for access
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
                        case .restricted, .denied:
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "failed"
                            )
                        case .limited:
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "limited"
                            )
                        case .authorized:
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "authorized"
                            )
                        case .notDetermined:
                            pluginResult = CDVPluginResult(
                                status: CDVCommandStatus_OK,
                                messageAs: "notdetermined"
                            )
                    }
                    self.commandDelegate!.send(
                        pluginResult,
                        callbackId: command.callbackId
                    )
                }
                return
            case .restricted, .denied:
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "failed"
                )
            case .authorized:
                // we have full access
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "authorized"
                )
            // new option:
            case .limited:
                // we only got access to a part of the library
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "limited"
                )
                
            }
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }else{//if less than ios14, normal flow works!
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "success"
            )
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }
    @objc(show:)
    func show(_ command: CDVInvokedUrlCommand) {
        returncommand=command;
        let gallery = GalleryController()
        gallery.delegate = self
        //configure settings!
        args=CDVImageGalleryOptions();
        args.mode=(command.arguments[0] as AnyObject).value(forKey: "mode") as! String
        args.maxImages=(command.arguments[0] as AnyObject).value(forKey: "maximumImagesCount") as! Int
        args.gridSize=(command.arguments[0] as AnyObject).value(forKey: "gridSize") as! Int
        args.cellSpacing=(command.arguments[0] as AnyObject).value(forKey: "cellSpacing") as! Int
        args.quality=((command.arguments[0] as AnyObject).value(forKey: "quality") as! Float)/100
        args.maxDuration=((command.arguments[0] as AnyObject).value(forKey: "maxDuration") as! Int)
        Config.Camera.imageLimit = args.maxImages
        Config.Grid.Dimension.columnCount = CGFloat(args.gridSize)
        Config.Grid.Dimension.cellSpacing = CGFloat(args.cellSpacing)
        Config.VideoEditor.maximumDuration=TimeInterval(args.maxDuration);
        print(args)
        if(args.mode=="LibraryOnly"){
            Config.tabsToShow = [.imageTab]
        }else if(args.mode=="LibraryAndCamera"){
            Config.tabsToShow = [.imageTab,.cameraTab]
            Config.initialTab = .imageTab
        }else if(args.mode=="CameraOnly"){
            Config.tabsToShow = [.cameraTab]
        }else if(args.mode=="VideoOnly"){
            Config.tabsToShow = [.videoTab]
        }else if(args.mode=="AllMedia"){
            Config.tabsToShow = [.imageTab,.cameraTab,.videoTab]
            Config.initialTab = .imageTab
        }else{
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Invalid Mode"
            )
            self.commandDelegate!.send(
                pluginResult,
                callbackId: self.returncommand.callbackId
            )
            return
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
        NSLog("Got Video!")
        controller.dismiss(animated: true, completion: nil)
        let thisitem=self;
        video.fetchAVAsset { asset in
            let newObj = asset as! AVURLAsset
            print(newObj.url.path)
            var imagelist=[] as [String]
            imagelist.append(newObj.url.path);
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: imagelist
            )
            thisitem.commandDelegate!.send(
                pluginResult,
                callbackId: thisitem.returncommand.callbackId
            )
        }
    }
    func saveImageDocumentDirectory(image: UIImage, imageName: String) -> String{
        let fileManager = FileManager.default
        let url = NSURL(string: NSTemporaryDirectory())
        let imagePath = url!.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        //let imageData = UIImageJPEGRepresentation(image, CGFloat(self.args!.quality))
        let imageData = image.jpegData(compressionQuality: CGFloat(self.args!.quality))
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
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
          return
        }

        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self

        //self.viewController.present(lightbox, animated: true, completion: nil)
      }
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        return
        LightboxConfig.DeleteButton.enabled = true

        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
          SVProgressHUD.dismiss()
          self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
      }
      func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        print(page)
      }
    func lightboxControllerWillDismiss(_ controller: LightboxController) {

  }
}
