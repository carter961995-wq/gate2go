import SwiftUI
import SwiftData

struct DesignGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allDesigns: [GateDesignModel]
    let projectId: String

    var designs: [GateDesignModel] {
        allDesigns.filter { $0.projectId == projectId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        Group {
            if designs.isEmpty {
                emptyState
            } else {
                designsList
            }
        }
        .navigationTitle("Design Versions")
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Designs Yet")
                .font(.title2.bold())

            Text("Save a design version to see it here")
                .foregroundStyle(.secondary)
        }
    }

    private var designsList: some View {
        List {
            ForEach(designs) { design in
                NavigationLink(destination: DesignDetailView(design: design)) {
                    DesignRow(design: design)
                }
            }
            .onDelete(perform: deleteDesigns)
        }
    }

    private func deleteDesigns(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(designs[index])
        }
    }
}

struct DesignRow: View {
    let design: GateDesignModel

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "door.garage.closed")
                        .foregroundStyle(.secondary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(GateStyle(rawValue: design.gateStyle)?.displayName ?? "Gate")
                    .font(.headline)

                Text("\(design.widthFeet)' x \(design.heightFeet)' • \(Material(rawValue: design.material)?.displayName ?? "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(PricingCalculator.formatMoney(design.totalPriceCents))
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
            }

            Spacer()

            if design.selectedByClient {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        DesignGalleryView(projectId: "test")
    }
    .modelContainer(for: GateDesignModel.self)
}

