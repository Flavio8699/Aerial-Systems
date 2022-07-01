//
//  PopupHandler.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 28/10/2021.
//

import SwiftUI

class PopupHandler: ObservableObject {
    
    @Published private var showPopup: Bool = false
    @Published var currentPopup: PopupType? = nil {
        didSet {
            self.showPopup = true
        }
    }
    @Published var missionImagePopup: MissionImage? = nil {
        didSet {
            self.showPopup = true
        }
    }
    
    func isPopupOpen() -> Bool {
        return self.showPopup
    }
    
    func close() {
        self.missionImagePopup = nil
        self.currentPopup = nil
        self.showPopup = false
    }
}

enum PopupType {
    case success(message: String, button: String, action: () -> Void)
    case error(message: String, button: String, action: () -> Void)
    case saveMission(missionName: Binding<String>, action: () -> Void)
    case deleteMission(action: () -> Void)
    case logout(action: () -> Void)
    case messageAutoClose(message: String, closeAfter: CGFloat)
    case lowBattery(action1: () -> Void, action2: () -> Void)
}
