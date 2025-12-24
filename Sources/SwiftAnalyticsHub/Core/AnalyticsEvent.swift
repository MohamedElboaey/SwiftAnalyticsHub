//
//  AnalyticsEvent.swift
//  GenericAnalytics
//
//  Created by Mohamed Elboraey on 02/12/2025.
//

import Foundation

public struct AnalyticsEvent: @unchecked Sendable {
    public let name: String
    public let parameters: [String: Any]?
    public let action: String?
    public let extraParam: String?
    public let timestamp: Date
    
    public init(name: String, parameters: [String: Any]? = nil, action: String? = "" , extraParam: String? = nil, timestamp: Date = Date()) {
        self.name = name
        self.parameters = parameters
        self.action = action
        self.extraParam = extraParam
        self.timestamp = timestamp
    }
}
