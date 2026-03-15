// OnboardingView.swift
// QRAI Pro

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(PremiumManager.self) private var premiumManager
    @State private var currentPage = 0
    @State private var showPaywall = false

    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Scan Any Code", subtitle: "Instantly scan QR codes and barcodes with your camera or from your photo library.", icon: "qrcode.viewfinder", color: AppConstants.Colors.qrBlue),
        OnboardingPage(title: "Generate QR Codes", subtitle: "Create custom QR codes for URLs, contacts, WiFi, and more in seconds.", icon: "qrcode", color: AppConstants.Colors.qrPurple),
        OnboardingPage(title: "Custom Styles", subtitle: "Make your QR codes stand out with custom colors, logos, and patterns.", icon: "paintbrush.pointed", color: AppConstants.Colors.qrGreen),
        OnboardingPage(title: "Full History", subtitle: "All your scanned and generated codes saved and organized for easy access.", icon: "clock.arrow.circlepath", color: AppConstants.Colors.qrOrange),
    ]

    var body: some View {
        ZStack {
            AppConstants.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? AppConstants.Colors.qrBlue : Color.gray.opacity(0.3))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // CTA buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started Free")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppConstants.Colors.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)

                    if currentPage == pages.count - 1 {
                        Button("Unlock Premium") {
                            showPaywall = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppConstants.Colors.qrBlue)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        AnalyticsService.shared.track(.onboardingCompleted)
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 180, height: 180)
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(page.color)
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}
