import SwiftUI
import Photos
import UserNotifications

struct OnboardingView: View {
    @EnvironmentObject private var settings: Gate2GoSettings
    @State private var page: Int = 0

    @State private var photoStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    @State private var notificationsGranted: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                OnboardingSlide(
                    title: "Design gates on-site",
                    bodyText: "Take a jobsite photo, choose a style + material, then customize with visual cards.",
                    systemImage: "camera.viewfinder"
                )
                .tag(0)

                OnboardingSlide(
                    title: "Upsells + pricing",
                    bodyText: "Add options like keypad, latch, drop rod, and (Premium) openers—then export a proposal.",
                    systemImage: "list.bullet.rectangle.portrait"
                )
                .tag(1)

                permissionsSlide
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            HStack {
                Button("Back") { withAnimation { page = max(0, page - 1) } }
                    .opacity(page == 0 ? 0 : 1)
                    .disabled(page == 0)

                Spacer()

                Button(page == 2 ? "Get Started" : "Next") {
                    if page < 2 {
                        withAnimation { page += 1 }
                    } else {
                        settings.hasCompletedOnboarding = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await refreshNotificationsStatus()
        }
    }

    private var permissionsSlide: some View {
        OnboardingSlide(
            title: "Permissions",
            bodyText: "Gate2Go needs photo access to import jobsite images, and notifications for proposal follow-ups (optional).",
            systemImage: "hand.raised"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                PermissionRow(
                    title: "Photos",
                    statusText: photoStatusText(photoStatus),
                    actionTitle: photoButtonTitle(photoStatus),
                    isActionDisabled: photoStatus == .authorized || photoStatus == .limited
                ) {
                    Task {
                        let new = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                        await MainActor.run { photoStatus = new }
                    }
                }

                PermissionRow(
                    title: "Notifications (optional)",
                    statusText: notificationsGranted ? "Enabled" : "Not enabled",
                    actionTitle: notificationsGranted ? "Enabled" : "Enable",
                    isActionDisabled: notificationsGranted
                ) {
                    Task {
                        do {
                            let granted = try await UNUserNotificationCenter.current()
                                .requestAuthorization(options: [.alert, .sound, .badge])
                            await MainActor.run { notificationsGranted = granted }
                        } catch {
                            await MainActor.run { notificationsGranted = false }
                        }
                    }
                }
            }
            .padding(.top, 6)
        }
    }

    private func refreshNotificationsStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            notificationsGranted = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
        }
    }

    private func photoStatusText(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Full access"
        case .limited: return "Limited access"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not set"
        @unknown default: return "Unknown"
        }
    }

    private func photoButtonTitle(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized, .limited: return "Enabled"
        case .denied, .restricted: return "Open Settings"
        case .notDetermined: return "Enable"
        @unknown default: return "Enable"
        }
    }
}

private struct OnboardingSlide<Content: View>: View {
    let title: String
    let bodyText: String
    let systemImage: String
    let content: Content

    init(title: String, bodyText: String, systemImage: String, @ViewBuilder content: () -> Content = { EmptyView() }) {
        self.title = title
        self.bodyText = bodyText
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.tint)
                .padding(18)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(bodyText)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 26)

            content
                .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.vertical, 20)
    }
}

private struct PermissionRow: View {
    let title: String
    let statusText: String
    let actionTitle: String
    let isActionDisabled: Bool
    let action: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(statusText).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button(actionTitle, action: action)
                .buttonStyle(.bordered)
                .disabled(isActionDisabled)
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
            .environmentObject(Gate2GoSettings())
    }
}

