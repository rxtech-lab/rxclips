//
//  AddRepositorySheet.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import SwiftUI

struct AddRepositorySheet: View {
    @Bindable var viewModel: RepositoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var url = ""
    @State private var resolverType: Repository.ResolverType = .http
    @State private var repositoryDescription = ""
    @State private var isValidating = false
    @State private var validationMessage = ""
    @State private var isValid = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Repository Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Repository URL", text: $url)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: url) { _, _ in
                            validateURL()
                        }
                    
                    Picker("Resolver Type", selection: $resolverType) {
                        ForEach(Repository.ResolverType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    TextField("Description (Optional)", text: $repositoryDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                } header: {
                    Text("Repository Details")
                }
                
                Section {
                    HStack {
                        if isValidating {
                            ProgressView()
                                .controlSize(.small)
                        }
                        
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundColor(isValid ? .green : .red)
                    }
                    
                    Button("Test Connection") {
                        testConnection()
                    }
                    .disabled(url.isEmpty || isValidating)
                } header: {
                    Text("Validation")
                }
            }
            .navigationTitle("Add Repository")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addRepository()
                        dismiss()
                    }
                    .disabled(name.isEmpty || url.isEmpty || !isValid)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private func validateURL() {
        guard !url.isEmpty else {
            validationMessage = ""
            isValid = false
            return
        }
        
        if viewModel.validateRepositoryURL(url) {
            validationMessage = "URL format is valid"
            isValid = true
        } else {
            validationMessage = "Invalid URL format"
            isValid = false
        }
    }
    
    private func testConnection() {
        guard !url.isEmpty else { return }
        
        isValidating = true
        validationMessage = "Testing connection..."
        
        Task {
            let connectionResult = await viewModel.testRepositoryConnection(url)
            
            await MainActor.run {
                isValidating = false
                if connectionResult {
                    validationMessage = "Connection successful"
                    isValid = true
                } else {
                    validationMessage = "Connection failed"
                    isValid = false
                }
            }
        }
    }
    
    private func addRepository() {
        let trimmedDescription = repositoryDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.addRepository(
            name: name,
            url: url,
            resolverType: resolverType,
            repositoryDescription: trimmedDescription.isEmpty ? nil : trimmedDescription
        )
    }
}