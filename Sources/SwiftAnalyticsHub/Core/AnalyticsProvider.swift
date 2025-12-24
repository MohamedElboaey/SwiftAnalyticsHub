//
//  AnalyticsProvider.swift
//  GenericAnalytics
//
//  Created by Mohamed Elboraey on 02/12/2025.
//

import Foundation

public protocol AnalyticsProvider {
    /// Unique identifier for this provider
    var identifier: String { get }
    
    /// Initialize/configure the provider
    func configure(with config: [String: Any]) throws
    
    /// Track an event
    func track(event: AnalyticsEvent)
    
    /// Set user ID
    func setUserId(_ userId: String?)
    
    /// Set user properties
    func setUserProperties(_ properties: UserProperties)
    
    /// Track screen view
    func trackScreen(name: String, parameters: [String: Any]?)
    
    /// Reset/clear user data
    func reset()
}

extension AnalyticsProvider {
    func trackScreen(name: String, parameters: [String: Any]?) {
        
    }
}
