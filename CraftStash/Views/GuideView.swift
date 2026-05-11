import SwiftUI

struct GuideView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var expandedFaq: Int?

    private var steps: [GuideStep] {
        [
            GuideStep(icon: "arrow.down.circle", num: "1", title: L.guideStep1Title, desc: L.guideStep1Desc),
            GuideStep(icon: "square.stack.3d.up", num: "2", title: L.guideStep2Title, desc: L.guideStep2Desc),
            GuideStep(icon: "tag", num: "3", title: L.guideStep3Title, desc: L.guideStep3Desc),
            GuideStep(icon: "eye", num: "4", title: L.guideStep4Title, desc: L.guideStep4Desc),
        ]
    }

    private var features: [GuideFeature] {
        [
            GuideFeature(icon: "globe", title: L.featureMultiPlatform, desc: L.featureMultiPlatformDesc),
            GuideFeature(icon: "bolt.fill", title: L.featureFastSave, desc: L.featureFastSaveDesc),
            GuideFeature(icon: "square.stack.3d.up.fill", title: L.featureSmartCollections, desc: L.featureSmartCollectionsDesc),
            GuideFeature(icon: "magnifyingglass", title: L.featurePowerfulSearch, desc: L.featurePowerfulSearchDesc),
        ]
    }

    private var faqs: [FAQ] {
        [
            FAQ(q: L.faq1Q, a: L.faq1A),
            FAQ(q: L.faq2Q, a: L.faq2A),
            FAQ(q: L.faq3Q, a: L.faq3A),
            FAQ(q: L.faq4Q, a: L.faq4A),
        ]
    }

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
                            Text(L.sloganTitle)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text(L.guideHero)
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
                            Text(L.inSteps)
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
                            Text(L.features)
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
                            Text(L.faqTitle)
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
                    Text(L.guideTitle)
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
        .environment(LanguageManager.shared)
        .preferredColorScheme(.dark)
}
