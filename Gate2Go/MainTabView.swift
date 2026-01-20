import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ProjectsListView()
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(Gate2GoSettings())
}
