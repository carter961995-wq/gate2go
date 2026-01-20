import Foundation

enum MoneyFormatting {
    static func dollarsString(cents: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = 2
        return nf.string(from: NSNumber(value: Double(cents) / 100.0)) ?? "$0.00"
    }
}

