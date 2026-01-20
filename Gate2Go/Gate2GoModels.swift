import SwiftUI
import SwiftData

enum GateStyle: String, Codable, CaseIterable {
    case singleSwing = "single_swing"
    case doubleSwing = "double_swing"
    case rollGate = "roll_gate"
    case cantileverSlide = "cantilever_slide"
    case overheadTrack = "overhead_track"
    case verticalPivot = "vertical_pivot"

    var displayName: String {
        switch self {
        case .singleSwing: return "Single Swing"
        case .doubleSwing: return "Double Swing"
        case .rollGate: return "Roll Gate"
        case .cantileverSlide: return "Cantilever Slide"
        case .overheadTrack: return "Overhead Track"
        case .verticalPivot: return "Vertical Pivot"
        }
    }

    var tier: String {
        switch self {
        case .singleSwing, .doubleSwing, .rollGate: return "essential"
        case .cantileverSlide, .overheadTrack, .verticalPivot: return "premium"
        }
    }
}

enum Material: String, Codable, CaseIterable {
    case wood
    case steel
    case chainLink = "chain_link"
    case aluminum

    var displayName: String {
        switch self {
        case .wood: return "Wood"
        case .steel: return "Steel"
        case .chainLink: return "Chain Link"
        case .aluminum: return "Aluminum"
        }
    }

    var tier: String {
        switch self {
        case .wood, .steel: return "essential"
        case .chainLink, .aluminum: return "premium"
        }
    }
}

enum AddonType: String, Codable, CaseIterable {
    case keypad
    case latch
    case opener
    case hinges
    case wheels
    case lock

    var displayName: String {
        switch self {
        case .keypad: return "Keypad Entry"
        case .latch: return "Heavy-Duty Latch"
        case .opener: return "Gate Opener"
        case .hinges: return "Premium Hinges"
        case .wheels: return "Roller Wheels"
        case .lock: return "Security Lock"
        }
    }

    var defaultPriceCents: Int {
        switch self {
        case .keypad: return 35000
        case .latch: return 8500
        case .opener: return 85000
        case .hinges: return 12000
        case .wheels: return 15000
        case .lock: return 9500
        }
    }
}

struct AddonLineItem: Codable, Identifiable {
    var id = UUID()
    var type: AddonType
    var quantity: Int
    var priceCents: Int

    var totalCents: Int {
        priceCents * quantity
    }
}

@Model
class ProjectModel {
    var id: String
    var clientName: String
    var clientPhone: String
    var clientEmail: String
    var siteAddress: String
    var sitePhotoData: Data?
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        clientName: String = "",
        clientPhone: String = "",
        clientEmail: String = "",
        siteAddress: String = "",
        sitePhotoData: Data? = nil,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.clientName = clientName
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.siteAddress = siteAddress
        self.sitePhotoData = sitePhotoData
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
class GateDesignModel {
    var id: String
    var projectId: String
    var gateStyle: String
    var material: String
    var widthFeet: Int
    var heightFeet: Int
    var addonsData: Data?
    var basePriceCents: Int
    var totalPriceCents: Int
    var laborCents: Int
    var markupPercent: Double
    var taxPercent: Double
    var selectedByClient: Bool
    var generatedImageData: Data?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        projectId: String,
        gateStyle: String = "single_swing",
        material: String = "steel",
        widthFeet: Int = 12,
        heightFeet: Int = 6,
        addonsData: Data? = nil,
        basePriceCents: Int = 0,
        totalPriceCents: Int = 0,
        laborCents: Int = 50000,
        markupPercent: Double = 30,
        taxPercent: Double = 0,
        selectedByClient: Bool = false,
        generatedImageData: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.projectId = projectId
        self.gateStyle = gateStyle
        self.material = material
        self.widthFeet = widthFeet
        self.heightFeet = heightFeet
        self.addonsData = addonsData
        self.basePriceCents = basePriceCents
        self.totalPriceCents = totalPriceCents
        self.laborCents = laborCents
        self.markupPercent = markupPercent
        self.taxPercent = taxPercent
        self.selectedByClient = selectedByClient
        self.generatedImageData = generatedImageData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

