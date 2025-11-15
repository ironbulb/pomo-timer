import SwiftUI

struct TasksContentViewTabs: View {
    @StateObject private var paneManager = PaneManager()
    @StateObject private var viewModel: TasksViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddTaskSheet = false
    @State private var showAddPaneSheet = false
    @State private var newTaskTitle = ""
    @State private var newTaskChecked: Bool = false
    @State private var newTaskArea: String? = nil
    @State private var newTaskPriority: String? = nil
    @State private var newTaskProject: String? = nil
    @State private var newTaskStatus: String? = "Not Started"

    init() {
        self._viewModel = StateObject(wrappedValue: TasksViewModel())
    }

    var body: some View {
        ZStack {
            // Frosted glass background
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .opacity(0.85)

            VStack(spacing: 0) {
                // Header with pane tabs and add buttons
                VStack(spacing: 12) {
                    HStack {
                        Text("Tasks")
                            .font(.system(size: 18, weight: .semibold))

                        Spacer()

                        // Add Pane button
                        Button(action: {
                            showAddPaneSheet = true
                        }) {
                            Image(systemName: "square.grid.3x1.fill.below.line.grid.1x2")
                                .foregroundColor(.purple)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Add new filter pane")

                        // Add Task button
                        Button(action: {
                            showAddTaskSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 20))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Add new task")
                    }

                    // Pane tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(paneManager.panes) { pane in
                                PaneTab(
                                    pane: pane,
                                    isSelected: pane.id == paneManager.selectedPaneId,
                                    onSelect: {
                                        paneManager.selectPane(pane.id)
                                        applyPaneFilters(pane)
                                    },
                                    onDelete: {
                                        if paneManager.panes.count > 1 {
                                            paneManager.deletePane(pane)
                                            if let firstPane = paneManager.panes.first {
                                                applyPaneFilters(firstPane)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(16)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Tasks list
                tasksList
            }
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity,
               minHeight: 200, idealHeight: 500, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .sheet(isPresented: $showAddTaskSheet) {
            addTaskSheet
        }
        .sheet(isPresented: $showAddPaneSheet) {
            addPaneSheet
        }
        .onAppear {
            viewModel.fetchSchema()
            if let firstPane = paneManager.panes.first {
                applyPaneFilters(firstPane)
                // Fetch calendar events based on pane's timer filter
                if let timerFilter = firstPane.timerFilter {
                    viewModel.fetchCalendarEvents(timeFilter: timerFilter)
                }
            }
            viewModel.startAutoRefresh()
        }
    }

    // MARK: - Tasks List

    var tasksList: some View {
        Group {
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
            } else if filteredTasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                    Text("No tasks")
                        .font(.headline)
                    if let pane = paneManager.selectedPane {
                        Text(pane.filterDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Calendar events section
                        if !viewModel.calendarEvents.isEmpty {
                            ForEach(viewModel.calendarEvents) { event in
                                CalendarEventRow(event: event)
                            }

                            Divider()
                                .padding(.vertical, 4)
                        }

                        // Tasks section
                        ForEach(filteredTasks) { task in
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

    // MARK: - Add Task Sheet

    var addTaskSheet: some View {
        VStack(spacing: 20) {
            Text("New Task")
                .font(.system(size: 20, weight: .semibold))

            TextField("Task title", text: $newTaskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 450)

            // Checked/Unchecked toggle
            Toggle(isOn: $newTaskChecked) {
                Text("Checked")
                    .font(.system(size: 13))
            }
            .toggleStyle(.checkbox)
            .frame(width: 450, alignment: .leading)

            // Area selector (always show, use API values if available, otherwise fallback)
            VStack(alignment: .leading, spacing: 8) {
                Text("Area:")
                    .font(.system(size: 13))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        let areas = viewModel.availableAreas.isEmpty ? ["PhD", "Life", "MD"] : viewModel.availableAreas
                        ForEach(areas, id: \.self) { area in
                            Button(action: {
                                newTaskArea = area
                            }) {
                                Text(area)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(newTaskArea == area ? Color.cyan.opacity(0.3) : Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(newTaskArea == area ? .cyan : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button(action: {
                            newTaskArea = nil
                        }) {
                            Text("None")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(newTaskArea == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(newTaskArea == nil ? .blue : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            // Priority selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Priority:")
                    .font(.system(size: 13))

                HStack(spacing: 8) {
                    ForEach(viewModel.availablePriorities, id: \.self) { priority in
                        Button(action: {
                            newTaskPriority = priority
                        }) {
                            Text(priority)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(newTaskPriority == priority ? priorityColor(priority).opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(newTaskPriority == priority ? priorityColor(priority) : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button(action: {
                        newTaskPriority = nil
                    }) {
                        Text("None")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(newTaskPriority == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(newTaskPriority == nil ? .blue : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            // Status selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Status:")
                    .font(.system(size: 13))

                HStack(spacing: 8) {
                    ForEach(viewModel.availableStatuses.filter { $0 == "Not Started" || $0 == "In Progress" }, id: \.self) { status in
                        Button(action: {
                            newTaskStatus = status
                        }) {
                            Text(status)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(newTaskStatus == status ? statusButtonColor(status).opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(newTaskStatus == status ? statusButtonColor(status) : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            // Project selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Project:")
                    .font(.system(size: 13))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.availableProjects, id: \.self) { project in
                            Button(action: {
                                newTaskProject = project
                            }) {
                                Text(project)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(newTaskProject == project ? Color.purple.opacity(0.3) : Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(newTaskProject == project ? .purple : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button(action: {
                            newTaskProject = nil
                        }) {
                            Text("None")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(newTaskProject == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(newTaskProject == nil ? .blue : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    showAddTaskSheet = false
                    resetTaskForm()
                }
                .keyboardShortcut(.cancelAction)

                Button("Create") {
                    viewModel.createTask(
                        title: newTaskTitle,
                        priority: newTaskPriority,
                        status: newTaskStatus,
                        project: newTaskProject,
                        area: newTaskArea,
                        checked: newTaskChecked
                    )
                    showAddTaskSheet = false
                    resetTaskForm()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newTaskTitle.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 500, height: 550)
    }

    // MARK: - Add Pane Sheet

    var addPaneSheet: some View {
        AddPaneView(
            viewModel: viewModel,
            onSave: { pane in
                paneManager.addPane(pane)
                paneManager.selectPane(pane.id)
                applyPaneFilters(pane)
                showAddPaneSheet = false
            },
            onCancel: {
                showAddPaneSheet = false
            }
        )
    }

    // MARK: - Helper Functions

    func applyPaneFilters(_ pane: FilterPane) {
        viewModel.applyFilters(
            priority: pane.priority,
            status: pane.status,
            project: pane.project
        )
        // Fetch calendar events if timer filter is set
        if let timerFilter = pane.timerFilter {
            viewModel.fetchCalendarEvents(timeFilter: timerFilter)
        } else {
            viewModel.calendarEvents = []
        }
    }

    func resetTaskForm() {
        newTaskTitle = ""
        newTaskChecked = false
        newTaskArea = nil
        newTaskPriority = nil
        newTaskStatus = "Not Started"
        newTaskProject = nil
    }

    func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "1": return .red
        case "2": return .orange
        case "3": return .yellow
        default: return .gray
        }
    }

    func statusButtonColor(_ status: String) -> Color {
        switch status {
        case "Not Started": return .orange
        case "In Progress": return .blue
        case "Completed": return .green
        default: return .gray
        }
    }

    func filterTasksByTimer(_ tasks: [NotionTask], timerFilter: TimerFilter?) -> [NotionTask] {
        guard let filter = timerFilter else { return tasks }

        let now = Date()
        let calendar = Calendar.current

        return tasks.filter { task in
            switch filter {
            case .any:
                return true
            case .today:
                guard let startStr = task.timerStart,
                      let start = ISO8601DateFormatter().date(from: startStr) else {
                    return false
                }
                return calendar.isDateInToday(start)
            case .thisWeek:
                guard let startStr = task.timerStart,
                      let start = ISO8601DateFormatter().date(from: startStr) else {
                    return false
                }
                return calendar.isDate(start, equalTo: now, toGranularity: .weekOfYear)
            case .hasTimer:
                return task.timerStart != nil
            case .noTimer:
                return task.timerStart == nil
            }
        }
    }

    var filteredTasks: [NotionTask] {
        guard let pane = paneManager.selectedPane else {
            return viewModel.tasks
        }
        return filterTasksByTimer(viewModel.tasks, timerFilter: pane.timerFilter)
    }
}

// MARK: - Pane Tab View

struct PaneTab: View {
    let pane: FilterPane
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 4) {
            Button(action: onSelect) {
                Text(pane.name)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())

            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 6)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.6) : Color.gray.opacity(0.2))
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Add Pane View

struct AddPaneView: View {
    @ObservedObject var viewModel: TasksViewModel
    let onSave: (FilterPane) -> Void
    let onCancel: () -> Void

    @State private var paneName = ""
    @State private var selectedPriority: String? = nil
    @State private var selectedStatus: String? = nil
    @State private var selectedProject: String? = nil
    @State private var selectedArea: String? = nil
    @State private var selectedChecked: Bool? = nil
    @State private var selectedTimer: TimerFilter = .any

    var body: some View {
        VStack(spacing: 20) {
            Text("New Filter Pane")
                .font(.system(size: 20, weight: .semibold))

            TextField("Pane name", text: $paneName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 450)

            // Checked filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Checked:")
                    .font(.system(size: 13))

                HStack(spacing: 8) {
                    Button(action: {
                        selectedChecked = true
                    }) {
                        Text("Checked")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedChecked == true ? Color.green.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedChecked == true ? .green : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        selectedChecked = false
                    }) {
                        Text("Unchecked")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedChecked == false ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedChecked == false ? .orange : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        selectedChecked = nil
                    }) {
                        Text("Any")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedChecked == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedChecked == nil ? .blue : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            // Area filter (always show, use API values if available, otherwise fallback)
            VStack(alignment: .leading, spacing: 8) {
                Text("Area:")
                    .font(.system(size: 13))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        let areas = viewModel.availableAreas.isEmpty ? ["PhD", "Life", "MD"] : viewModel.availableAreas
                        ForEach(areas, id: \.self) { area in
                            Button(action: {
                                selectedArea = area
                            }) {
                                Text(area)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedArea == area ? Color.cyan.opacity(0.3) : Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(selectedArea == area ? .cyan : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button(action: {
                            selectedArea = nil
                        }) {
                            Text("Any")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedArea == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedArea == nil ? .blue : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            // Priority filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Priority:")
                    .font(.system(size: 13))

                HStack(spacing: 8) {
                    ForEach(viewModel.availablePriorities, id: \.self) { priority in
                        Button(action: {
                            selectedPriority = priority
                        }) {
                            Text(priority)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedPriority == priority ? priorityColor(priority).opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedPriority == priority ? priorityColor(priority) : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button(action: {
                        selectedPriority = nil
                    }) {
                        Text("Any")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedPriority == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedPriority == nil ? .blue : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            // Status filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Status:")
                    .font(.system(size: 13))

                HStack(spacing: 8) {
                    ForEach(viewModel.availableStatuses, id: \.self) { status in
                        Button(action: {
                            selectedStatus = status
                        }) {
                            Text(status)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedStatus == status ? statusButtonColor(status).opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedStatus == status ? statusButtonColor(status) : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button(action: {
                        selectedStatus = nil
                    }) {
                        Text("Any")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedStatus == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedStatus == nil ? .blue : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            // Project filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Project:")
                    .font(.system(size: 13))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.availableProjects, id: \.self) { project in
                            Button(action: {
                                selectedProject = project
                            }) {
                                Text(project)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedProject == project ? Color.purple.opacity(0.3) : Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(selectedProject == project ? .purple : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button(action: {
                            selectedProject = nil
                        }) {
                            Text("Any")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedProject == nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedProject == nil ? .blue : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            // Timer filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Timer:")
                    .font(.system(size: 13))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach([TimerFilter.any, .today, .thisWeek, .hasTimer, .noTimer], id: \.self) { timer in
                            Button(action: {
                                selectedTimer = timer
                            }) {
                                Text(timer.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedTimer == timer ? timerColor(timer).opacity(0.3) : Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(selectedTimer == timer ? timerColor(timer) : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("Create Pane") {
                    let pane = FilterPane(
                        name: paneName.isEmpty ? "New Pane" : paneName,
                        priority: selectedPriority,
                        status: selectedStatus,
                        project: selectedProject,
                        area: selectedArea,
                        checked: selectedChecked,
                        timerFilter: selectedTimer == .any ? nil : selectedTimer
                    )
                    onSave(pane)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(30)
        .frame(width: 500, height: 700)
    }

    func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "1": return .red
        case "2": return .orange
        case "3": return .yellow
        default: return .gray
        }
    }

    func statusButtonColor(_ status: String) -> Color {
        switch status {
        case "Not Started": return .orange
        case "In Progress": return .blue
        case "Completed": return .green
        default: return .gray
        }
    }
}
// Extension for AddPaneView timer color helper
extension AddPaneView {
    func timerColor(_ timer: TimerFilter) -> Color {
        switch timer {
        case .any: return .blue
        case .today: return .green
        case .thisWeek: return .cyan
        case .hasTimer: return .purple
        case .noTimer: return .gray
        }
    }
}
