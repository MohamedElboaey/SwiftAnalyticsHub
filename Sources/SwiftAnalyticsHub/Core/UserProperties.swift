//
//  UserProperties.swift
//  GenericAnalytics
//
//  Created by Mohamed Elboraey on 02/12/2025.
//

import Foundation

public struct UserProperties: @unchecked Sendable {
    public let properties: [String: Any]
    
    public init(properties: [String: Any]) {
        self.properties = properties
    }
}
