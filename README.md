# SwiftAnalyticsHub 📊

A modern, type-safe, and thread-safe analytics aggregation library for iOS. Route analytics events to multiple providers (Firebase, Adjust, Tealuim, etc.) through a single, unified API.

## ✨ Features

- 🔌 **Multi-Provider Support**: Send events to multiple analytics services simultaneously
- 🎯 **Type-Safe**: Full Swift type safety with proper concurrency handling
- ⚡ **Thread-Safe**: Built with DispatchQueue for safe concurrent access
- 🧩 **Protocol-Oriented**: Easy to implement custom providers
- 🎨 **Flexible**: Track to all providers or specific ones per event
- 📦 **Lightweight**: Zero external dependencies
- 🔧 **Easy Integration**: Works with both SwiftUI and UIKit

## 🏗️ Architecture & Design Patterns

### Design Patterns Used

1. **Singleton Pattern** - `AnalyticsManager.shared` provides global access point
2. **Strategy Pattern** - `AnalyticsProvider` protocol allows swapping analytics implementations
3. **Facade Pattern** - Unified interface hiding multiple provider complexities
4. **Observer Pattern** - Providers observe and react to analytics events

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                 Your iOS/macOS App                       │
│                (SwiftUI or UIKit)                        │
│                                                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │         AnalyticsManager (Singleton)               │ │
│  │  ┌──────────────────────────────────────────────┐ │ │
│  │  │  Public API:                                 │ │ │
│  │  │  • track()                                   │ │ │
│  │  │  • setUserId()                               │ │ │
│  │  │  • setUserProperties()                       │ │ │
│  │  │  • trackScreen()                             │ │ │
│  │  │  • reset()                                   │ │ │
│  │  └──────────────────────────────────────────────┘ │ │
│  │                      │                             │ │
│  │                      ▼                             │ │
│  │         ┌────────────────────────┐                │ │
│  │         │  AnalyticsProvider     │                │ │
│  │         │     (Protocol)         │                │ │
│  │         └────────────────────────┘                │ │
│  │                      │                             │ │
│  │         ┌────────────┴────────────┐               │ │
│  │         ▼            ▼            ▼               │ │
│  │    ┌─────────┐  ┌─────────┐  ┌─────────┐        │ │
│  │    │Firebase │  │ Adjust  │  │Mixpanel │        │ │
│  │    │Provider │  │Provider │  │Provider │        │ │
│  │    └─────────┘  └─────────┘  └─────────┘        │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
              ┌───────────────────────┐
              │  Analytics Services   │
              │  • Firebase Analytics │
              │  • Adjust             │
              │  • Mixpanel           │
              │  • Your Custom SDK    │
              └───────────────────────┘
```

### Data Flow Diagram

```
User Action
    │
    ▼
┌─────────────────┐
│   Your App      │
│ (SwiftUI/UIKit) │
└────────┬────────┘
         │
         │ track(eventName, parameters)
         ▼
┌─────────────────────────┐
│   AnalyticsManager      │
│   ┌─────────────────┐   │
│   │ Provider Array  │   │
│   │ [P1, P2, P3]    │   │
│   └─────────────────┘   │
└──────┬──────────────────┘
       │
       │ Dispatch to all providers (Concurrent Queue)
       │
       ├─────────────┬─────────────┬─────────────┐
       ▼             ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│Firebase  │  │ Adjust   │  │Mixpanel  │  │ Custom   │
│Provider  │  │Provider  │  │Provider  │  │Provider  │
└────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │             │
     ▼             ▼             ▼             ▼
Firebase API   Adjust SDK   Mixpanel API   Your API
```

## 📦 Installation

### Swift Package Manager

**Option 1: Xcode UI**
1. Open your project in Xcode
2. Go to `File` → `Add Package Dependencies...`
3. Enter the repository URL: `https://github.com/MohamedElboaey/SwiftAnalyticsHub.git`
4. Click `Add Package`

**Option 2: Package.swift**

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/MohamedElboaey/SwiftAnalyticsHub.git", from: "1.0.0")
]
```

**Option 3: Xcode Project**

Add to your Xcode project's Package Dependencies section.

## 🚀 Quick Start

### Step 1: Create Your Provider

Here's an example Firebase provider:

```swift
import Foundation
import SwiftAnalyticsHub
import FirebaseAnalytics

final class FirebaseProvider: AnalyticsProvider {
    let identifier = "firebase"
    
