import SwiftUI
import SwiftData
import UIKit

struct DesignDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: Gate2GoSettings
    @Bindable var design: GateDesignModel

    @State private var showShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                previewSection
                specsSection
                pricingSection
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Design Details")
        .sheet(isPresented: $showShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(activityItems: [pdfData])
            }
        }
    }

    private var previewSection: some View {
        GateDesignerView(
            widthFeet: design.widthFeet,
            heightFeet: design.heightFeet,
            material: Material(rawValue: design.material) ?? .steel,
            gateStyle: GateStyle(rawValue: design.gateStyle) ?? .singleSwing
        )
    }

    private var specsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specifications")
                .font(.headline)

            VStack(spacing: 8) {
                specRow("Style", value: GateStyle(rawValue: design.gateStyle)?.displayName ?? "")
                specRow("Material", value: Material(rawValue: design.material)?.displayName ?? "")
                specRow("Width", value: "\(design.widthFeet) ft")
                specRow("Height", value: "\(design.heightFeet) ft")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private func specRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }

    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pricing")
                .font(.headline)

            VStack(spacing: 8) {
                specRow("Base Price", value: PricingCalculator.formatMoney(design.basePriceCents))
                specRow("Labor", value: PricingCalculator.formatMoney(design.laborCents))
                specRow("Markup", value: "\(Int(design.markupPercent))%")
                specRow("Tax", value: "\(Int(design.taxPercent))%")

                Divider()

                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(PricingCalculator.formatMoney(design.totalPriceCents))
                        .font(.title3.bold())
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Toggle("Selected by Client", isOn: $design.selectedByClient)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Button(action: exportPDF) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Export Proposal PDF")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Button(action: duplicateDesign) {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Duplicate Design")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
        }
    }

    private func exportPDF() {
        // Note: Need project data for full PDF generation
        // This is a simplified version
        showShareSheet = true
    }

    private func duplicateDesign() {
        let newDesign = GateDesignModel(
            projectId: design.projectId,
            gateStyle: design.gateStyle,
            material: design.material,
            widthFeet: design.widthFeet,
            heightFeet: design.heightFeet,
            basePriceCents: design.basePriceCents,
            totalPriceCents: design.totalPriceCents,
            laborCents: design.laborCents,
            markupPercent: design.markupPercent,
            taxPercent: design.taxPercent
        )
        modelContext.insert(newDesign)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let design = GateDesignModel(projectId: "test")
    return NavigationStack {
        DesignDetailView(design: design)
    }
    .modelContainer(for: GateDesignModel.self)
    .environmentObject(Gate2GoSettings())
}

