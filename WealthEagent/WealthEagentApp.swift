import SwiftUI
import SwiftData

@main
struct WealthEagentApp: App {

    private let modelContainer: ModelContainer
    private let contractRepository: ContractRepository
    private let catalogProvider: CatalogProvider = BundleCatalogProvider()
    private let documentScanner: DocumentScanner = VisionDocumentScanner()

    init() {
        do {
            let container = try ModelContainer(
                for: ContractRecord.self, PendingContractRecord.self
            )
            self.modelContainer = container
            self.contractRepository = LocalContractRepository(modelContainer: container)
        } catch {
            fatalError("SwiftData ModelContainer init failed: \(error)")
        }
    }

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
                ),
                catalogProvider: catalogProvider,
                scanViewModel: ScanViewModel(
                    documentScanner: documentScanner,
                    contractRepository: contractRepository
                )
            )
        }
    }
}
