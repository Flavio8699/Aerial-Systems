//
//  ProductCommunicationManager.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 09/03/2022.
//

import UIKit
import DJISDK
import DJIWidget

class DJIDroneManager: NSObject, ObservableObject {
    
    static let shared = DJIDroneManager()
    
    fileprivate let enableBridgeMode = false
    fileprivate let bridgeAppIP = "10.164.33.30"

    @Published var videoFeed = DroneLiveFPV()
    
    var adapter: VideoPreviewerAdapter?
    var needToSetMode = false
    
    func registerWithSDK() {
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        
        guard appKey != nil && appKey!.isEmpty == false else {
            NSLog("Please enter your app key in the info.plist")
            return
        }
        
        DJISDKManager.registerApp(with: self)
    }
    
}

extension DJIDroneManager: DJISDKManagerDelegate {
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        NSLog("SDK downloading db file \(progress.completedUnitCount / progress.totalUnitCount)")
    }
    
    func appRegisteredWithError(_ error: Error?) {
        var message = "Register App Successed!"
        
        if let _ = error {
            message = "SDK Registered with error \(error?.localizedDescription ?? "")"
        } else {
            if enableBridgeMode {
                DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppIP)
            } else {
                DJISDKManager.startConnectionToProduct()
            }
        }
        
        NSLog(message)
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if let camera = fetchCamera() {
            camera.delegate = self
        }
        print("PRODUCT CONNECTED")
    }
    
    func productDisconnected() {
        if let camera = fetchCamera(), let delegate = camera.delegate, delegate.isEqual(self) {
            camera.delegate = nil
        }
        print("PRODUCT DISCONNECTED")
        self.resetVideo()
    }
    
    func componentConnected(withKey key: String?, andIndex index: Int) {
        
    }
    
    func componentDisconnected(withKey key: String?, andIndex index: Int) {
        
    }
}

extension DJIDroneManager: DJIVideoFeedListener {
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        let videoData = videoData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        DJIVideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
}

extension DJIDroneManager: DJICameraDelegate {
    func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        if product is DJIAircraft {
            return (product as! DJIAircraft).camera
        }
        if product is DJIHandheld {
            return (product as! DJIHandheld).camera
        }
        return nil
    }
    
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        if systemState.mode != .recordVideo && systemState.mode != .shootPhoto {
            return
        }
        if needToSetMode == false {
            return
        }
        
        needToSetMode = false
        camera.setMode(.shootPhoto) { (error) in
            if error != nil {
                self.needToSetMode = true
            }
        }
    }
    
    func camera(_ camera: DJICamera, didGenerateNewMediaFile newMedia: DJIMediaFile) { }
}

extension DJIDroneManager: DJIVideoPreviewerFrameControlDelegate {
    func parseDecodingAssistInfo(withBuffer buffer: UnsafeMutablePointer<UInt8>!, length: Int32, assistInfo: UnsafeMutablePointer<DJIDecodingAssistInfo>!) -> Bool {
        return DJISDKManager.videoFeeder()?.primaryVideoFeed.parseDecodingAssistInfo(withBuffer: buffer, length: length, assistInfo: assistInfo) ?? false
    }
    
    func isNeedFitFrameWidth() -> Bool {
        let displayName = fetchCamera()?.displayName
        if displayName == DJICameraDisplayNameMavic2ZoomCamera ||
            displayName == DJICameraDisplayNameMavic2ProCamera {
            return true
        }
        return false
    }
    
    func syncDecoderStatus(_ isNormal: Bool) {
        DJISDKManager.videoFeeder()?.primaryVideoFeed.syncDecoderStatus(isNormal)
    }
    
    func decodingDidSucceed(withTimestamp timestamp: UInt32) {
        DJISDKManager.videoFeeder()?.primaryVideoFeed.decodingDidSucceed(withTimestamp: UInt(timestamp))
    }
    
    func decodingDidFail() {
        DJISDKManager.videoFeeder()?.primaryVideoFeed.decodingDidFail()
    }    
}

extension DJIDroneManager {
    func setupVideo() {
        DJIVideoPreviewer.instance().setView(self.videoFeed.view)
        
        let camera = self.fetchCamera()
        camera?.delegate = self
        
        needToSetMode = true

        DJIVideoPreviewer.instance()?.start()
        
        adapter = VideoPreviewerAdapter.init()
        adapter?.start()
        
        if camera?.displayName == DJICameraDisplayNameMavic2ZoomCamera ||
            camera?.displayName == DJICameraDisplayNameMavic2ProCamera {
            adapter?.setupFrameControlHandler()
        }
    }
    
    func resetVideo() {
        DJIVideoPreviewer.instance()?.unSetView()
        
        if adapter != nil {
            adapter?.stop()
            adapter = nil
        }
    }
}
