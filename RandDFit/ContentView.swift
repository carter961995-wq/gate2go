//
//  ContentView.swift
//  RandDFit
//
//  Created by Logan Carter on 1/9/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var settings: Gate2GoSettings

    var body: some View {
        NavigationStack {
            Group {
                if !settings.hasCompletedOnboarding {
                    OnboardingView()
                } else if !settings.hasActiveSubscription {
                    PaywallView()
                } else {
                    ProjectsListView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .newProject:
                    NewProjectView()
                case .workspace(let projectId):
                    ProjectWorkspaceView(projectId: projectId)
                case .settings:
                    SettingsView()
                case .gallery(let projectId):
                    DesignGalleryView(projectId: projectId)
                case .designDetail(let designId, let projectId):
                    DesignDetailView(projectId: projectId, designId: designId)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Gate2GoSettings())
        .modelContainer(for: [ProjectModel.self, GateDesignModel.self], inMemory: true)
}
