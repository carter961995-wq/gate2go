import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct NewProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var clientName = ""
    @State private var clientPhone = ""
    @State private var clientEmail = ""
    @State private var siteAddress = ""
    @State private var notes = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var sitePhotoData: Data?
    @State private var showCameraPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Client Info") {
                    TextField("Client Name", text: $clientName)
                    TextField("Phone", text: $clientPhone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $clientEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Site") {
                    TextField("Site Address", text: $siteAddress)

                    HStack {
                        Text("Site Photo")
                        Spacer()

                        if let photoData = sitePhotoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            HStack(spacing: 12) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                }

                                Button(action: { showCameraPicker = true }) {
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                }
                                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                            }
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                sitePhotoData = data
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        createProject()
                    }
                    .disabled(clientName.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(imageData: $sitePhotoData, sourceType: .camera)
        }
    }

    private func createProject() {
        let project = ProjectModel(
            clientName: clientName,
            clientPhone: clientPhone,
            clientEmail: clientEmail,
            siteAddress: siteAddress,
            sitePhotoData: sitePhotoData,
            notes: notes
        )
        modelContext.insert(project)
        dismiss()
    }
}

#Preview {
    NewProjectView()
        .modelContainer(for: ProjectModel.self)
}

