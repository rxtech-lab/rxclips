//
//  ExecutionDetailView.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import SwiftUI
import JSONSchemaForm

struct ExecutionDetailView: View {
    @Bindable var templateViewModel: TemplateViewModel
    @Bindable var executionViewModel: ExecutionViewModel
    
    var body: some View {
        VStack {
            if let selectedTemplate = templateViewModel.selectedTemplate {
                if selectedTemplate.type == .file {
                    executionContent
                        .onChange(of: selectedTemplate) { _, template in
                            executionViewModel.setTemplate(template)
                        }
                } else {
                    ContentUnavailableView(
                        "Folder Selected",
                        systemImage: "folder",
                        description: Text("Double-click to navigate into the folder")
                    )
                }
            } else {
                ContentUnavailableView(
                    "No Template Selected",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Select a template from the list to view execution details")
                )
            }
        }
        .navigationTitle("Execution")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if executionViewModel.isExecuting {
                    Button("Stop") {
                        executionViewModel.cancelExecution()
                    }
                    .foregroundColor(.red)
                } else {
                    Button("Run") {
                        executionViewModel.startExecution()
                    }
                    .disabled(templateViewModel.selectedTemplate?.type != .file)
                }
                
                Button("Clear Logs") {
                    executionViewModel.clearLogs()
                }
                .disabled(executionViewModel.logEntries.isEmpty)
            }
        }
        .sheet(isPresented: $executionViewModel.showGlobalForm) {
            GlobalFormSheet(executionViewModel: executionViewModel)
        }
        .sheet(isPresented: $executionViewModel.showStepForm) {
            StepFormSheet(executionViewModel: executionViewModel)
        }
    }
    
    @ViewBuilder
    private var executionContent: some View {
        HSplitView {
            // Left pane - Step list
            stepListView
                .frame(minWidth: 250)
            
            // Right pane - Execution logs
            executionLogsView
                .frame(minWidth: 300)
        }
    }
    
    @ViewBuilder
    private var stepListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Steps")
                .font(.headline)
                .padding()
            
            List(executionViewModel.stepStates.indices, id: \.self) { index in
                let stepState = executionViewModel.stepStates[index]
                
                HStack {
                    stepStatusIcon(stepState.status)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stepState.stepName)
                            .font(.headline)
                        
                        if let duration = stepState.duration {
                            Text(String(format: "%.2fs", duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let errorMessage = stepState.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    @ViewBuilder
    private var executionLogsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Execution Logs")
                    .font(.headline)
                
                Spacer()
                
                Text(executionStatusText)
                    .font(.caption)
                    .foregroundColor(executionStatusColor)
            }
            .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(executionViewModel.logEntries) { entry in
                        LogEntryView(entry: entry)
                    }
                }
                .padding()
            }
            .background(Color(NSColor.textBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .padding()
        }
    }
    
    private func stepStatusIcon(_ status: StepExecutionState.ExecutionStatus) -> some View {
        switch status {
        case .notStarted:
            return Image(systemName: "play.circle")
                .foregroundColor(.secondary)
        case .inProgress:
            return Image(systemName: "hourglass.circle")
                .foregroundColor(.blue)
        case .completed:
            return Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .error:
            return Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        case .skipped:
            return Image(systemName: "minus.circle")
                .foregroundColor(.secondary)
        }
    }
    
    private var executionStatusText: String {
        switch executionViewModel.executionStatus {
        case .notStarted:
            return "Ready to run"
        case .inProgress:
            return "Running..."
        case .completed:
            return "Completed"
        case .error:
            return "Error"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    private var executionStatusColor: Color {
        switch executionViewModel.executionStatus {
        case .notStarted:
            return .secondary
        case .inProgress:
            return .blue
        case .completed:
            return .green
        case .error:
            return .red
        case .cancelled:
            return .orange
        }
    }
}

struct LogEntryView: View {
    let entry: LogEntry
    
    var body: some View {
        HStack(alignment: .top) {
            Text(timeString)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            logLevelIcon
            
            VStack(alignment: .leading, spacing: 2) {
                if let stepName = entry.stepName {
                    Text("[\(stepName)]")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(entry.message)
                    .font(.caption)
                    .foregroundColor(logLevelColor)
            }
            
            Spacer()
        }
        .padding(.vertical, 1)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: entry.timestamp)
    }
    
    private var logLevelIcon: some View {
        switch entry.level {
        case .debug:
            return Image(systemName: "ladybug")
                .foregroundColor(.purple)
        case .info:
            return Image(systemName: "info.circle")
                .foregroundColor(.blue)
        case .warning:
            return Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
        case .error:
            return Image(systemName: "xmark.circle")
                .foregroundColor(.red)
        }
    }
    
    private var logLevelColor: Color {
        switch entry.level {
        case .debug:
            return .purple
        case .info:
            return .primary
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
}

struct GlobalFormSheet: View {
    @Bindable var executionViewModel: ExecutionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var formData: [String: Any] = [:]
    
    var body: some View {
        NavigationView {
            VStack {
                if let globalForm = executionViewModel.currentTemplate?.globalForm {
                    JSONSchemaForm(schema: globalForm, data: $formData)
                        .padding()
                } else {
                    Text("No global form schema available")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Global Configuration")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        executionViewModel.submitGlobalForm(formData)
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct StepFormSheet: View {
    @Bindable var executionViewModel: ExecutionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var formData: [String: Any] = [:]
    
    var body: some View {
        NavigationView {
            VStack {
                if !executionViewModel.currentStepFormSchema.isEmpty {
                    JSONSchemaForm(schema: executionViewModel.currentStepFormSchema, data: $formData)
                        .padding()
                } else {
                    Text("No form schema available")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Step Configuration")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        executionViewModel.submitStepForm(formData)
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}