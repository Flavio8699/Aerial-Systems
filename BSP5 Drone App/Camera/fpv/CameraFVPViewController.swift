//
//  CameraFVPViewController.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 18/11/2021.
//

import SwiftUI
import DJISDK
import DJIWidget

struct CameraFPVViewController: UIViewRepresentable {
    
    var adapter: VideoPreviewerAdapter?
    var needToSetMode = false
    weak var fpvView: UIView!
    
    func makeUIView(context: Context) -> UIView {
        let camera = fetchCamera()
        camera?.delegate = test()
        
        DJIVideoPreviewer.instance()?.start()
        
        let x: VideoPreviewerAdapter? = VideoPreviewerAdapter.init()
        x?.start()
        
        if camera?.displayName == DJICameraDisplayNameMavic2ZoomCamera ||
            camera?.displayName == DJICameraDisplayNameMavic2ProCamera {
            adapter?.setupFrameControlHandler()
        }
        
        DJIVideoPreviewer.instance()?.setView(fpvView)
        print("appear")
        let empty = UIView.init()
        empty.backgroundColor = UIColor(.blue)
        return fpvView ?? empty
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
         print("update")
        DJIVideoPreviewer.instance()?.setView(fpvView)
    }
}

class test: NSObject, DJICameraDelegate {
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        if systemState.mode != .recordVideo && systemState.mode != .shootPhoto {
            return
        }
        /*if needToSetMode == false {
            return
        }
        needToSetMode = false
        */camera.setMode(.shootPhoto) { (error) in
            if error != nil {
                //self?.needToSetMode = true
            }
        }
        
    }
    
    func camera(_ camera: DJICamera, didUpdateTemperatureData temperature: Float) {
        //tempLabel.text = String(format: "%f", temperature)
    }
    
}
    
func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        
        if product is DJIAircraft || product is DJIHandheld {
            return product.camera
        }
        return nil
}
