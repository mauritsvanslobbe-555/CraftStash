import SwiftUI
import SwiftData

// MARK: - Onboarding Flow
// 4 screens per the design handoff: Welcome, Platforms, Hoe op te slaan, Eerste collecties.

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var step = 0
    @State private var selectedPresets: Set<String> = ["Knutselideeën", "Recepten", "DIY"]

    var onFinished: () -> Void

    private let totalSteps = 4

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $step) {
                    OnboardingWelcomeStep()
                        .tag(0)
                    OnboardingPlatformsStep()
                        .tag(1)
                    OnboardingHowToStep()
                        .tag(2)
                    OnboardingCollectionsStep(selectedPresets: $selectedPresets)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: step)

                bottomBar
            }
        }
    }

    // MARK: - Top bar (progress dots + skip)
    private var topBar: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Theme.primary : Theme.surfaceHi)
                        .frame(width: i == step ? 22 : 7, height: 7)
                        .animation(.easeInOut(duration: 0.2), value: step)
                }
            }

            Spacer()

            if step < totalSteps - 1 {
                Button("Overslaan") {
                    finish(createCollections: false)
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.inkMute)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Bottom bar (primary CTA)
    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button {
                if step < totalSteps - 1 {
                    withAnimation { step += 1 }
                } else {
                    finish(createCollections: true)
                }
            } label: {
                Text(ctaLabel)
                    .font(.system(size: 15.5, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Theme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Theme.primary.opacity(0.35), radius: 14, y: 6)
            }
            .disabled(step == totalSteps - 1 && selectedPresets.isEmpty)
            .opacity(step == totalSteps - 1 && selectedPresets.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
        .padding(.top, 8)
    }

    private var ctaLabel: String {
        switch step {
        case 0: return "Aan de slag"
        case 1: return "Volgende"
        case 2: return "Volgende"
        default:
            let count = selectedPresets.count
            return count == 1 ? "1 collectie aanmaken" : "\(count) collecties aanmaken"
        }
    }

    private func finish(createCollections: Bool) {
        if createCollections {
            for preset in OnboardingCollectionsStep.presets where selectedPresets.contains(preset.name) {
                let collection = CraftCollection(
                    name: preset.name,
                    icon: preset.icon,
                    colorName: preset.colorName
                )
                modelContext.insert(collection)
            }
            try? modelContext.save()
        }
        onFinished()
    }
}

// MARK: - Step 1: Welcome
private struct OnboardingWelcomeStep: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            ZStack {
                Circle()
                    .fill(Theme.primaryTint)
                    .frame(width: 220, height: 220)
                    .blur(radius: 10)

                // Floating cards
                RoundedRectangle(cornerRadius: 18)
                    .fill(Theme.surfaceHi)
                    .frame(width: 84, height: 108)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.borderHi, lineWidth: 1))
                    .rotationEffect(.degrees(-12))
                    .offset(x: -70, y: 18)

                RoundedRectangle(cornerRadius: 18)
                    .fill(Theme.surfaceHi)
                    .frame(width: 84, height: 108)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.borderHi, lineWidth: 1))
                    .rotationEffect(.degrees(9))
                    .offset(x: 68, y: -14)

                BrandLogo(size: 96)
                    .shadow(color: Theme.primary.opacity(0.4), radius: 24, y: 10)
            }
            .frame(height: 220)

            VStack(spacing: 10) {
                Text("Bewaar alles wat je leuk vindt.")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)

                Text("Eén plek voor knutselideeën, recepten en inspiratie van Instagram, TikTok, Pinterest en meer.")
                    .font(.system(size: 14.5))
                    .foregroundStyle(Theme.inkMute)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: 300)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 20)
        }
    }
}

// MARK: - Step 2: Platforms
private struct OnboardingPlatformsStep: View {
    private struct PlatformRow {
        let name: String
        let icon: String
        let color: Color
    }

