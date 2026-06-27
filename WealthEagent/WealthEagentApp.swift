import SwiftUI

@main
struct WealthEagentApp: App {

    private let contractRepository: ContractRepository = InMemoryContractRepository()
    private let catalogProvider: CatalogProvider = BundleCatalogProvider()

    var body: some Scene {
        WindowGroup {
            TabShellView(
                dashboardViewModel: DashboardViewModel(
                    contractRepository: contractRepository,
                    catalogProvider: catalogProvider
                ),
                contractListViewModel: ContractListViewModel(
                    contractRepository: contractRepository
                ),
                observationsViewModel: ObservationsViewModel(
                    contractRepository: contractRepository,
                    catalogProvider: catalogProvider
                )
            )
        }
    }
}
