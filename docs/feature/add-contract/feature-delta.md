# Feature Delta — add-contract

## Wave: DISTILL

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| n/a | MVVM+Ports — AddContractViewModel is @Observable @MainActor, injected into AddContractView | n/a | Form state fully testable via MockContractRepository without UI |
| n/a | No "Empfehlung/empfehlen" in any user-facing string (CLAUDE.md rule) | n/a | All labels are neutral factual terms: "Vertragsart", "Anbieter", "Beitrag", "Speichern" |
| n/a | EU-only / SwiftData persistence — ContractRepository.save() writes to LocalContractRepository | n/a | Saved contracts persist across app restarts without leaving device |

### [REF] Scenario list

| Scenario | Tags |
|---|---|
| AddContractViewModel initializes with canSave = false | @walking_skeleton |
| canSave false when provider is empty | @validation |
| canSave false when category not selected | @validation |
| canSave true with category and provider | @validation |
| Whitespace-only provider is treated as invalid | @validation @error |
| save() persists contract to repository | @happy_path |
| save() converts comma decimal to Double correctly | @happy_path |
| save() with empty amount is valid | @happy_path |
| AddContractView initializes without crash | @wiring |

### [REF] Driving port

`AddContractViewModel` — driving port for all add-contract interactions.
`ContractListViewModel.add(contract:)` — already exists; called indirectly after save() via repository.

### [REF] Test placement

`WealthEagentTests/ViewModels/AddContractViewModelTests.swift` — XCTest @MainActor  
`WealthEagentTests/Views/AddContractViewTests.swift` — XCTest structural wiring check

### [REF] Files modified

**New — production:**
- `WealthEagent/ViewModels/AddContractViewModel.swift`
- `WealthEagent/Views/AddContractView.swift`

**Updated — production:**
- `WealthEagent/ViewModels/ContractListViewModel.swift` (contractRepository: private → internal)
- `WealthEagent/Views/ContractListView.swift` (add catalogProvider param + sheet)
- `WealthEagent/Views/TabShellView.swift` (add catalogProvider param)
- `WealthEagent/WealthEagentApp.swift` (pass catalogProvider to TabShellView)

**New — tests:**
- `WealthEagentTests/ViewModels/AddContractViewModelTests.swift`
- `WealthEagentTests/Views/AddContractViewTests.swift`

**Updated — tests:**
- `WealthEagentTests/Views/ContractListViewTests.swift` (pass catalogProvider)
- `WealthEagentTests/Views/TabShellViewTests.swift` (pass catalogProvider)
