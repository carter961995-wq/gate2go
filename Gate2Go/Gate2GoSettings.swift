import SwiftUI

enum SubscriptionTier: String, CaseIterable {
    case essential
    case premium
}

enum SubscriptionPlan: String, CaseIterable {
    case none
    case monthly
    case yearly
    case lifetime

    var displayName: String {
        switch self {
        case .none: return "None"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    var priceText: String {
        switch self {
        case .none: return ""
        case .monthly: return "$9.99 / month"
        case .yearly: return "$79.99 / year"
        case .lifetime: return "$199.99 one-time"
        }
    }
}

class Gate2GoSettings: ObservableObject {
    @AppStorage("subscriptionTier") var subscriptionTier: SubscriptionTier = .essential
    @AppStorage("subscriptionPlan") var subscriptionPlan: SubscriptionPlan = .none
    @AppStorage("singleDesignCredits") var singleDesignCredits: Int = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("hasActiveSubscription") var hasActiveSubscription: Bool = false
    @AppStorage("demoModeEnabled") var demoModeEnabled: Bool = true

    @AppStorage("defaultLaborCents") var defaultLaborCents: Int = 50000
    @AppStorage("defaultMarkupPercent") var defaultMarkupPercent: Double = 30
    @AppStorage("defaultTaxPercent") var defaultTaxPercent: Double = 0

    @AppStorage("brandingCompanyName") var brandingCompanyName: String = ""
    @AppStorage("brandingPhone") var brandingPhone: String = ""
    @AppStorage("brandingEmail") var brandingEmail: String = ""
    @Published var companyLogoData: Data?

    var isPremium: Bool {
        subscriptionTier == .premium || hasActiveSubscription
    }

    var canCreateDesign: Bool {
        isPremium || singleDesignCredits > 0
    }

    func useSingleDesignCredit() {
        if singleDesignCredits > 0 {
            singleDesignCredits -= 1
        }
    }

    func resetAll() {
        subscriptionTier = .essential
        subscriptionPlan = .none
        singleDesignCredits = 0
        hasCompletedOnboarding = false
        hasActiveSubscription = false
        demoModeEnabled = true
        defaultLaborCents = 50000
        defaultMarkupPercent = 30
        defaultTaxPercent = 0
        brandingCompanyName = ""
        brandingPhone = ""
        brandingEmail = ""
        companyLogoData = nil
    }
}

