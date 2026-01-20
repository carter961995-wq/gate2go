import SwiftUI

struct AddOnPickerView: View {
    @Binding var addons: [AddonLineItem]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(AddonType.allCases, id: \.self) { addonType in
                AddOnRow(
                    addonType: addonType,
                    isEnabled: isAddonEnabled(addonType),
                    quantity: getQuantity(addonType),
                    onToggle: { toggleAddon(addonType) },
                    onQuantityChange: { newQty in updateQuantity(addonType, quantity: newQty) }
                )
            }
        }
    }

    private func isAddonEnabled(_ type: AddonType) -> Bool {
        addons.contains { $0.type == type }
    }

    private func getQuantity(_ type: AddonType) -> Int {
        addons.first { $0.type == type }?.quantity ?? 1
    }

    private func toggleAddon(_ type: AddonType) {
        if let index = addons.firstIndex(where: { $0.type == type }) {
            addons.remove(at: index)
        } else {
            addons.append(AddonLineItem(
                type: type,
                quantity: 1,
                priceCents: type.defaultPriceCents
            ))
        }
    }

    private func updateQuantity(_ type: AddonType, quantity: Int) {
        if let index = addons.firstIndex(where: { $0.type == type }) {
            addons[index].quantity = max(1, quantity)
        }
    }
}

struct AddOnRow: View {
    let addonType: AddonType
    let isEnabled: Bool
    let quantity: Int
    let onToggle: () -> Void
    let onQuantityChange: (Int) -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Toggle(isOn: Binding(
                    get: { isEnabled },
                    set: { _ in onToggle() }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(addonType.displayName)
                            .font(.subheadline.weight(.medium))
                        Text(formatMoney(addonType.defaultPriceCents))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if isEnabled {
                HStack {
                    Text("Quantity")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Stepper("\(quantity)", value: Binding(
                        get: { quantity },
                        set: { onQuantityChange($0) }
                    ), in: 1...10)
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func formatMoney(_ cents: Int) -> String {
        let dollars = Double(cents) / 100
        return String(format: "$%.2f", dollars)
    }
}

#Preview {
    AddOnPickerView(addons: .constant([]))
}
