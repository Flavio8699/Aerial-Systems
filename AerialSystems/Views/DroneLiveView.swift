//
//  DroneLiveView.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 18/11/2021.
//

import SwiftUI
import DJISDK

struct DroneLiveView: View {
    var body: some View {
        VStack {
            Text("test \(DJISDKManager.sdkVersion())")
            CameraFPVViewController()
        }.onAppear {
            print("Appear")
            guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
                NSLog("Error creating the connectedKey")
                return;
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
                    if newValue != nil {
                        if newValue!.boolValue {
                            // At this point, a product is connected so we can show it.
                            
                            // UI goes on MT.
                            DispatchQueue.main.async {
                                self.productConnected()
                            }
                        }
                    }
                })
                DJISDKManager.keyManager()?.getValueFor(connectedKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
                    if let unwrappedValue = value {
                        if unwrappedValue.boolValue {
                            // UI goes on MT.
                            DispatchQueue.main.async {
                                self.productConnected()
                            }
                        }
                    }
                })
            }
        }.onDisappear {
            print("Disappear")
            DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
        }
    }
    
    func productConnected() {
        guard let newProduct = DJISDKManager.product() else {
            print("Product is connected but DJISDKManager.product is nil -> something is wrong")
            return;
        }

        //Updates the product's model
        print("Model: \((newProduct.model)!)")
        
        //Updates the product's firmware version - COMING SOON
        newProduct.getFirmwarePackageVersion{ (version:String?, error:Error?) -> Void in
            
            print("Firmware Package Version: \(version ?? "Unknown")")
            
            print("Firmware package version is: \(version ?? "Unknown")")
        }
    
        print("Product Connected")
    }
    
    func productDisconnected() {
        print("Product Disconnected")
    }
}

struct DroneLiveView_Previews: PreviewProvider {
    static var previews: some View {
        DroneLiveView()
    }
}
