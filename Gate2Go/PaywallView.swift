import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var settings: Gate2GoSettings
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var isBuyingSingle = false
    @State private var isRestoring = false
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var showDemoAlert = false

    private let proPlans: [SubscriptionPlan] = [.monthly, .yearly, .lifetime]

    private let essentialFeatures = [
        "3 gate styles",
        "Wood & Steel materials",
        "Pricing calculator",
        "Save design versions"
    ]

    private let proFeatures = [
        "All gate styles and materials",
        "Live visual gate preview",
        "Unlimited projects & proposals",
        "Priority support"
    ]

    private let singleFeatures = [
        ("checkmark", "Create 1 complete gate design"),
        ("doc.text", "Generate professional PDF proposal"),
        ("square.and.arrow.up", "Share with your client")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    proSection
                    divider
                    singleDesignSection
                    demoModeSection
                    restoreButton
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if settings.subscriptionPlan != .none {
                    selectedPlan = settings.subscriptionPlan
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Demo Mode Disabled", isPresented: $showDemoAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Enable Demo Mode in Settings to simulate purchases.")
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Choose Your Option")
                .font(.title.bold())

            Text("Design professional gates and create proposals for your clients.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var proSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "star.circle.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)

                VStack(alignment: .leading) {
                    Text("Gate2Go Pro")
                        .font(.headline)
                    Text("For contractors and professionals")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 12) {
                ForEach(proPlans, id: \.self) { plan in
                    planRow(for: plan)
                }
            }

            Button(action: subscribeToPro) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Start \(selectedPlan.displayName) Plan")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)

            comparisonSection
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
        )
    }

    private func planRow(for plan: SubscriptionPlan) -> some View {
        Button(action: { selectedPlan = plan }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(plan.displayName)
                            .font(.headline)
                        if plan == .yearly {
                            Text("Save 33%")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    Text(plan.priceText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPlan == plan ? .blue : .secondary)
            }
            .padding()
            .background(selectedPlan == plan ? Color.blue.opacity(0.15) : Color(.systemGray5))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        HStack {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
            Text("or")
                .font(.caption)
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
        }
    }

    private var singleDesignSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "house.circle.fill")
                    .font(.title)
                    .foregroundStyle(.green)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Single Design")
                            .font(.headline)
                        Spacer()
                        Text("$2.99")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    Text("Perfect for homeowners")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(singleFeatures, id: \.1) { icon, label in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text(label)
                            .font(.subheadline)
                    }
                }
            }

            Button(action: buySingleDesign) {
                if isBuyingSingle {
                    ProgressView()
                        .tint(.blue)
                } else {
                    Text("Buy Single Design - $2.99")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .disabled(isBuyingSingle)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plan Comparison")
                .font(.headline)

            HStack(alignment: .top, spacing: 16) {
                featureColumn(title: "Essential", features: essentialFeatures, color: .gray)
                featureColumn(title: "Pro", features: proFeatures, color: .blue)
            }
        }
    }

    private func featureColumn(title: String, features: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(color)

            ForEach(features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(color)
                    Text(feature)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var demoModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $settings.demoModeEnabled) {
                Text("Demo Mode (simulated purchases)")
                    .font(.subheadline.weight(.medium))
            }
            Text("Disable Demo Mode before connecting real StoreKit.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var restoreButton: some View {
        Button(action: restorePurchases) {
            if isRestoring {
                ProgressView()
            } else {
                Text("Restore Purchases")
                    .font(.footnote)
            }
        }
        .foregroundStyle(.blue)
        .padding(.top, 8)
        .disabled(isRestoring)
    }

    private func subscribeToPro() {
        guard settings.demoModeEnabled else {
            showDemoAlert = true
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            settings.subscriptionTier = .premium
            settings.subscriptionPlan = selectedPlan
            settings.hasActiveSubscription = true
            isLoading = false
            dismiss()
        }
    }

    private func buySingleDesign() {
        guard settings.demoModeEnabled else {
            showDemoAlert = true
            return
        }
        isBuyingSingle = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            settings.singleDesignCredits += 1
            isBuyingSingle = false
            dismiss()
        }
    }

    private func restorePurchases() {
        guard settings.demoModeEnabled else {
            showDemoAlert = true
            return
        }
        isRestoring = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if settings.subscriptionPlan == .none {
                settings.subscriptionPlan = .monthly
            }
            settings.subscriptionTier = .premium
            settings.hasActiveSubscription = true
            isRestoring = false
            dismiss()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(Gate2GoSettings())
}

