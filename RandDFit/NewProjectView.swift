import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct NewProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var projectName: String = ""
    @State private var clientName: String = ""
    @State private var clientPhone: String = ""
    @State private var clientEmail: String = ""
    @State private var notes: String = ""

    @State private var pickedPhotoItem: PhotosPickerItem?
    @State private var photoPath: String?
    @State private var photoPreview: Image?

    @State private var createdProjectId: String?
    @State private var goToWorkspace: Bool = false

    var body: some View {
        Form {
            Section("Jobsite Photo (required)") {
                VStack(alignment: .leading, spacing: 12) {
                    PhotosPicker(selection: $pickedPhotoItem, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.secondary.opacity(0.12))
                            if let photoPreview {
                                photoPreview
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            } else {
                                VStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.title2)
                                    Text("Tap to select photo")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(height: 200)
                    }

                    if photoPath == nil {
                        Text("A jobsite photo is required to start a project.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Project") {
                TextField("Project name", text: $projectName)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Client (optional)") {
                TextField("Client name", text: $clientName)
                TextField("Phone", text: $clientPhone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $clientEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section {
                Button("Create Project") { createProject() }
                    .disabled(!canCreate)
            }
        }
        .navigationTitle("New Project")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: pickedPhotoItem) { await loadPhoto() }
        .background(
            NavigationLink(
                destination: Group {
                    if let createdProjectId {
                        ProjectWorkspaceView(projectId: createdProjectId)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $goToWorkspace
            ) { EmptyView() }
                .hidden()
        )
    }

    private var canCreate: Bool {
        let nameOK = !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return nameOK && photoPath != nil
    }

    private func loadPhoto() async {
        guard let pickedPhotoItem else { return }
        do {
            if let data = try await pickedPhotoItem.loadTransferable(type: Data.self),
               let ui = UIImage(data: data) {
                let fileName = "project_\(UUID().uuidString).jpg"
                let path = try FileStore.writeJPEG(ui, fileName: fileName, subdirectory: "projects/photos")
                await MainActor.run {
                    photoPath = path
                    photoPreview = Image(uiImage: ui)
                }
            }
        } catch {
            // MVP: silently fail; user can retry pick.
            await MainActor.run {
                photoPath = nil
                photoPreview = nil
            }
        }
    }

    private func createProject() {
        guard let photoPath else { return }

        let now = Date()
        let p = ProjectModel(
            name: projectName.trimmingCharacters(in: .whitespacesAndNewlines),
            clientName: clientName.nilIfEmpty,
            clientPhone: clientPhone.nilIfEmpty,
            clientEmail: clientEmail.nilIfEmpty,
            notes: notes.nilIfEmpty,
            sitePhotoPath: photoPath,
            createdAt: now,
            updatedAt: now
        )
        modelContext.insert(p)
        createdProjectId = p.id
        goToWorkspace = true
    }
}

private extension String {
    var nilIfEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}

#Preview {
    NavigationStack {
        NewProjectView()
    }
    .modelContainer(for: [ProjectModel.self, GateDesignModel.self], inMemory: true)
}

