//
//  BluetoothConnectorViewController.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 12/10/2021.
//

import DJISDK
import CoreBluetooth
import SwiftUI

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class BluetoothConnectorViewController: UIViewController, DJIBluetoothProductConnectorDelegate, ObservableObject {

    var bluetoothProducts = [CBPeripheral]()
    var selectedIndex: IndexPath!
    
    func bluetoothConnector() -> DJIBluetoothProductConnector? {
        return DJISDKManager.bluetoothProductConnector()
    }
    
    func searchBluetoothProducts() {
        print("bluetooth connector:", DJISDKManager.bluetoothProductConnector())
        
        guard let blConnector = self.bluetoothConnector() else {
            return;
        }
            
        blConnector.delegate = self
            
        blConnector.searchBluetoothProducts { (error: Error?) in
            if error != nil {
                //self.showAlert("Search Bluetooth product failed:\(error!)")
                print("error", error)
            }
        }
    }
    
    func onBluetoothConnectButtonClicked() {
        if isBluetoothProductConnected() {
            self.disconnectBluetooth();
        } else {
            self.connectBluetooth();
        }
    }
    
    func updateConnectButtonState() -> Void {
        if isBluetoothProductConnected() {
            //self.connectButton.setTitle("Disconnect", for: UIControl.State())
        } else {
            //self.connectButton.setTitle("Connect", for: UIControl.State())
        }
    }
    
    func isBluetoothProductConnected() -> Bool {
        guard let product = DJISDKManager.product() else {
            return false;
        }
        if (product.model == DJIHandheldModelNameOsmoMobile) {
            return true;
        }
        return false;
    }
    
    func connectBluetooth() -> Void {
        
        if self.bluetoothProducts.isEmpty == true ||
           self.selectedIndex == nil {
            return
        }
        
        
        guard let blConnector = self.bluetoothConnector() else {
            return;
        }
        
        let curSelectedPer = self.bluetoothProducts[self.selectedIndex.row]
        blConnector.connectProduct(curSelectedPer) { (error:Error?) in
            if let _ = error {
                //self.showAlert("Connect Bluetooth product failed:\(error!)")
            } else {
                self.bluetoothProducts.removeAll();
                //self.bluetoothDevicesTableView.reloadData()
                //self.connectButton.setTitle("Disconnect", for: UIControl.State())
            }
        }
    }
    
    func disconnectBluetooth() -> Void {
        self.bluetoothConnector()?.disconnectProduct { [weak self](error:Error?) in
            if let _ = error {
                //self!.showAlert("Disconnect Bluetooth product failed:\(error!)")
            } else {
                //self!.connectButton.setTitle("Connect", for: UIControl.State())
                //self!.bluetoothDevicesTableView.reloadData()
            }
        }
    }
    
    
    func connectorDidFindProducts(_ peripherals: [CBPeripheral]?) {
        guard peripherals != nil else {
            return;
        }
        self.bluetoothProducts = peripherals!
        print("reload table")
    }
    
    
    // MARK : Convenience

}
