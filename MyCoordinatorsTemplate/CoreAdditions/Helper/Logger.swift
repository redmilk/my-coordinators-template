//
//  Logger.swift
//  MyCoordinatorsTemplate
//
//  Created by Danyl Timofeyev on 24.12.2020.
//  Copyright © 2020 Danyl Timofeyev. All rights reserved.
//

import Foundation

// TODO: - refactor to switch for including/discluding neccassary/unneccessary logs
struct Logger {

    static func log(_ text: String = "", entity: AnyObject?, symbol: String = "🌀") {
        if let pureEntityName = String(describing: entity).slice(from: ".", to: ":") {
            print("\(time()) \(symbol) \(text): \(pureEntityName)")
        } else if let pureEntityName = String(describing: entity).textAfter(str: ".") {
            print("\(time()) \(symbol) \(text): \(pureEntityName)")
        } else {
            print("\(time()) \(symbol) \(text): \(String(describing: entity))")
        }
    }
    
    static func initialization(entity: AnyObject, symbol: String = "⚠️") {
        if let pureEntityName = String(describing: entity).slice(from: ".", to: ":") {
            print("\(time()) \(symbol) init: \(pureEntityName)")
        } else if let pureEntityName = String(describing: entity).textAfter(str: ".") {
            print("\(time()) \(symbol) init: \(pureEntityName)")
        }
    }
    
    static func deinitialization(entity: AnyObject, symbol: String = "❌")  {
        if let pureEntityName = String(describing: entity).slice(from: ".", to: ":") {
            print("\(time()) \(symbol) deinit: \(pureEntityName)")
        } else if let pureEntityName = String(describing: entity).textAfter(str: ".") {
            print("\(time()) \(symbol) deinit: \(pureEntityName)")
        }
    }
    
    static private func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"

        return dateFormatter.string(from: Date())
    }
    
}
