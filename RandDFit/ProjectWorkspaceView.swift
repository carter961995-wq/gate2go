import SwiftUI
import SwiftData

struct ProjectWorkspaceView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: Gate2GoSettings
    let project: ProjectModel

    @State private var selectedTab = 0
    @State private var gateStyle: GateStyle = .singleSwing
    @State private var material: Material = .steel
    @State private var widthFeet: Int = 12
    @State private var heightFeet: Int = 6
    @State private var addons: [AddonLineItem] = []

    var basePriceCents: Int {
        PricingCalculator.calculateBasePrice(
            gateStyle: gateStyle,
            material: material,
            widthFeet: widthFeet,
            heightFeet: heightFeet
        )
    }

    var addonsTotalCents: Int {
        addons.reduce(0) { $0 + $1.totalCents }
    }

    var laborCents: Int {
        settings.defaultLaborCents
    }

    var subtotalCents: Int {
        basePriceCents + addonsTotalCents + laborCents
    }

    var markupCents: Int {
        Int(Double(subtotalCents) * settings.defaultMarkupPercent / 100)
    }

    var taxCents: Int {
        Int(Double(subtotalCents + markupCents) * settings.defaultTaxPercent / 100)
    }

    var totalPriceCents: Int {
        subtotalCents + markupCents + taxCents
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Tab", selection: $selectedTab) {
                Text("Design").tag(0)
                Text("Options + Price").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                designTab
            } else {
                pricingTab
            }
        }
        .navigationTitle(project.clientName.isEmpty ? "Design" : project.clientName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: DesignGalleryView(projectId: project.id)) {
                    Image(systemName: "square.grid.2x2")
                }
            }
        }
    }

    private var designTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                gatePreview
                gateStyleSection
                materialSection
                sizeSection
            }
            .padding()
        }
    }

    private var gatePreview: some View {
        VStack(spacing: 8) {
            GateDesignerView(
                widthFeet: widthFeet,
                heightFeet: heightFeet,
                material: material,
                gateStyle: gateStyle
            )

            HStack {
                Text("\(gateStyle.displayName) • \(material.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(widthFeet)' W x \(heightFeet)' H")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var gateStyleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gate Style")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(GateStyle.allCases, id: \.self) { style in
                    let isLocked = style.tier == "premium" && !settings.isPremium

                    Button(action: {
                        if !isLocked {
                            gateStyle = style
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(style.displayName)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)

                            if style.tier == "premium" {
                                Text("Premium")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(gateStyle == style ? Color.blue.opacity(0.2) : Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(gateStyle == style ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .opacity(isLocked ? 0.5 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(isLocked)
                }
            }
        }
    }

    private var materialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Material")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Material.allCases, id: \.self) { mat in
                    let isLocked = mat.tier == "premium" && !settings.isPremium

                    Button(action: {
                        if !isLocked {
                            material = mat
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(mat.displayName)
                                .font(.subheadline)

                            if mat.tier == "premium" {
                                Text("Premium")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(material == mat ? Color.blue.opacity(0.2) : Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(material == mat ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .opacity(isLocked ? 0.5 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(isLocked)
                }
            }
        }
    }

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Size")
                .font(.headline)

            VStack(spacing: 16) {
                HStack {
                    Text("Width")
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: { widthFeet = max(4, widthFeet - 1) }) {
                            Image(systemName: "minus")
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        Text("\(widthFeet) ft")
                            .frame(width: 50)

                        Button(action: { widthFeet = min(30, widthFeet + 1) }) {
                            Image(systemName: "plus")
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    Text("Height")
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: { heightFeet = max(3, heightFeet - 1) }) {
                            Image(systemName: "minus")
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        Text("\(heightFeet) ft")
                            .frame(width: 50)

                        Button(action: { heightFeet = min(12, heightFeet + 1) }) {
                            Image(systemName: "plus")
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private var pricingTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                addonsSection
                pricingCard
                saveButton
            }
            .padding()
        }
    }

    private var addonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add-ons")
                .font(.headline)

            AddOnPickerView(addons: $addons)
        }
    }

    private var pricingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pricing")
                .font(.headline)

            VStack(spacing: 12) {
                pricingRow("Base Price", cents: basePriceCents)

                if addonsTotalCents > 0 {
                    pricingRow("Add-ons (\(addons.count))", cents: addonsTotalCents)
                }

                pricingRow("Labor", cents: laborCents)
                pricingRow("Markup (\(Int(settings.defaultMarkupPercent))%)", cents: markupCents)
                pricingRow("Tax (\(Int(settings.defaultTaxPercent))%)", cents: taxCents)

                Divider()

                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(PricingCalculator.formatMoney(totalPriceCents))
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private func pricingRow(_ label: String, cents: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(PricingCalculator.formatMoney(cents))
        }
    }

    private var saveButton: some View {
        Button(action: saveDesign) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Save Version")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    private func saveDesign() {
        let design = GateDesignModel(
            projectId: project.id,
            gateStyle: gateStyle.rawValue,
            material: material.rawValue,
            widthFeet: widthFeet,
            heightFeet: heightFeet,
            basePriceCents: basePriceCents,
            totalPriceCents: totalPriceCents,
            laborCents: laborCents,
            markupPercent: settings.defaultMarkupPercent,
            taxPercent: settings.defaultTaxPercent
        )
        modelContext.insert(design)

        if !settings.isPremium && settings.singleDesignCredits > 0 {
            settings.useSingleDesignCredit()
        }
    }
}

#Preview {
    let project = ProjectModel(clientName: "Test Client")
    return NavigationStack {
        ProjectWorkspaceView(project: project)
    }
    .modelContainer(for: [ProjectModel.self, GateDesignModel.self])
    .environmentObject(Gate2GoSettings())
}

