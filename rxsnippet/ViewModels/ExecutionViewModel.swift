//
//  ExecutionViewModel.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import Foundation
import RxClipsCore

@Observable
final class ExecutionViewModel {
    var currentTemplate: TemplateItem?
    var executionStatus: ExecutionStatus = .notStarted
    var stepStates: [StepExecutionState] = []
    var logEntries: [LogEntry] = []
    var isExecuting = false
    var currentStepIndex = 0
    var globalFormData: [String: Any] = [:]
    var showGlobalForm = false
    var showStepForm = false
    var currentStepFormData: [String: Any] = [:]
    var currentStepFormSchema: [String: Any] = [:]
    var formCompletionCallback: (([String: Any]) -> Void)?
    
    private var engine: RxClipsCore.Engine?
    
    enum ExecutionStatus {
        case notStarted
        case inProgress
        case completed
        case error
        case cancelled
    }
    
    init() {}
    
    func setTemplate(_ template: TemplateItem) {
        currentTemplate = template
        resetExecution()
        setupStepStates()
    }
    
    private func resetExecution() {
        executionStatus = .notStarted
        stepStates = []
        logEntries = []
        isExecuting = false
        currentStepIndex = 0
        globalFormData = [:]
        currentStepFormData = [:]
        engine = nil
    }
    
    private func setupStepStates() {
        guard let template = currentTemplate else { return }
        
        stepStates = template.steps.map { step in
            StepExecutionState(
                stepName: step.name,
                status: .notStarted,
                startTime: nil,
                endTime: nil,
                errorMessage: nil,
                logEntries: []
            )
        }
    }
    
    func startExecution() {
        guard let template = currentTemplate else { return }
        
        if let globalForm = template.globalForm, !globalForm.isEmpty {
            showGlobalForm = true
            return
        }
        
        executeSteps()
    }
    
    func executeSteps() {
        guard let template = currentTemplate else { return }
        
        isExecuting = true
        executionStatus = .inProgress
        currentStepIndex = 0
        
        setupEngines()
        
        Task {
            await executeAllSteps()
        }
    }
    
    private func setupEngines() {
        engine = RxClipsCore.Engine()
    }
    
    @MainActor
    private func executeAllSteps() async {
        guard let template = currentTemplate else { return }
        
        for (index, step) in template.steps.enumerated() {
            currentStepIndex = index
            await executeStep(step, at: index)
            
            if executionStatus == .error || executionStatus == .cancelled {
                break
            }
        }
        
        if executionStatus == .inProgress {
            executionStatus = .completed
        }
        
        isExecuting = false
    }
    
    @MainActor
    private func executeStep(_ step: TemplateStep, at index: Int) async {
        updateStepStatus(at: index, status: .inProgress)
        
        do {
            // For now, just simulate step execution
            // TODO: Integrate with actual RxClipsCore engine
            
            addLogEntry("Executing step: \(step.name)", level: .info)
            
            // Simulate execution time
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            addLogEntry("Step '\(step.name)' executed successfully", level: .info)
            updateStepStatus(at: index, status: .completed)
        } catch {
            addLogEntry("Step '\(step.name)' failed: \(error.localizedDescription)", level: .error)
            updateStepStatus(at: index, status: .error, errorMessage: error.localizedDescription)
            executionStatus = .error
        }
    }
    
    private func updateStepStatus(at index: Int, status: StepExecutionState.ExecutionStatus, errorMessage: String? = nil) {
        guard index < stepStates.count else { return }
        
        stepStates[index] = StepExecutionState(
            stepName: stepStates[index].stepName,
            status: status,
            startTime: stepStates[index].startTime ?? (status == .inProgress ? Date() : nil),
            endTime: status == .completed || status == .error ? Date() : nil,
            errorMessage: errorMessage,
            logEntries: stepStates[index].logEntries
        )
    }
    
    private func addLogEntry(_ message: String, level: LogLevel) {
        let entry = LogEntry(
            timestamp: Date(),
            stepName: currentStepIndex < stepStates.count ? stepStates[currentStepIndex].stepName : nil,
            level: level,
            message: message
        )
        
        logEntries.append(entry)
        
        if currentStepIndex < stepStates.count {
            var stepState = stepStates[currentStepIndex]
            stepState.logEntries.append(entry)
            stepStates[currentStepIndex] = stepState
        }
    }
    
    private func handleFormRequest(schema: [String: Any], completion: @escaping ([String: Any]) -> Void) {
        currentStepFormSchema = schema
        formCompletionCallback = completion
        showStepForm = true
    }
    
    func submitGlobalForm(_ formData: [String: Any]) {
        globalFormData = formData
        showGlobalForm = false
        executeSteps()
    }
    
    func submitStepForm(_ formData: [String: Any]) {
        currentStepFormData = formData
        showStepForm = false
        formCompletionCallback?(formData)
        formCompletionCallback = nil
    }
    
    func cancelExecution() {
        isExecuting = false
        executionStatus = .cancelled
        addLogEntry("Execution cancelled by user", level: .warning)
    }
    
    func clearLogs() {
        logEntries.removeAll()
        for index in stepStates.indices {
            stepStates[index].logEntries.removeAll()
        }
    }
    
    func retryExecution() {
        resetExecution()
        setupStepStates()
        startExecution()
    }
}

// MARK: - Supporting Types

struct StepExecutionState {
    let stepName: String
    let status: ExecutionStatus
    let startTime: Date?
    let endTime: Date?
    let errorMessage: String?
    var logEntries: [LogEntry]
    
    enum ExecutionStatus {
        case notStarted
        case inProgress
        case completed
        case error
        case skipped
    }
    
    var duration: TimeInterval? {
        guard let startTime = startTime, let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let stepName: String?
    let level: LogLevel
    let message: String
    
    enum LogLevel {
        case debug
        case info
        case warning
        case error
    }
}