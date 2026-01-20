import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: Gate2GoSettings
    @State private var showPaywall = false

    var body: some View {
        Group {
            if !settings.hasCompletedOnboarding {
                OnboardingView()
            } else if !settings.isPremium && settings.singleDesignCredits == 0 {
                MainTabView()
                    .sheet(isPresented: $showPaywall) {
                        PaywallView()
                    }
                    .onAppear {
                        showPaywall = true
                    }
            } else {
                MainTabView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Gate2GoSettings())
}
