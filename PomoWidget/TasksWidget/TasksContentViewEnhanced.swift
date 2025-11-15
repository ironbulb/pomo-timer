import SwiftUI

struct TasksContentViewEnhanced: View {
    @StateObject private var viewModel: TasksViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddTaskSheet = false
    @State private var newTaskTitle = ""
    @State private var newTaskChecked: Bool = false
    @State private var newTaskArea: String? = nil
    @State private var newTaskPriority: String? = nil
    @State private var newTaskProject: String? = nil
    @State private var newTaskStatus: String? = "Not Started"

    enum FilterMode {
        case priority
        case status
        case project
        case combined
    }

    let filterMode: FilterMode
    let fixedFilters: (priority: String?, status: String?, project: String?)

    init(filterMode: FilterMode = .priority, priority: String? = nil, status: String? = nil, project: String? = nil) {
        self.filterMode = filterMode
        self.fixedFilters = (priority, status, project)
        self._viewModel = StateObject(wrappedValue: TasksViewModel(
            initialPriority: priority,
            initialStatus: status,
            initialProject: project
        ))
    }

    var body: some View {
        ZStack {
            // Frosted glass background
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .opacity(0.85)

            VStack(spacing: 0) {
                // Header with filters and add button
                VStack(spacing: 12) {
                    HStack {
                        Text(widgetTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Open current filter in new window button
                        if viewModel.selectedPriority != nil || viewModel.selectedStatus != nil || viewModel.selectedProject != nil {
                            Button(action: {
                                openInNewWindow()
                            }) {
                                Image(systemName: "plus.rectangle.on.rectangle")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Open current filter in new window")
                        }

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

                    // Filter buttons based on mode
                    switch filterMode {
                    case .priority:
                        priorityFilters
                    case .status:
                        statusFilters
                    case .project:
                        projectFilters
                    case .combined:
                        combinedFilters
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
        .onAppear {
            viewModel.fetchSchema()
            viewModel.fetchTasks()
            viewModel.startAutoRefresh()
        }
    }

    // MARK: - Filter Views

    var priorityFilters: some View {
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

    var statusFilters: some View {
        HStack(spacing: 8) {
            FilterButton(
                title: "All",
                isSelected: viewModel.selectedStatus == nil,
                action: { viewModel.filterByStatus(nil) }
            )

            FilterButton(
                title: "Not Started",
                isSelected: viewModel.selectedStatus == "Not Started",
                color: .orange,
                action: { viewModel.filterByStatus("Not Started") }
            )

            FilterButton(
                title: "In Progress",
                isSelected: viewModel.selectedStatus == "In Progress",
                color: .blue,
                action: { viewModel.filterByStatus("In Progress") }
            )

            FilterButton(
                title: "Completed",
                isSelected: viewModel.selectedStatus == "Completed",
                color: .green,
                action: { viewModel.filterByStatus("Completed") }
            )
        }
    }

    var projectFilters: some View {
        HStack(spacing: 8) {
            FilterButton(
                title: "All",
                isSelected: viewModel.selectedProject == nil,
                action: { viewModel.filterByProject(nil) }
            )

            FilterButton(
                title: "ICI",
                isSelected: viewModel.selectedProject == "ICI",
                color: .purple,
                action: { viewModel.filterByProject("ICI") }
            )

            FilterButton(
                title: "Work",
                isSelected: viewModel.selectedProject == "Work",
                color: .blue,
                action: { viewModel.filterByProject("Work") }
            )

            FilterButton(
                title: "Personal",
                isSelected: viewModel.selectedProject == "Personal",
                color: .green,
                action: { viewModel.filterByProject("Personal") }
            )
        }
    }

    var combinedFilters: some View {
        VStack(spacing: 8) {
            // Status filter row
            HStack(spacing: 6) {
                Text("Status:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                FilterButton(
                    title: "In Progress",
                    isSelected: viewModel.selectedStatus == "In Progress",
                    color: .blue,
                    action: {
                        viewModel.applyFilters(
                            priority: viewModel.selectedPriority,
                            status: "In Progress",
                            project: viewModel.selectedProject
                        )
                    }
                )

                FilterButton(
                    title: "Not Started",
                    isSelected: viewModel.selectedStatus == "Not Started",
                    color: .orange,
                    action: {
                        viewModel.applyFilters(
                            priority: viewModel.selectedPriority,
                            status: "Not Started",
                            project: viewModel.selectedProject
                        )
                    }
                )
            }

            // Project filter row
            HStack(spacing: 6) {
                Text("Project:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                FilterButton(
                    title: "ICI",
                    isSelected: viewModel.selectedProject == "ICI",
                    color: .purple,
                    action: {
                        viewModel.applyFilters(
                            priority: viewModel.selectedPriority,
                            status: viewModel.selectedStatus,
                            project: "ICI"
                        )
                    }
                )

                FilterButton(
                    title: "Work",
                    isSelected: viewModel.selectedProject == "Work",
                    color: .blue,
                    action: {
                        viewModel.applyFilters(
                            priority: viewModel.selectedPriority,
                            status: viewModel.selectedStatus,
                            project: "Work"
                        )
                    }
                )

                if viewModel.selectedStatus != nil || viewModel.selectedProject != nil {
                    Button(action: {
                        viewModel.applyFilters(priority: nil, status: nil, project: nil)
                    }) {
                        Text("Clear")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
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
            } else if viewModel.tasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                    Text("No tasks")
                        .font(.headline)
                    Text(filterDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
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

            // Area selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Area:")
                    .font(.system(size: 13))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.availableAreas, id: \.self) { area in
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
                    resetForm()
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
                    resetForm()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newTaskTitle.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 500, height: 550)
    }

    // MARK: - Helper Functions

    var widgetTitle: String {
        if fixedFilters.priority != nil && fixedFilters.status != nil && fixedFilters.project != nil {
            var parts: [String] = []
            if let status = fixedFilters.status { parts.append(status) }
            if let project = fixedFilters.project { parts.append(project) }
            return parts.joined(separator: " + ")
        } else if let priority = fixedFilters.priority {
            return "P\(priority) Tasks"
        } else if let status = fixedFilters.status {
            return "\(status) Tasks"
        } else if let project = fixedFilters.project {
            return "\(project) Tasks"
        } else {
            return "Tasks"
        }
    }

    var filterDescription: String {
        var parts: [String] = []
        if let priority = viewModel.selectedPriority {
            parts.append("P\(priority)")
        }
        if let status = viewModel.selectedStatus {
            parts.append(status)
        }
        if let project = viewModel.selectedProject {
            parts.append(project)
        }

        if parts.isEmpty {
            return "All clear!"
        } else {
            return "No tasks matching: " + parts.joined(separator: " + ")
        }
    }

    func resetForm() {
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

    func openInNewWindow() {
        // Create a title for the new window
        var titleParts: [String] = []
        if let priority = viewModel.selectedPriority {
            titleParts.append("P\(priority)")
        }
        if let status = viewModel.selectedStatus {
            titleParts.append(status)
        }
        if let project = viewModel.selectedProject {
            titleParts.append(project)
        }

        let title = titleParts.isEmpty ? "All Tasks" : titleParts.joined(separator: " + ")

        // Create new widget with current filters
        WidgetManager.shared.createWidget(
            title: title,
            project: viewModel.selectedProject,
            status: viewModel.selectedStatus,
            priority: viewModel.selectedPriority,
            filterMode: .combined,
            position: .auto
        )
    }
}
