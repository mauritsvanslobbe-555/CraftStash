import SwiftUI

struct GuideView: View {
    @State private var expandedFaq: Int?

    private let steps = [
        GuideStep(icon: "arrow.down.circle", num: "1", title: "Content opslaan", desc: "Deel een link vanuit Instagram, TikTok, YouTube of een andere app naar StuffStash."),
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
        FAQ(q: "Welke platformen worden ondersteund?", a: "StuffStash werkt met Instagram, TikTok, YouTube, Pinterest, Facebook, X en meer."),
        FAQ(q: "Hoe sla ik content op?", a: "Gebruik de 'Delen'-knop in een andere app en kies StuffStash. Je kunt ook screenshots importeren via de + knop."),
        FAQ(q: "Kan ik screenshots opslaan?", a: "Ja! Tik op de + knop in het home scherm en kies 'Screenshot opslaan' om foto's uit je bibliotheek te importeren."),
        FAQ(q: "Is er een limiet?", a: "Nee, je kunt onbeperkt content opslaan. Je opslag is alleen beperkt door de ruimte op je apparaat."),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Hoe werkt het?")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.primarySoft)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Hero
                        VStack(spacing: 10) {
                            Text("\u{2728}")
                                .font(.system(size: 36))
                            Text("Bewaar alles.\nVind alles terug.")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text("StuffStash is jouw persoonlijke bibliotheek voor knutselideeën.")
                                .font(.system(size: 13.5))
                                .foregroundStyle(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Steps
                        VStack(alignment: .leading, spacing: 10) {
                            Text("IN 4 STAPPEN")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.inkDim)
                                .tracking(1)
                                .padding(.horizontal, 20)

                            ForEach(steps, id: \.num) { step in
                                HStack(alignment: .top, spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Theme.primaryTint)
                                            .frame(width: 48, height: 48)
                                        Image(systemName: step.icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(Theme.primarySoft)
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Text(step.num)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 18, height: 18)
                                            .background(Theme.primary)
                                            .clipShape(Circle())
                                            .offset(x: 4, y: -4)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(step.title)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Theme.ink)
                                        Text(step.desc)
                                            .font(.system(size: 13))
                                            .foregroundStyle(Theme.inkMute)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineSpacing(2)
                                    }
                                }
                                .padding(14)
                                .background(Theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Theme.border, lineWidth: 1)
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 24)

                        // Features grid
                        VStack(alignment: .leading, spacing: 10) {
                            Text("FEATURES")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.inkDim)
                                .tracking(1)
                                .padding(.horizontal, 20)

                            LazyVGrid(columns: Theme.gridColumns, spacing: 10) {
                                ForEach(features, id: \.title) { feature in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Image(systemName: feature.icon)
                                            .font(.system(size: 20))
                                            .foregroundStyle(Theme.primarySoft)
                                        Text(feature.title)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(Theme.ink)
                                        Text(feature.desc)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Theme.inkMute)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineSpacing(2)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Theme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Theme.border, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 24)

                        // FAQ
                        VStack(alignment: .leading, spacing: 10) {
                            Text("VEELGESTELDE VRAGEN")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.inkDim)
                                .tracking(1)
                                .padding(.horizontal, 20)

                            ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        expandedFaq = expandedFaq == index ? nil : index
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(faq.q)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Theme.ink)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                            Image(systemName: expandedFaq == index ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 11))
                                                .foregroundStyle(Theme.inkDim)
                                        }
                                        if expandedFaq == index {
                                            Text(faq.a)
                                                .font(.system(size: 13))
                                                .foregroundStyle(Theme.inkMute)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineSpacing(2)
                                        }
                                    }
                                    .padding(14)
                                    .background(Theme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Theme.border, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationBarHidden(true)
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
