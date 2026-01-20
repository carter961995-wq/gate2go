import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var settings: Gate2GoSettings
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var isBuyingSingle = false
    @State private var isRestoring = false

    private let proFeatures = [
        ("square.grid.2x2", "All gate styles and materials"),
        ("photo", "Visual designer with live preview"),
        ("doc.text", "Unlimited projects and proposals"),
        ("star", "Priority support")
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
                    restoreButton
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
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

            VStack(alignment: .leading, spacing: 10) {
                ForEach(proFeatures, id: \.1) { icon, label in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text(label)
                            .font(.subheadline)
                    }
                }
            }

            Button(action: subscribeToPro) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("View Pro Plans")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
        )
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
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            settings.subscriptionTier = .premium
            isLoading = false
            dismiss()
        }
    }

    private func buySingleDesign() {
        isBuyingSingle = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            settings.singleDesignCredits += 1
            isBuyingSingle = false
            dismiss()
        }
    }

    private func restorePurchases() {
        isRestoring = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isRestoring = false
            dismiss()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(Gate2GoSettings())
}

