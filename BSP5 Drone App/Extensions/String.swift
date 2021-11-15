//
//  String.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 04/11/2021.
//

import Foundation
import MapKit

extension Array where Element == String {
    func summary() -> String {
        var abbreviations = [String]()
        for word in self {
            abbreviations.append(word.firstLetterOfEveryWord())
        }
        return abbreviations.joined(separator: ", ")
    }
}

extension String {
    func firstLetterOfEveryWord() -> String {
        var result = ""
        for word in self.split(separator: " ") {
            if let letter = word.first {
                result.append(String(letter).capitalized)
            }
        }
        return result
    }
}
