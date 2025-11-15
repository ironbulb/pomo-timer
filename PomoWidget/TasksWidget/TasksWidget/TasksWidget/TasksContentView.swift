import SwiftUI

struct TasksContentView: View {
    @StateObject private var viewModel: TasksViewModel
    @Environment(\.colorScheme) var colorScheme

    let fixedPriority: String?
    let showFilters: Bool

    init(fixedPriority: String? = nil) {
        self.fixedPriority = fixedPriority
        self.showFilters = (fixedPriority == nil)
        self._viewModel = StateObject(wrappedValue: TasksViewModel(initialPriority: fixedPriority))
    }

    var body: some View {
        ZStack {
            // Frosted glass background - transparent
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .opacity(0.85)

            VStack(spacing: 0) {
                // Header with filters
                VStack(spacing: 12) {
                    Text(widgetTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Filter buttons (only if not fixed)
                    if showFilters {
                        HStack(spacing: 8) {
                            FilterButton(
                                title: "All",
                                isSelected: viewModel.selectedPriority == nil,
                                action: { viewModel.filterByPriority(nil) }
                            )

                            FilterButton(
                                title: "P1",
                                isSelected: viewModel.selectedPriority == "1",
                                color: .red,
                                action: { viewModel.filterByPriority("1") }
                            )

                            FilterButton(
                                title: "P2",
                                isSelected: viewModel.selectedPriority == "2",
                                color: .orange,
                                action: { viewModel.filterByPriority("2") }
                            )

                            FilterButton(
                                title: "P3",
                                isSelected: viewModel.selectedPriority == "3",
                                color: .yellow,
                                action: { viewModel.filterByPriority("3") }
                            )
                        }
                    }
                }
                .padding(16)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Tasks list
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.tasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                        Text("No tasks")
                            .font(.headline)
                        Text("All clear!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.tasks) { task in
                                TaskRow(task: task, onToggleComplete: { taskId in
                                    viewModel.toggleTaskCompletion(taskId: taskId)
                                })
                            }
                        }
                        .padding(12)
                    }
                }
            }
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity,
               minHeight: 200, idealHeight: 500, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .onAppear {
            viewModel.fetchTasks()
            viewModel.startAutoRefresh()
        }
    }

    var widgetTitle: String {
        if let priority = fixedPriority {
            return "P\(priority) Tasks"
        } else {
            return "Tasks"
        }
    }
}

struct FilterButton: View {
    let title: String
    var isSelected: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.1))
                )
                .foregroundColor(isSelected ? color : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskRow: View {
    let task: NotionTask
    let onToggleComplete: (String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button(action: {
                onToggleComplete(task.id)
            }) {
                Image(systemName: task.status == "Completed" ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.status == "Completed" ? .green : .secondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)

            // Priority indicator
            if let priority = task.priority {
                Circle()
                    .fill(priorityColor(priority))
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2)
                    .strikethrough(task.status == "Completed", color: .secondary)
                    .foregroundColor(task.status == "Completed" ? .secondary : .primary)

                HStack(spacing: 8) {
                    // Status badge
                    Text(task.status)
                        .font(.system(size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(statusColor(task.status).opacity(0.2))
                        )
                        .foregroundColor(statusColor(task.status))

                    // Project badge (if exists)
                    if let project = task.project {
                        Text(project)
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.purple.opacity(0.2))
                            )
                            .foregroundColor(.purple)
                    }

                    // Timer info (if exists)
                    if let timerStart = task.timerStart {
                        Text(formatTime(timerStart))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "1": return .red
        case "2": return .orange
        case "3": return .yellow
        default: return .gray
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "In Progress": return .blue
        case "Completed": return .green
        case "Not Started": return .orange
        default: return .gray
        }
    }

    private func formatTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return "" }

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: date)
    }
}
