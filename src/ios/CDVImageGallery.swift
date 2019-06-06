import UIKit
import Gallery
import AVFoundation
import AVKit
@objc(CDVImageGallery) class CDVImageGallery : CDVPlugin {
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
  func show(command: CDVInvokedUrlCommand) {
      var pluginResult = CDVPluginResult(
         status: CDVCommandStatus_ERROR
     )
      let gallery = GalleryController()
      viewController.present(gallery, animated: true, completion: nil)
      pluginResult = CDVPluginResult(
         status: CDVCommandStatus_OK
         )
      self.commandDelegate!.send(
         pluginResult,
         callbackId: command.callbackId
         )
  }
  func galleryControllerDidCancel(_ controller: GalleryController) {
      controller.dismiss(animated: true, completion: nil)
      gallery = nil
  }

  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
      controller.dismiss(animated: true, completion: nil)
      gallery = nil
      
      
      editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
          DispatchQueue.main.async {
              if let tempPath = tempPath {
                  let controller = AVPlayerViewController()
                  controller.player = AVPlayer(url: tempPath)
                  
                  //self.present(controller, animated: true, completion: nil)
              }
          }
      }
  }

  func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
      controller.dismiss(animated: true, completion: nil)
      gallery = nil
  }
}
