import SwiftUI
import PDFKit
import UIKit

class ProposalGenerator {

    static func generatePDF(
        project: ProjectModel,
        design: GateDesignModel,
        settings: Gate2GoSettings
    ) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfMetaData = [
            kCGPDFContextCreator: "Gate2Go",
            kCGPDFContextAuthor: settings.brandingCompanyName,
            kCGPDFContextTitle: "Gate Proposal - \(project.clientName)"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            if let logoData = settings.companyLogoData,
               let logoImage = UIImage(data: logoData) {
                let logoSize: CGFloat = 60
                let logoRect = CGRect(x: margin, y: yPosition, width: logoSize, height: logoSize)
                logoImage.draw(in: logoRect)
                yPosition += logoSize + 10
            }

            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let title = "Gate Proposal"
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40

            let normalFont = UIFont.systemFont(ofSize: 12)
            let normalAttributes: [NSAttributedString.Key: Any] = [.font: normalFont]

            if !settings.brandingCompanyName.isEmpty {
                settings.brandingCompanyName.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
                yPosition += 20
            }

            if !settings.brandingPhone.isEmpty {
                settings.brandingPhone.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
                yPosition += 20
            }

            if !settings.brandingEmail.isEmpty {
                settings.brandingEmail.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
                yPosition += 30
            }

            yPosition += 20

            let sectionFont = UIFont.boldSystemFont(ofSize: 16)
            let sectionAttributes: [NSAttributedString.Key: Any] = [.font: sectionFont]

            "Client Information".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25

            "Name: \(project.clientName)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 18

            if !project.clientPhone.isEmpty {
                "Phone: \(project.clientPhone)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
                yPosition += 18
            }

            if !project.siteAddress.isEmpty {
                "Address: \(project.siteAddress)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
                yPosition += 18
            }

            yPosition += 30

            "Gate Specifications".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25

            let gateStyle = GateStyle(rawValue: design.gateStyle)?.displayName ?? design.gateStyle
            let material = Material(rawValue: design.material)?.displayName ?? design.material
            let addons = decodeAddons(from: design.addonsData)
            let addonsTotalCents = addons.reduce(0) { $0 + $1.totalCents }
            let subtotalCents = design.basePriceCents + addonsTotalCents + design.laborCents
            let markupCents = Int(Double(subtotalCents) * design.markupPercent / 100)
            let taxCents = Int(Double(subtotalCents + markupCents) * design.taxPercent / 100)
            let totalCents = design.totalPriceCents > 0 ? design.totalPriceCents : (subtotalCents + markupCents + taxCents)

            "Style: \(gateStyle)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 18

            "Material: \(material)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 18

            "Dimensions: \(design.widthFeet)' W x \(design.heightFeet)' H".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 30

            "Pricing".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 25

            "Base Price: \(PricingCalculator.formatMoney(design.basePriceCents))".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 18

            if addonsTotalCents > 0 {
                "Add-ons: \(PricingCalculator.formatMoney(addonsTotalCents))".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
                yPosition += 18

                for addon in addons {
                    let line = "• \(addon.type.displayName) x\(addon.quantity) — \(PricingCalculator.formatMoney(addon.totalCents))"
                    line.draw(at: CGPoint(x: margin + 8, y: yPosition), withAttributes: normalAttributes)
                    yPosition += 16
                }
            }

            "Labor: \(PricingCalculator.formatMoney(design.laborCents))".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 18

            "Markup (\(Int(design.markupPercent))%): \(PricingCalculator.formatMoney(markupCents))".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 18

            "Tax (\(Int(design.taxPercent))%): \(PricingCalculator.formatMoney(taxCents))".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 25

            let totalFont = UIFont.boldSystemFont(ofSize: 18)
            let totalAttributes: [NSAttributedString.Key: Any] = [.font: totalFont]
            "Total: \(PricingCalculator.formatMoney(totalCents))".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: totalAttributes)
            yPosition += 50

            let footerFont = UIFont.italicSystemFont(ofSize: 10)
            let footerAttributes: [NSAttributedString.Key: Any] = [.font: footerFont, .foregroundColor: UIColor.gray]
            let footer = "Generated by Gate2Go on \(Date().formatted(date: .abbreviated, time: .omitted))"
            footer.draw(at: CGPoint(x: margin, y: pageHeight - margin), withAttributes: footerAttributes)
        }

        return data
    }

    private static func decodeAddons(from data: Data?) -> [AddonLineItem] {
        guard let data else { return [] }
        return (try? JSONDecoder().decode([AddonLineItem].self, from: data)) ?? []
    }
}
