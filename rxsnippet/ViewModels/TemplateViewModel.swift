//
//  TemplateViewModel.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import Foundation
import RxClipsCore

@Observable
final class TemplateViewModel {
    var templates: [TemplateItem] = []
    var selectedTemplate: TemplateItem?
    var currentPath: String = ""
    var isLoading = false
    var errorMessage: String?
    var navigationPath: [String] = []
    
    private var currentRepository: Repository?
    
    init() {}
    
    func loadTemplates(from repository: Repository, path: String = "") {
        guard currentRepository?.id != repository.id || currentPath != path else { return }
        
        currentRepository = repository
        currentPath = path
        isLoading = true
        errorMessage = nil
        
        Task {
            await fetchTemplates()
        }
    }
    
    @MainActor
    private func fetchTemplates() async {
        guard let repository = currentRepository else { return }
        
        do {
            guard let baseUrl = URL(string: repository.url) else {
                errorMessage = "Invalid repository URL"
                isLoading = false
                return
            }
            
            let httpSource = HttpRepositorySource(baseUrl: baseUrl)
            let repositoryItems = try await httpSource.list(path: currentPath.isEmpty ? nil : currentPath)
            
            templates = repositoryItems.map { item in
                TemplateItem(
                    name: item.name,
                    description: item.description,
                    category: item.category,
                    path: item.path,
                    type: item.type == .file ? .file : .folder,
                    steps: [], // Steps will be loaded when needed
                    globalForm: nil // Global form will be loaded when needed
                )
            }
            
            updateNavigationPath()
            isLoading = false
        } catch {
            errorMessage = "Failed to load templates: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func navigateToFolder(_ folderPath: String) {
        loadTemplates(from: currentRepository!, path: folderPath)
    }
    
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        
        navigationPath.removeLast()
        let newPath = navigationPath.joined(separator: "/")
        loadTemplates(from: currentRepository!, path: newPath)
    }
    
    func canNavigateBack() -> Bool {
        return !navigationPath.isEmpty
    }
    
    private func updateNavigationPath() {
        navigationPath = currentPath.isEmpty ? [] : currentPath.split(separator: "/").map(String.init)
    }
    
    func selectTemplate(_ template: TemplateItem) {
        selectedTemplate = template
    }
    
    func refreshTemplates() {
        guard let repository = currentRepository else { return }
        loadTemplates(from: repository, path: currentPath)
    }
}

// MARK: - Supporting Types

struct TemplateItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String?
    let category: String
    let path: String
    let type: TemplateType
    let steps: [TemplateStep]
    let globalForm: [String: Any]?
    
    enum TemplateType {
        case file
        case folder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TemplateItem, rhs: TemplateItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct TemplateStep: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String?
    let script: String
    let form: [String: Any]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TemplateStep, rhs: TemplateStep) -> Bool {
        lhs.id == rhs.id
    }
}

