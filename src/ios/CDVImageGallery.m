/*
 Copyright 2009-2011 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import "CDVJSBridge.h"
import <Cordova/CDVPlugin.h>
import Gallery
@objc(CDVImageGallery) class CDVImageGallery : CDVPlugin {

func show(command: CDVInvokedUrlCommand) {
    NSLog(@"======>RUN COMMAND");
    var pluginResult = CDVPluginResult(
       status: CDVCommandStatus_ERROR
   )
    let gallery = GalleryController()
    gallery.delegate = self
    present(gallery, animated: true, completion: nil)
    pluginResult = CDVPluginResult(
       status: CDVCommandStatus_OK,
       messageAsString: msg
       )
    self.commandDelegate!.sendPluginResult(
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
                
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
}
@end
