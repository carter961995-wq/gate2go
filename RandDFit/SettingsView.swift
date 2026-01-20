import SwiftUI
import PhotosUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var settings: Gate2GoSettings
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showDeleteAlert = false
    @State private var showResetAlert = false
    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            Form {
                subscriptionSection
                defaultsSection
                brandingSection
                dataSection
            }
            .navigationTitle("Settings")
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            HStack {
                Text("Status")
                Spacer()
                Text(settings.isPremium ? "Active" : "Inactive")
                    .foregroundStyle(settings.isPremium ? .green : .secondary)
            }

            HStack {
                Text("Plan")
                Spacer()
                Text(settings.isPremium ? "Gate2Go Pro" : "Free")
            }

            if settings.singleDesignCredits > 0 {
                HStack {
                    Text("Design Credits")
                    Spacer()
                    Text("\(settings.singleDesignCredits)")
                        .foregroundStyle(.blue)
                }
            }

            Button(action: restorePurchases) {
                HStack {
                    if isRestoring {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text("Restore Purchases")
                }
            }
            .disabled(isRestoring)
        }
    }

    private var defaultsSection: some View {
        Section("Defaults") {
            HStack {
                Text("Markup %")
                Spacer()
                TextField("30", value: $settings.defaultMarkupPercent, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Labor (cents)")
                Spacer()
                TextField("50000", value: $settings.defaultLaborCents, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Tax %")
                Spacer()
                TextField("0", value: $settings.defaultTaxPercent, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }

    private var brandingSection: some View {
        Section("Branding (Proposal)") {
            HStack {
                Text("Company Logo")
                Spacer()

                if let logoData = settings.companyLogoData,
                   let uiImage = UIImage(data: logoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        settings.companyLogoData = data
                    }
                }
            }

            if settings.companyLogoData != nil {
                Button("Remove Logo", role: .destructive) {
                    settings.companyLogoData = nil
                }
            }

            TextField("Company name", text: $settings.brandingCompanyName)
            TextField("Phone", text: $settings.brandingPhone)
                .keyboardType(.phonePad)
            TextField("Email", text: $settings.brandingEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button("Reset Onboarding") {
                settings.hasCompletedOnboarding = false
            }

            Button("Delete All Data", role: .destructive) {
                showDeleteAlert = true
            }
            .alert("Delete All Data", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {}
            } message: {
                Text("This will permanently delete all your projects and designs.")
            }

            Button("Reset Entire App", role: .destructive) {
                showResetAlert = true
            }
            .alert("Reset Entire App", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset Everything", role: .destructive) {
                    settings.resetAll()
                }
            } message: {
                Text("This will reset all settings and clear subscription status.")
            }
        }
    }

    private func restorePurchases() {
        isRestoring = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRestoring = false
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Gate2GoSettings())
}

