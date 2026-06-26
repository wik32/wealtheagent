// TabShellView.swift
// Views — SwiftUI. Root TabView with 4 tabs. Replaces ContentView as main UI entry point.
//
// SCAFFOLD: true
// Tab labels (ubiquitous-language.md):
//   "Übersicht" | "Verträge" | "Beobachtungen" | "Mehr"
// First tab (Übersicht) is selected on launch.

import SwiftUI

// MARK: - TabShellView

/// Root tab interface. Wires the four top-level destinations.
/// Requires all ViewModels injected — no ad-hoc construction inside (Pillar 3).
struct TabShellView: View {

    // MARK: - Injected ViewModels

    @State var dashboardViewModel: DashboardViewModel
    @State var contractListViewModel: ContractListViewModel
    @State var observationsViewModel: ObservationsViewModel

    // MARK: - Tab selection (first tab on launch)

    @State private var selectedTab: Int = 0

    // MARK: - Body

    var body: some View {
        fatalError("SCAFFOLD — TabShellView body not yet implemented. Remove fatalError in DELIVER.")
        // Design spec:
        //
        // TabView(selection: $selectedTab) {
        //     DashboardView(viewModel: dashboardViewModel)
        //         .tabItem { Label("Übersicht", systemImage: "chart.pie") }
        //         .tag(0)
        //     ContractListView(viewModel: contractListViewModel)
        //         .tabItem { Label("Verträge", systemImage: "doc.text") }
        //         .tag(1)
        //     ObservationsView(viewModel: observationsViewModel)
        //         .tabItem { Label("Beobachtungen", systemImage: "eye") }
        //         .tag(2)
        //     SettingsPlaceholderView()
        //         .tabItem { Label("Mehr", systemImage: "ellipsis") }
        //         .tag(3)
        // }
    }
}

// MARK: - SettingsPlaceholderView

/// Placeholder for the "Mehr" tab (SettingsView / KnowledgeHubView — Stage 2 scope).
struct SettingsPlaceholderView: View {
    var body: some View {
        Text("Mehr")
    }
}
