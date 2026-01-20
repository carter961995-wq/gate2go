import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: Gate2GoSettings
    @State private var currentPage = 0

    let pages = [
        OnboardingPage(
            icon: "paintbrush",
            title: "Design Gates",
            description: "Create professional gate designs with our visual editor"
        ),
        OnboardingPage(
            icon: "dollarsign.circle",
            title: "Calculate Pricing",
            description: "Automatically calculate material, labor, and markup costs"
        ),
        OnboardingPage(
            icon: "doc.text",
            title: "Generate Proposals",
            description: "Create branded PDF proposals to share with clients"
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: pages[index].icon)
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)

                        Text(pages[index].title)
                            .font(.title.bold())

                        Text(pages[index].description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    settings.hasCompletedOnboarding = true
                }
            }) {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView()
        .environmentObject(Gate2GoSettings())
}

