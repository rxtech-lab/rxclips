//
//  SidebarView.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import SwiftUI

struct SidebarView: View {
    @Bindable var viewModel: RepositoryViewModel
    
    var body: some View {
        List(selection: $viewModel.selectedRepository) {
            ForEach(viewModel.repositories, id: \.id) { repository in
                RepositoryRowView(repository: repository)
                    .tag(repository)
                    .contextMenu {
                        Button("Edit") {
                            // TODO: Edit repository
                        }
                        
                        Button("Delete", role: .destructive) {
                            viewModel.deleteRepository(repository)
                        }
                    }
            }
        }
        .navigationTitle("Repositories")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Repository") {
                    viewModel.isAddingRepository = true
                }
            }
        }
        .sheet(isPresented: $viewModel.isAddingRepository) {
            AddRepositorySheet(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct RepositoryRowView: View {
    let repository: Repository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(repository.name)
                .font(.headline)
            
            Text(repository.url)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let repositoryDescription = repository.repositoryDescription {
                Text(repositoryDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}