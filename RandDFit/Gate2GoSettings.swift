import SwiftUI

enum SubscriptionTier: String, CaseIterable {
    case essential
    case premium
}

class Gate2GoSettings: ObservableObject {
    @AppStorage("subscriptionTier") var subscriptionTier: SubscriptionTier = .essential
    @AppStorage("singleDesignCredits") var singleDesignCredits: Int = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("hasActiveSubscription") var hasActiveSubscription: Bool = false

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
        singleDesignCredits = 0
        hasCompletedOnboarding = false
        hasActiveSubscription = false
        defaultLaborCents = 50000
        defaultMarkupPercent = 30
        defaultTaxPercent = 0
        brandingCompanyName = ""
        brandingPhone = ""
        brandingEmail = ""
        companyLogoData = nil
    }
}

