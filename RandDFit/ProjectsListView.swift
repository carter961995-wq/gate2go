import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProjectModel.updatedAt, order: .reverse) private var projects: [ProjectModel]

    @State private var query: String = ""

    var filteredProjects: [ProjectModel] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return projects }
        return projects.filter { $0.name.localizedCaseInsensitiveContains(q) || ($0.clientName ?? "").localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        List {
            if filteredProjects.isEmpty {
                ContentUnavailableView("No Projects", systemImage: "folder", description: Text("Tap “New Project” to start."))
            } else {
                ForEach(filteredProjects) { project in
                    NavigationLink(value: Route.workspace(project.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.name)
                                .font(.headline)
                            if let client = project.clientName, !client.isEmpty {
                                Text(client)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Text(project.updatedAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onDelete(perform: deleteProjects)
            }
        }
        .navigationTitle("Projects")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: Route.settings) {
                    Image(systemName: "gearshape")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.newProject) {
                    Label("New Project", systemImage: "plus")
                }
            }
        }
    }

    private func deleteProjects(offsets: IndexSet) {
        withAnimation {
            for idx in offsets {
                let p = filteredProjects[idx]
                modelContext.delete(p)
            }
        }
    }
}

enum Route: Hashable {
    case newProject
    case workspace(String)
    case gallery(String)
    case designDetail(designId: String, projectId: String)
    case settings
}

#Preview {
    NavigationStack {
        ProjectsListView()
    }
    .modelContainer(for: [ProjectModel.self, GateDesignModel.self], inMemory: true)
}

