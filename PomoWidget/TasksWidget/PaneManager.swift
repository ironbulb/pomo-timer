import Foundation
import Combine

class PaneManager: ObservableObject {
    @Published var panes: [FilterPane] = []
    @Published var selectedPaneId: String?

    private let userDefaultsKey = "SavedFilterPanes"

    init() {
        loadPanes()
        if panes.isEmpty {
            // Create default pane
            let defaultPane = FilterPane(name: "All Tasks")
            panes.append(defaultPane)
            selectedPaneId = defaultPane.id
            savePanes()
        } else {
            selectedPaneId = panes.first?.id
        }
    }

    var selectedPane: FilterPane? {
        panes.first { $0.id == selectedPaneId }
    }

    func addPane(_ pane: FilterPane) {
        panes.append(pane)
        savePanes()
    }

    func updatePane(_ pane: FilterPane) {
        if let index = panes.firstIndex(where: { $0.id == pane.id }) {
            panes[index] = pane
            savePanes()
        }
    }

    func deletePane(_ pane: FilterPane) {
        panes.removeAll { $0.id == pane.id }
        if selectedPaneId == pane.id {
            selectedPaneId = panes.first?.id
        }
        savePanes()
    }

    func selectPane(_ paneId: String) {
        selectedPaneId = paneId
    }

    private func savePanes() {
        if let encoded = try? JSONEncoder().encode(panes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadPanes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([FilterPane].self, from: data) {
            panes = decoded
        }
    }
}
