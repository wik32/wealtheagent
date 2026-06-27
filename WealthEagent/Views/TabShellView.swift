// TabShellView.swift
// Views — SwiftUI. Root TabView with 4 tabs. Replaces ContentView as main UI entry point.
//
// Tab labels (ubiquitous-language.md):
//   "Übersicht" | "Verträge" | "Beobachtungen" | "Mehr"
// First tab (Übersicht) is selected on launch.

import SwiftUI

// MARK: - TabShellView

/// Root tab interface. Wires the four top-level destinations.
/// Requires all ViewModels and providers injected — no ad-hoc construction inside (Pillar 3).
struct TabShellView: View {

    // MARK: - Injected ViewModels

    @State var dashboardViewModel: DashboardViewModel
    @State var contractListViewModel: ContractListViewModel
    @State var observationsViewModel: ObservationsViewModel
    let catalogProvider: CatalogProvider
    let scanViewModel: ScanViewModel

    // MARK: - First-launch disclaimer

    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false

    // MARK: - Tab selection (first tab on launch)

    @State private var selectedTab: Int = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem { Label("Übersicht", systemImage: "house") }
                .tag(0)

            ContractListView(
                viewModel: contractListViewModel,
                catalogProvider: catalogProvider,
                scanViewModel: scanViewModel
            )
            .tabItem { Label("Verträge", systemImage: "doc.text") }
            .tag(1)

            ObservationsView(viewModel: observationsViewModel)
                .tabItem { Label("Beobachtungen", systemImage: "eye") }
                .tag(2)

            SettingsView()
                .tabItem { Label("Mehr", systemImage: "gearshape") }
                .tag(3)
        }
        .fullScreenCover(isPresented: .constant(!hasAcceptedDisclaimer)) {
            OnboardingDisclaimerView {
                hasAcceptedDisclaimer = true
            }
        }
    }
}
