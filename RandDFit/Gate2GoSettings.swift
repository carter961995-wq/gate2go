import Foundation
import SwiftUI

final class Gate2GoSettings: ObservableObject {
    @AppStorage("g2g_hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    /// MVP “store-managed” placeholder. In V1 we wire StoreKit2 products here.
    @AppStorage("g2g_hasActiveSubscription") var hasActiveSubscription: Bool = false
    @AppStorage("g2g_subscriptionTier") private var subscriptionTierRaw: String = SubscriptionTier.essential.rawValue

    /// Defaults used in Options + Price.
    @AppStorage("g2g_defaultMarkupPercent") var defaultMarkupPercent: Double = 30
    @AppStorage("g2g_defaultLaborCents") var defaultLaborCents: Int = 0
    @AppStorage("g2g_defaultTaxPercent") var defaultTaxPercent: Double = 0

    /// Proposal branding (V1).
    @AppStorage("g2g_brandingCompanyName") var brandingCompanyName: String = ""
    @AppStorage("g2g_brandingPhone") var brandingPhone: String = ""
    @AppStorage("g2g_brandingEmail") var brandingEmail: String = ""

    var subscriptionTier: SubscriptionTier {
        get { SubscriptionTier(rawValue: subscriptionTierRaw) ?? .essential }
        set { subscriptionTierRaw = newValue.rawValue }
    }

    func isPremiumLocked(_ tierRequired: SubscriptionTier) -> Bool {
        switch tierRequired {
        case .essential:
            return false
        case .premium:
            return !(hasActiveSubscription && subscriptionTier == .premium)
        }
    }
}

