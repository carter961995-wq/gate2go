import SwiftUI
import SwiftData
import UIKit

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProjectModel.updatedAt, order: .reverse) private var projects: [ProjectModel]
    @State private var searchText = ""
    @State private var showNewProject = false

    var filteredProjects: [ProjectModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return projects
        }
        return projects.filter {
            $0.clientName.localizedCaseInsensitiveContains(trimmed) ||
            $0.siteAddress.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    emptyState
                } else {
                    projectsList
                }
            }
            .navigationTitle("Projects")
            .searchable(text: $searchText, prompt: "Search projects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNewProject = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewProject) {
                NewProjectView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Projects Yet")
                .font(.title2.bold())

            Text("Create your first project to get started")
                .foregroundStyle(.secondary)

            Button("New Project") {
                showNewProject = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var projectsList: some View {
        List {
            ForEach(filteredProjects) { project in
                NavigationLink(destination: ProjectWorkspaceView(project: project)) {
                    ProjectRow(project: project)
                }
            }
            .onDelete(perform: deleteProjects)
        }
    }

    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredProjects[index])
        }
    }
}

struct ProjectRow: View {
    let project: ProjectModel

    var body: some View {
        HStack(spacing: 12) {
            if let photoData = project.sitePhotoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(project.clientName.isEmpty ? "Untitled Project" : project.clientName)
                    .font(.headline)

                Text(project.siteAddress.isEmpty ? "No address" : project.siteAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Updated \(project.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProjectsListView()
        .modelContainer(for: [ProjectModel.self, GateDesignModel.self])
        .environmentObject(Gate2GoSettings())
}

