import SwiftUI

struct GuideView: View {
    @State private var expandedFaq: Int?

    private let steps = [
        GuideStep(icon: "arrow.down.circle", num: "1", title: "Content opslaan", desc: "Deel een link vanuit Instagram, TikTok, YouTube of een andere app naar CraftStash."),
        GuideStep(icon: "square.stack.3d.up", num: "2", title: "Organiseer in collecties", desc: "Maak collecties aan voor verschillende thema's en voeg items toe."),
        GuideStep(icon: "tag", num: "3", title: "Filter en zoek", desc: "Filter op platform, type (video/afbeelding) of zoek op titel."),
        GuideStep(icon: "eye", num: "4", title: "Bekijk en deel", desc: "Open opgeslagen content in de app of ga terug naar het origineel."),
    ]

    private let features = [
        GuideFeature(icon: "globe", title: "Multi-platform", desc: "Instagram, TikTok, YouTube, Pinterest en meer"),
        GuideFeature(icon: "bolt.fill", title: "Bliksemsnel opslaan", desc: "Eén tap via de share sheet, klaar"),
        GuideFeature(icon: "square.stack.3d.up.fill", title: "Slimme collecties", desc: "Organiseer zoals jij wilt met mappen"),
        GuideFeature(icon: "magnifyingglass", title: "Krachtig zoeken", desc: "Vind alles terug op titel of platform"),
    ]

    private let faqs = [
        FAQ(q: "Welke platformen worden ondersteund?", a: "CraftStash werkt met Instagram, TikTok, YouTube, Pinterest, Facebook, X en meer."),
        FAQ(q: "Hoe sla ik content op?", a: "Gebruik de 'Delen'-knop in een andere app en kies CraftStash. Je kunt ook screenshots importeren via de + knop."),
        FAQ(q: "Kan ik screenshots opslaan?", a: "Ja! Tik op de + knop in het home scherm en kies 'Screenshot opslaan' om foto's uit je bibliotheek te importeren."),
        FAQ(q: "Is er een limiet?", a: "Nee, je kunt onbeperkt content opslaan. Je opslag is alleen beperkt door de ruimte op je apparaat."),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Hero
                        VStack(spacing: 8) {
                            Text("✨")
                                .font(.system(size: 32))
                            Text("Bewaar alles.\nVind alles terug.")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text("CraftStash is jouw persoonlijke bibliotheek voor knutselideeën.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                        // Steps
                        VStack(alignment: .leading, spacing: 12) {
                            Text("IN 4 STAPPEN")
                                .font(.caption.bold())
                                .foregroundStyle(Theme.textSecondary)
                                .tracking(0.5)
                                .padding(.horizontal)

                            ForEach(steps, id: \.num) { step in
                                HStack(alignment: .top, spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Theme.primaryColor.opacity(0.15))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: step.icon)
                                            .foregroundStyle(Theme.primaryColor)
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Text(step.num)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 18, height: 18)
                                            .background(Theme.primaryColor)
                                            .clipShape(Circle())
                                            .offset(x: 4, y: -4)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(step.title)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.white)
                                        Text(step.desc)
                                            .font(.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(14)
                                .background(Theme.surface1)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm)
                                        .stroke(Theme.borderColor, lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                        }

                        // Features grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("FEATURES")
                                .font(.caption.bold())
                                .foregroundStyle(Theme.textSecondary)
                                .tracking(0.5)
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(features, id: \.title) { feature in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Image(systemName: feature.icon)
                                            .font(.title3)
                                            .foregroundStyle(Theme.primaryColor)
                                        Text(feature.title)
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                        Text(feature.desc)
                                            .font(.caption2)
                                            .foregroundStyle(Theme.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Theme.surface1)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm)
                                            .stroke(Theme.borderColor, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }

                        // FAQ
                        VStack(alignment: .leading, spacing: 12) {
                            Text("VEELGESTELDE VRAGEN")
                                .font(.caption.bold())
                                .foregroundStyle(Theme.textSecondary)
                                .tracking(0.5)
                                .padding(.horizontal)

                            ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        expandedFaq = expandedFaq == index ? nil : index
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(faq.q)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.white)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                            Image(systemName: expandedFaq == index ? "chevron.up" : "chevron.down")
                                                .font(.caption)
                                                .foregroundStyle(Theme.textTertiary)
                                        }
                                        if expandedFaq == index {
                                            Text(faq.a)
                                                .font(.caption)
                                                .foregroundStyle(Theme.textSecondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding(14)
                                    .background(Theme.surface1)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm)
                                            .stroke(Theme.borderColor, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Hoe werkt het?")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct GuideStep {
    let icon: String
    let num: String
    let title: String
    let desc: String
}

private struct GuideFeature {
    let icon: String
    let title: String
    let desc: String
}

private struct FAQ {
    let q: String
    let a: String
}

#Preview {
    GuideView()
        .preferredColorScheme(.dark)
}
