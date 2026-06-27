// ContractSortOrder.swift
// Views support type — Sortieroptionen für die Vertragsliste.

import Foundation

enum ContractSortOrder: String, CaseIterable, Identifiable {
    case provider = "provider"
    case category = "category"
    case premiumAsc = "premiumAsc"
    case premiumDesc = "premiumDesc"
    case endDate = "endDate"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .provider:    return "Anbieter (A–Z)"
        case .category:    return "Kategorie"
        case .premiumAsc:  return "Beitrag aufsteigend"
        case .premiumDesc: return "Beitrag absteigend"
        case .endDate:     return "Vertragsende"
        }
    }

    func apply(to contracts: [Contract], catalog: Catalog) -> [Contract] {
        switch self {
        case .provider:
            return contracts.sorted { $0.provider.localizedCompare($1.provider) == .orderedAscending }
        case .category:
            return contracts.sorted {
                let aName = catalog.category(for: $0.categoryKey)?.nameDe ?? $0.categoryKey
                let bName = catalog.category(for: $1.categoryKey)?.nameDe ?? $1.categoryKey
                return aName.localizedCompare(bName) == .orderedAscending
            }
        case .premiumAsc:
            return contracts.sorted { ($0.premiumAmount ?? 0) < ($1.premiumAmount ?? 0) }
        case .premiumDesc:
            return contracts.sorted { ($0.premiumAmount ?? 0) > ($1.premiumAmount ?? 0) }
        case .endDate:
            return contracts.sorted {
                switch ($0.endDate, $1.endDate) {
                case let (lhs?, rhs?): return lhs < rhs
                case (nil, _?):        return false
                case (_?, nil):        return true
                case (nil, nil):       return false
                }
            }
        }
    }
}
