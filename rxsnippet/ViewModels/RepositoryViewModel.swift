//
//  RepositoryViewModel.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import Foundation
import SwiftData
import RxClipsCore

@Observable
final class RepositoryViewModel {
    var repositories: [Repository] = []
    var selectedRepository: Repository?
    var isLoading = false
    var errorMessage: String?
    var isAddingRepository = false
    
    private var modelContext: ModelContext?
    
    init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadRepositories()
    }
    
    func loadRepositories() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Repository>(
                sortBy: [SortDescriptor(\.name)]
            )
            repositories = try context.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load repositories: \(error.localizedDescription)"
        }
    }
    
    func addRepository(name: String, url: String, resolverType: Repository.ResolverType = .http, repositoryDescription: String? = nil) {
        guard let context = modelContext else { return }
        
        isLoading = true
        errorMessage = nil
        
        let repository = Repository(
            name: name,
            url: url,
            resolverType: resolverType,
            repositoryDescription: repositoryDescription
        )
        
        context.insert(repository)
        
        do {
            try context.save()
            repositories.append(repository)
        } catch {
            errorMessage = "Failed to add repository: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteRepository(_ repository: Repository) {
        guard let context = modelContext else { return }
        
        context.delete(repository)
        
        do {
            try context.save()
            repositories.removeAll { $0.id == repository.id }
            
            if selectedRepository?.id == repository.id {
                selectedRepository = nil
            }
        } catch {
            errorMessage = "Failed to delete repository: \(error.localizedDescription)"
        }
    }
    
    func validateRepositoryURL(_ url: String) -> Bool {
        guard let url = URL(string: url) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
    
    func testRepositoryConnection(_ url: String) async -> Bool {
        do {
            guard let baseUrl = URL(string: url) else { return false }
            let httpSource = HttpRepositorySource(baseUrl: baseUrl)
            _ = try await httpSource.list(path: nil)
            return true
        } catch {
            return false
        }
    }
}