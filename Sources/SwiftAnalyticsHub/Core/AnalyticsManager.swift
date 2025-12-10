//
//  AnalyticsManager.swift
//  GenericAnalytics
//
//  Created by Mohamed Elboraey on 02/12/2025.
//

import Foundation

public final class AnalyticsManager: @unchecked Sendable {
    public static let shared = AnalyticsManager()
    
    private var providers: [AnalyticsProvider] = []
    private let queue = DispatchQueue(label: "com.analytics.queue", attributes: .concurrent)
    private var isConfigured = false
    
    private init() {}
    
    // MARK: - Provider Management
    
    /// Register a new analytics provider
    public func register(provider: AnalyticsProvider, config: [String: Any] = [:]) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Check if provider already exists
            if self.providers.contains(where: { $0.identifier == provider.identifier }) {
                print("⚠️ Analytics: Provider '\(provider.identifier)' already registered")
                return
            }
            
            do {
                var mutableProvider = provider
                try mutableProvider.configure(with: config)
                self.providers.append(mutableProvider)
                self.isConfigured = true
                print("✅ Analytics: Registered '\(provider.identifier)'")
            } catch {
                print("❌ Analytics: Failed to configure '\(provider.identifier)': \(error)")
            }
        }
    }
    
    /// Convenience: Register multiple providers at once
    public func setup(providers: [AnalyticsProvider], config: [String: Any] = [:]) {
        providers.forEach { register(provider: $0, config: config) }
    }
    
    /// Remove a provider
    public func unregister(providerIdentifier: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.providers.removeAll { $0.identifier == providerIdentifier }
            print("🗑️ Analytics: Unregistered '\(providerIdentifier)'")
        }
    }
    
    /// Get all registered providers
    public func getProviders() -> [String] {
        queue.sync {
            providers.map { $0.identifier }
        }
    }
    
    // MARK: - Analytics Methods
    
    /// Track event to specific providers only
    public func track(
        providerIds: [String],
        eventName: String,
        parameters: [String: Any]? = nil,
        action: String? = nil,
        extraParam: String? = nil
    ) {
        let event = AnalyticsEvent(name: eventName, parameters: parameters, action: action, extraParam: extraParam)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let registeredIds = Set(self.providers.map { $0.identifier })
            let requestedIds = Set(providerIds)
            let missingIds = requestedIds.subtracting(registeredIds)
            
            if !missingIds.isEmpty {
                print("⚠️ Analytics: Unknown providers: \(missingIds.joined(separator: ", "))")
            }
            
            self.providers.forEach { provider in
                if requestedIds.contains(provider.identifier) {
                    provider.track(event: event)
                }
            }
        }
    }
    
    /// Track event across ALL providers
    public func track(eventName: String, parameters: [String: Any]? = nil, action: String? = nil, extraParam: String? = nil) {
        guard isConfigured else {
            print("⚠️ Analytics: Not configured. Call setup() or register() first!")
            return
        }
        
        let event = AnalyticsEvent(name: eventName, parameters: parameters, action: action, extraParam: extraParam)
        
        queue.async { [weak self] in
            self?.providers.forEach { $0.track(event: event) }
        }
    }
    
    /// Set user ID across all providers
    public func setUserId(_ userId: String?) {
        queue.async { [weak self] in
            self?.providers.forEach { $0.setUserId(userId) }
        }
    }
    
    /// Set user properties across all providers
    public func setUserProperties(_ properties: [String: Any]) {
        let userProps = UserProperties(properties: properties)
        queue.async { [weak self] in
            self?.providers.forEach { $0.setUserProperties(userProps) }
        }
    }
    
    /// Track screen view across all providers
    public func trackScreen(_ screenName: String, parameters: [String: Any]? = nil) {
        queue.async { [weak self] in
            self?.providers.forEach { $0.trackScreen(name: screenName, parameters: parameters) }
        }
    }
    
    /// Reset all providers (logout)
    public func reset() {
        queue.async { [weak self] in
            self?.providers.forEach { $0.reset() }
        }
    }
}
