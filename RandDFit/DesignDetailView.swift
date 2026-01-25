import SwiftUI
import SwiftData

struct DesignDetailView: View {
    let projectId: String
    let designId: String

    @Environment(\.modelContext) private var modelContext
    @Query private var designs: [GateDesignModel]
    @Query private var projects: [ProjectModel]

    @State private var showOriginal: Bool = false

    init(projectId: String, designId: String) {
        self.projectId = projectId
        self.designId = designId
        _designs = Query(filter: #Predicate<GateDesignModel> { $0.id == designId })
        _projects = Query(filter: #Predicate<ProjectModel> { $0.id == projectId })
    }

    var design: GateDesignModel? { designs.first }
    var project: ProjectModel? { projects.first }

    var body: some View {
        Group {
            if let design {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        imageBlock(design: design)

                        HStack {
                            Toggle("Selected by client", isOn: Binding(
                                get: { design.selectedByClient },
                                set: { newValue in
                                    design.selectedByClient = newValue
                                    design.updatedAt = Date()
                                }
                            ))
                        }
                        .padding(14)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(design.gateStyle.cardTitle) • \(design.material.cardTitle)")
                                .font(.title3.bold())
                            Text("Size: \(Int(design.widthFeet))' W × \(Int(design.heightFeet))' H")
                                .foregroundStyle(.secondary)
                            Text("Total: \(MoneyFormatting.dollarsString(cents: design.totalPriceCents))")
                                .font(.headline)
                        }
                        .padding(14)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        HStack(spacing: 12) {
                            Button("Duplicate & Edit") {
                                duplicate(design: design)
                            }
                            .buttonStyle(.bordered)

                            Button("Export") {
                                // Stub: proposal export wired later in Options + Price.
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Design Detail")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Design not found", systemImage: "questionmark.square")
            }
        }
    }

    @ViewBuilder
    private func imageBlock(design: GateDesignModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Render")
                    .font(.headline)
                Spacer()
                Toggle("Original", isOn: $showOriginal)
                    .labelsHidden()
            }
            .padding(.horizontal, 2)

            let path = showOriginal ? project?.sitePhotoPath : design.generatedImagePath
            if let path, let ui = FileStore.readUIImage(path: path) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))
                    .frame(height: 260)
                    .overlay(Text(showOriginal ? "Original photo unavailable" : "No generated render yet").foregroundStyle(.secondary))
            }
        }
    }

    private func duplicate(design: GateDesignModel) {
        let now = Date()
        let copy = GateDesignModel(
            projectId: design.projectId,
            gateStyle: design.gateStyle,
            material: design.material,
            widthFeet: design.widthFeet,
            heightFeet: design.heightFeet,
            params: design.params,
            addons: design.addons,
            basePriceCents: design.basePriceCents,
            totalPriceCents: design.totalPriceCents,
            generatedImagePath: design.generatedImagePath,
            thumbnailPath: design.thumbnailPath,
            selectedByClient: false,
            createdAt: now,
            updatedAt: now
        )
        modelContext.insert(copy)
    }
}

#Preview {
    NavigationStack {
        DesignDetailView(projectId: "p1", designId: "d1")
    }
    .modelContainer(for: [ProjectModel.self, GateDesignModel.self], inMemory: true)
}

