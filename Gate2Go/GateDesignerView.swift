import SwiftUI

struct GateDesignerView: View {
    let widthFeet: Int
    let heightFeet: Int
    let material: Material
    let gateStyle: GateStyle
    var picketOrientation: String = "vertical"
    var finialStyle: String = "none"
    var archStyle: String = "flat"
    var archHeight: CGFloat = 20

    private var gateColor: Color {
        switch material {
        case .wood: return Color.brown
        case .steel: return Color.gray
        case .chainLink: return Color.gray.opacity(0.6)
        case .aluminum: return Color(white: 0.75)
        }
    }

    private var frameWidth: CGFloat {
        min(CGFloat(widthFeet) * 20, 300)
    }

    private var frameHeight: CGFloat {
        min(CGFloat(heightFeet) * 25, 200)
    }

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(gateColor, lineWidth: 4)
                    .frame(width: frameWidth, height: frameHeight)

                if material == .chainLink {
                    chainLinkPattern
                } else {
                    picketPattern
                }

                if gateStyle == .doubleSwing {
                    Rectangle()
                        .fill(gateColor)
                        .frame(width: 4, height: frameHeight)
                }
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(12)
        }
    }

    private var picketPattern: some View {
        HStack(spacing: picketOrientation == "vertical" ? 8 : 2) {
            ForEach(0..<Int(frameWidth / 15), id: \.self) { _ in
                if picketOrientation == "vertical" {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(gateColor)
                        .frame(width: 6, height: frameHeight - 16)
                } else {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(gateColor)
                        .frame(width: 6, height: frameHeight - 16)
                        .rotationEffect(.degrees(45))
                }
            }
        }
    }

    private var chainLinkPattern: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [gateColor.opacity(0.3), gateColor.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: frameWidth - 8, height: frameHeight - 8)
            .overlay(
                Image(systemName: "square.grid.3x3")
                    .resizable()
                    .foregroundStyle(gateColor)
                    .opacity(0.5)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        GateDesignerView(
            widthFeet: 12,
            heightFeet: 6,
            material: .steel,
            gateStyle: .singleSwing
        )

        GateDesignerView(
            widthFeet: 16,
            heightFeet: 6,
            material: .wood,
            gateStyle: .doubleSwing
        )
    }
}
