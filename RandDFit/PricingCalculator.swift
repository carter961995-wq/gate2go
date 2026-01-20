import Foundation

struct PricingCalculator {

    static func calculateBasePrice(
        gateStyle: GateStyle,
        material: Material,
        widthFeet: Int,
        heightFeet: Int
    ) -> Int {
        let squareFeet = widthFeet * heightFeet

        var basePricePerSqFt: Int
        switch material {
        case .wood:
            basePricePerSqFt = 2000
        case .steel:
            basePricePerSqFt = 2500
        case .chainLink:
            basePricePerSqFt = 1500
        case .aluminum:
            basePricePerSqFt = 3000
        }

        var styleMultiplier: Double = 1.0
        switch gateStyle {
        case .singleSwing:
            styleMultiplier = 1.0
        case .doubleSwing:
            styleMultiplier = 1.3
        case .rollGate:
            styleMultiplier = 1.4
        case .cantileverSlide:
            styleMultiplier = 1.6
        case .overheadTrack:
            styleMultiplier = 1.8
        case .verticalPivot:
            styleMultiplier = 2.0
        }

        return Int(Double(squareFeet * basePricePerSqFt) * styleMultiplier)
    }

    static func calculateTotalPrice(
        basePriceCents: Int,
        addons: [AddonLineItem],
        laborCents: Int,
        markupPercent: Double,
        taxPercent: Double
    ) -> Int {
        let addonsCents = addons.reduce(0) { $0 + $1.totalCents }
        let subtotal = basePriceCents + addonsCents + laborCents
        let markup = Int(Double(subtotal) * markupPercent / 100)
        let tax = Int(Double(subtotal + markup) * taxPercent / 100)
        return subtotal + markup + tax
    }

    static func formatMoney(_ cents: Int) -> String {
        let dollars = Double(cents) / 100
        return String(format: "$%.2f", dollars)
    }
}

