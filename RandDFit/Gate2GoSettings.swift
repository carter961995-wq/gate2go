import Foundation
import SwiftUI
import Combine

@MainActor
final class Gate2GoSettings: ObservableObject {
    nonisolated let objectWillChange = ObservableObjectPublisher()

    @AppStorage("g2g_hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false { willSet { objectWillChange.send() } }

    /// MVP “store-managed” placeholder. In V1 we wire StoreKit2 products here.
    @AppStorage("g2g_hasActiveSubscription") var hasActiveSubscription: Bool = false { willSet { objectWillChange.send() } }
    @AppStorage("g2g_subscriptionTier") private var subscriptionTierRaw: String = SubscriptionTier.essential.rawValue { willSet { objectWillChange.send() } }

    /// Defaults used in Options + Price.
    @AppStorage("g2g_defaultMarkupPercent") var defaultMarkupPercent: Double = 30 { willSet { objectWillChange.send() } }
    @AppStorage("g2g_defaultLaborCents") var defaultLaborCents: Int = 0 { willSet { objectWillChange.send() } }
    @AppStorage("g2g_defaultTaxPercent") var defaultTaxPercent: Double = 0 { willSet { objectWillChange.send() } }

    /// Proposal branding (V1).
    @AppStorage("g2g_brandingCompanyName") var brandingCompanyName: String = "" { willSet { objectWillChange.send() } }
    @AppStorage("g2g_brandingPhone") var brandingPhone: String = "" { willSet { objectWillChange.send() } }
    @AppStorage("g2g_brandingEmail") var brandingEmail: String = "" { willSet { objectWillChange.send() } }

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