    private var platforms: [PlatformRow] {
        [
            PlatformRow(name: "Instagram", icon: "camera.fill", color: Theme.igPink),
            PlatformRow(name: "TikTok", icon: "music.note", color: Theme.ttCyan),
            PlatformRow(name: "YouTube", icon: "play.rectangle.fill", color: Theme.ytRed),
            PlatformRow(name: "Pinterest", icon: "pin.fill", color: Theme.pinRed),
            PlatformRow(name: "En elke andere app met Delen", icon: "square.and.arrow.up", color: Theme.primary),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Werkt met je favoriete apps")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text("Stash ideeën rechtstreeks vanuit de app waar je ze vindt.")
                    .font(.system(size: 14.5))
                    .foregroundStyle(Theme.inkMute)
                    .lineSpacing(3)
            }

            VStack(spacing: 10) {
                ForEach(platforms, id: \.name) { platform in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(platform.color.opacity(0.16))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: platform.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(platform.color)
                            )

                        Text(platform.name)
                            .font(.system(size: 14.5, weight: .medium))
                            .foregroundStyle(Theme.ink)

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Theme.mint)
                    }
                    .padding(12)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}

// MARK: - Step 3: Hoe op te slaan
private struct OnboardingHowToStep: View {
    private struct StepRow {
        let number: Int
        let title: String
        let subtitle: String
    }

    private let steps = [
        StepRow(number: 1, title: "Open een post of video", subtitle: "In Instagram, TikTok, Pinterest of een andere app"),
        StepRow(number: 2, title: "Tik op Delen", subtitle: "Het pijltje-omhoog icoon onderaan het scherm"),
        StepRow(number: 3, title: "Kies StuffStash", subtitle: "Je idee wordt direct bewaard in je stash"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Zo bewaar je een idee")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text("In drie tikken staat het in je stash.")
                    .font(.system(size: 14.5))
                    .foregroundStyle(Theme.inkMute)
            }

            // Share-sheet illustration
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Theme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
                    .frame(height: 120)

                ZStack {
                    Circle()
                        .stroke(Theme.primary.opacity(0.3), lineWidth: 2)
                        .frame(width: 76, height: 76)
                    Circle()
                        .fill(Theme.primary)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                }
            }

            VStack(spacing: 14) {
                ForEach(steps, id: \.number) { row in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(row.number)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(Theme.primary)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.title)
                                .font(.system(size: 14.5, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            Text(row.subtitle)
                                .font(.system(size: 12.5))
                                .foregroundStyle(Theme.inkMute)
                        }
                        Spacer()
                    }
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}

// MARK: - Step 4: Eerste collecties
private struct OnboardingCollectionsStep: View {
    struct Preset {
        let name: String
        let icon: String
        let colorName: String
    }

    static let presets: [Preset] = [
        Preset(name: "Knutselideeën", icon: "paintbrush.fill", colorName: "sunshine"),
        Preset(name: "Recepten", icon: "fork.knife", colorName: "coral"),
        Preset(name: "DIY", icon: "hammer.fill", colorName: "ocean"),
        Preset(name: "Outfits", icon: "tshirt.fill", colorName: "berry"),
        Preset(name: "Reizen", icon: "airplane", colorName: "sky"),
        Preset(name: "Boeken", icon: "book.fill", colorName: "forest"),
    ]

    @Binding var selectedPresets: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Je eerste collecties")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text("Kies waar je mee wilt beginnen. Je kunt dit later altijd aanpassen.")
                    .font(.system(size: 14.5))
                    .foregroundStyle(Theme.inkMute)
                    .lineSpacing(3)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Self.presets, id: \.name) { preset in
                    presetChip(preset)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private func presetChip(_ preset: Preset) -> some View {
        let isSelected = selectedPresets.contains(preset.name)
        let color = Theme.color(for: preset.colorName)

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if isSelected {
                    selectedPresets.remove(preset.name)
                } else {
                    selectedPresets.insert(preset.name)
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: preset.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? .white : color)

                Text(preset.name)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Theme.ink)
                    .lineLimit(1)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(isSelected ? color : Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? .clear : Theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView(onFinished: {})
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