    func configure(with config: [String: Any]) throws {
        // Initialize Firebase SDK
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    func track(event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
    
    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperties(_ properties: UserProperties) {
        properties.properties.forEach { key, value in
            Analytics.setUserProperty(value, forName: key)
        }
    }
    
    func trackScreen(name: String, parameters: [String: Any]?) {
        var params = parameters ?? [:]
        params["screen_name"] = name
        Analytics.logEvent("screen_view", parameters: params)
    }
    
    func reset() {
        Analytics.resetAnalyticsData()
    }
}
```

## 📱 Integration Examples

### SwiftUI Integration

#### 1. Setup in App Entry Point

```swift
import SwiftUI
import SwiftAnalyticsHub

@main
struct MyApp: App {
    
    init() {
        setupAnalytics()
    }
    
    private func setupAnalytics() {
        // Create providers
        let firebase = FirebaseProvider()
        let adjust = AdjustProvider()
        let mixpanel = MixpanelProvider()
        
        // Register providers
        AnalyticsManager.shared.setup(
            providers: [firebase, adjust, mixpanel],
            config: [
                "firebase": ["debug": true],
                "adjust": ["appToken": "YOUR_ADJUST_TOKEN"],
                "mixpanel": ["token": "YOUR_MIXPANEL_TOKEN"]
            ]
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### 2. Track Events in SwiftUI Views

```swift
import SwiftUI
import SwiftAnalyticsHub

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        VStack {
            Text(product.name)
                .font(.title)
            
            Text("$\(product.price)")
                .font(.headline)
            
            Button("Add to Cart") {
                addToCart()
            }
        }
        .onAppear {
            trackScreenView()
        }
    }
    
    private func trackScreenView() {
        AnalyticsManager.shared.trackScreen(
            "ProductDetail",
            parameters: [
                "product_id": product.id,
                "product_name": product.name,
                "category": product.category
            ]
        )
    }
    
    private func addToCart() {
        // Add to cart logic
        
        // Track event
        AnalyticsManager.shared.track(
            eventName: "add_to_cart",
            parameters: [
                "product_id": product.id,
                "product_name": product.name,
                "price": "\(product.price)",
                "currency": "USD"
            ],
            action: "tap"
        )
    }
}
```

#### 3. Track User Authentication

```swift
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            Button("Login") {
                performLogin()
            }
            
            Button("Sign Up") {
                performSignUp()
            }
        }
        .padding()
    }
    
    private func performLogin() {
        // Login logic
        let userId = "user_12345"
        
        // Set user ID across all providers
        AnalyticsManager.shared.setUserId(userId)
        
        // Set user properties
        AnalyticsManager.shared.setUserProperties([
            "email": email,
            "login_method": "email",
            "account_created": "2024-12-10"
        ])
        
        // Track login event
        AnalyticsManager.shared.track(
            eventName: "user_login",
            parameters: ["method": "email"],
            action: "login"
        )
    }
    
    private func performSignUp() {
        // Sign up logic
        
        AnalyticsManager.shared.track(
            eventName: "user_signup",
            parameters: [
                "method": "email",
                "source": "app"
            ]
        )
    }
}
```

#### 4. Track with View Modifier (Custom Extension)

```swift
import SwiftUI
import SwiftAnalyticsHub

// Create a custom view modifier
struct AnalyticsViewModifier: ViewModifier {
    let screenName: String
    let parameters: [String: Any]?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                AnalyticsManager.shared.trackScreen(
                    screenName,
                    parameters: parameters
                )
            }
    }
}

extension View {
    func trackScreen(_ name: String, parameters: [String: Any]? = nil) -> some View {
        modifier(AnalyticsViewModifier(screenName: name, parameters: parameters))
    }
}

// Usage
struct HomeView: View {
    var body: some View {
        Text("Welcome Home")
            .trackScreen("Home")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .trackScreen("Profile", parameters: ["user_type": "premium"])
    }
}
```

### UIKit Integration

#### 1. Setup in AppDelegate

```swift
import UIKit
import SwiftAnalyticsHub

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        setupAnalytics()
        return true
    }
    
    private func setupAnalytics() {
        let firebase = FirebaseProvider()
        let adjust = AdjustProvider()
        
        AnalyticsManager.shared.setup(
            providers: [firebase, adjust],
            config: [
                "firebase": ["debug": true],
                "adjust": ["appToken": "YOUR_TOKEN"]
            ]
        )
        
        // Track app launch
        AnalyticsManager.shared.track(
            eventName: "app_launched",
            parameters: [
                "version": Bundle.main.appVersion,
                "build": Bundle.main.buildNumber
            ]
        )
    }
}
```

#### 2. Track in ViewControllers

```swift
import UIKit
import SwiftAnalyticsHub

class ProductViewController: UIViewController {
    
    let product: Product
    
    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenView()
    }
    
    private func setupUI() {
        // UI setup
        let addToCartButton = UIButton()
        addToCartButton.addTarget(
            self,
            action: #selector(addToCartTapped),
            for: .touchUpInside
        )
    }
    
    @objc private func addToCartTapped() {
        // Add to cart logic
        
        AnalyticsManager.shared.track(
            eventName: "add_to_cart",
            parameters: [
                "product_id": product.id,
                "product_name": product.name,
                "price": "\(product.price)",
                "source": "product_detail"
            ],
            action: "button_tap"
        )
    }
    
    private func trackScreenView() {
        AnalyticsManager.shared.trackScreen(
            "ProductDetail",
            parameters: [
                "product_id": product.id,
                "category": product.category
            ]
        )
    }
}
```

#### 3. Track User Actions with UIButton

```swift
class CheckoutViewController: UIViewController {
    
    private lazy var purchaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Complete Purchase", for: .normal)
        button.addTarget(self, action: #selector(purchaseTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func purchaseTapped() {
        let orderId = UUID().uuidString
        let totalAmount = calculateTotal()
        
        // Track purchase
        AnalyticsManager.shared.track(
            eventName: "purchase_completed",
            parameters: [
                "order_id": orderId,
                "amount": "\(totalAmount)",
                "currency": "USD",
                "payment_method": "credit_card",
                "item_count": "\(cartItems.count)"
            ],
            action: "purchase",
            extraParam: "checkout_screen"
        )
        
        // Track to specific providers only
        AnalyticsManager.shared.track(
            providerIds: ["firebase", "mixpanel"],
            eventName: "high_value_purchase",
            parameters: ["amount": "\(totalAmount)"]
        )
    }
    
    private func calculateTotal() -> Double {
        // Calculate logic
        return 99.99
    }
}
```

#### 4. Track in UITableView/UICollectionView

```swift
class ProductListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ProductListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        
        // Track product selection
        AnalyticsManager.shared.track(
            eventName: "product_selected",
            parameters: [
                "product_id": product.id,
                "product_name": product.name,
                "position": "\(indexPath.row)",
                "section": "main_list"
            ],
            action: "tap"
        )
        
        // Navigate to detail
        let detailVC = ProductViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ProductListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = product.name
        return cell
    }
}
```

#### 5. Base ViewController with Auto-Tracking

```swift
import UIKit
import SwiftAnalyticsHub

class BaseViewController: UIViewController {
    
    /// Override this in subclasses to provide screen name
    var screenName: String {
        return String(describing: type(of: self))
    }
    
    /// Override to provide additional parameters
    var screenParameters: [String: Any]? {
        return nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenView()
    }
    
    private func trackScreenView() {
        AnalyticsManager.shared.trackScreen(
            screenName,
            parameters: screenParameters
        )
    }
}

// Usage
class HomeViewController: BaseViewController {
    override var screenName: String {
        return "Home"
    }
    
    override var screenParameters: [String: Any]? {
        return ["tab": "main"]
    }
}
```

## 🎯 Common Use Cases

### 1. E-commerce Tracking

```swift
// Product View
AnalyticsManager.shared.track(
    eventName: "product_viewed",
    parameters: [
        "product_id": "SKU123",
        "product_name": "Premium Subscription",
        "price": "9.99",
        "currency": "USD"
    ]
)

// Add to Cart
AnalyticsManager.shared.track(
    eventName: "add_to_cart",
    parameters: [
        "product_id": "SKU123",
        "quantity": "1"
    ]
)

// Purchase
AnalyticsManager.shared.track(
    eventName: "purchase_completed",
    parameters: [
        "transaction_id": "TXN123",
        "total_amount": "9.99",
        "payment_method": "apple_pay"
    ]
)
```

### 2. User Engagement

```swift
// App Open
AnalyticsManager.shared.track(eventName: "app_opened")

// Feature Usage
AnalyticsManager.shared.track(
    eventName: "feature_used",
    parameters: [
        "feature_name": "dark_mode",
        "enabled": "true"
    ]
)

// Content Interaction
AnalyticsManager.shared.track(
    eventName: "content_shared",
    parameters: [
        "content_type": "article",
        "content_id": "article_123",
        "share_method": "twitter"
    ]
)
```

### 3. User Journey

```swift
// Onboarding
AnalyticsManager.shared.track(
    eventName: "onboarding_started",
    parameters: ["source": "first_launch"]
)

AnalyticsManager.shared.track(
    eventName: "onboarding_step_completed",
    parameters: ["step": "1", "step_name": "welcome"]
)

AnalyticsManager.shared.track(
    eventName: "onboarding_completed",
    parameters: ["duration_seconds": "120"]
)
```

### 4. User Logout

```swift
func logout() {
    // Clear user session
    
    // Track logout
    AnalyticsManager.shared.track(eventName: "user_logout")
    
    // Reset analytics data
    AnalyticsManager.shared.reset()
    
    // Clear user ID
    AnalyticsManager.shared.setUserId(nil)
}
```

## 🔧 Advanced Features

### Track to Specific Providers

```swift
// Only send to Firebase and Mixpanel
AnalyticsManager.shared.track(
    providerIds: ["firebase", "mixpanel"],
    eventName: "premium_feature_accessed",
    parameters: ["feature": "advanced_analytics"]
)
```

### Check Registered Providers

```swift
let providers = AnalyticsManager.shared.getProviders()
print("Active providers: \(providers)")
// Output: ["firebase", "adjust", "mixpanel"]
```

### Dynamic Provider Management

```swift
// Add provider at runtime
let newProvider = CustomAnalyticsProvider()
AnalyticsManager.shared.register(provider: newProvider, config: [:])

// Remove provider
AnalyticsManager.shared.unregister(providerIdentifier: "adjust")
```

## 📊 Event Naming Best Practice

Create constants for event names to avoid typos:

```swift
struct AnalyticsEvents {
    // User Events
    static let userLogin = "user_login"
    static let userSignup = "user_signup"
    static let userLogout = "user_logout"
    
    // E-commerce Events
    static let productViewed = "product_viewed"
    static let addToCart = "add_to_cart"
    static let purchaseCompleted = "purchase_completed"
    
    // Engagement Events
    static let appOpened = "app_opened"
    static let featureUsed = "feature_used"
    static let contentShared = "content_shared"
}

// Usage
AnalyticsManager.shared.track(eventName: AnalyticsEvents.userLogin)
```

## 🧩 Creating Custom Providers

### Example: Custom REST API Provider

```swift
import Foundation
import SwiftAnalyticsHub

final class CustomAPIProvider: AnalyticsProvider {
    let identifier = "custom_api"
    private var apiKey: String?
    private var endpoint: String?
    
    func configure(with config: [String: Any]) throws {
        guard let key = config["apiKey"] as? String,
              let url = config["endpoint"] as? String else {
            throw NSError(domain: "CustomAPIProvider", code: 1)
        }
        self.apiKey = key
        self.endpoint = url
    }
    
    func track(event: AnalyticsEvent) {
        guard let endpoint = endpoint,
              let url = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        let payload: [String: Any] = [
            "event_name": event.name,
            "parameters": event.parameters ?? [:],
            "timestamp": event.timestamp.timeIntervalSince1970
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setUserId(_ userId: String?) {
        // Implement user ID tracking
    }
    
    func setUserProperties(_ properties: UserProperties) {
        // Implement user properties
    }
    
    func reset() {
        // Implement reset logic
    }
}
```

## 🔒 Thread Safety

SwiftAnalyticsHub uses concurrent dispatch queues to ensure thread safety:

- ✅ Safe to call from any thread
- ✅ No data races
- ✅ Concurrent event tracking
- ✅ Non-blocking operations

## ⚠️ Important Notes

1. **Initialize Early**: Set up analytics in your app's launch method
2. **Privacy Compliance**: Always get user consent before tracking
3. **Test in Debug**: Enable debug mode during development
4. **Monitor Logs**: Check console for analytics warnings/errors

## 🆘 Troubleshooting

**Problem**: Events not appearing in analytics dashboard

**Solutions**:
- Check provider configuration
- Verify SDK initialization
- Enable debug mode
- Check internet connectivity
- Verify event name formatting

**Problem**: Provider already registered warning

**Solution**:
- Check if you're registering the same provider twice
- Use `getProviders()` to check registered providers

## 📄 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📮 Support

- 📧 Email: Mohamedelboraey35@gmail.com
- 🐛 Issues: GitHub Issues
- 📖 Documentation: GitHub Wiki

## 🙏 Credits

Created with ❤️ for the iOS development community

---

**Made by Mohamed Elboraey**
