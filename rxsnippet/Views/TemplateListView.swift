//
//  TemplateListView.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import SwiftUI

struct TemplateListView: View {
    @Bindable var repositoryViewModel: RepositoryViewModel
    @Bindable var templateViewModel: TemplateViewModel
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    var filteredTemplates: [TemplateItem] {
        var templates = templateViewModel.templates
        
        if !searchText.isEmpty {
            templates = templates.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        if selectedCategory != "All" {
            templates = templates.filter { $0.category == selectedCategory }
        }
        
        return templates
    }
    
    var categories: [String] {
        let allCategories = Set(templateViewModel.templates.map(\.category))
        return ["All"] + allCategories.sorted()
    }
    
    var body: some View {
        VStack {
            if let selectedRepository = repositoryViewModel.selectedRepository {
                templateContent
                    .onChange(of: selectedRepository) { _, repository in
                        templateViewModel.loadTemplates(from: repository)
                    }
            } else {
                ContentUnavailableView(
                    "No Repository Selected",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Select a repository from the sidebar to view templates")
                )
            }
        }
        .navigationTitle("Templates")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if templateViewModel.canNavigateBack() {
                    Button("Back") {
                        templateViewModel.navigateBack()
                    }
                }
                
                Button("Refresh") {
                    templateViewModel.refreshTemplates()
                }
            }
        }
    }
    
    @ViewBuilder
    private var templateContent: some View {
        if templateViewModel.isLoading {
            ProgressView("Loading templates...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if templateViewModel.templates.isEmpty {
            ContentUnavailableView(
                "No Templates Found",
                systemImage: "doc.text.magnifyingglass",
                description: Text("This repository doesn't contain any templates")
            )
        } else {
            VStack(spacing: 0) {
                searchAndFilterBar
                
                Table(filteredTemplates, selection: $templateViewModel.selectedTemplate) {
                    TableColumn("Name") { template in
                        HStack {
                            Image(systemName: template.type == .folder ? "folder" : "doc.text")
                                .foregroundColor(template.type == .folder ? .blue : .secondary)
                            
                            Text(template.name)
                                .font(.headline)
                        }
                    }
                    .width(min: 200)
                    
                    TableColumn("Type") { template in
                        Text(template.type == .folder ? "Folder" : "File")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .width(60)
                    
                    TableColumn("Category") { template in
                        Text(template.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .width(100)
                    
                    TableColumn("Description") { template in
                        Text(template.description ?? "No description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .width(min: 200)
                }
                .onTapGesture(count: 2) {
                    handleDoubleClick()
                }
            }
        }
    }
    
    @ViewBuilder
    private var searchAndFilterBar: some View {
        HStack {
            TextField("Search templates...", text: $searchText)
                .textFieldStyle(.roundedBorder)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 150)
        }
        .padding()
    }
    
    private func handleDoubleClick() {
        guard let selectedTemplate = templateViewModel.selectedTemplate else { return }
        
        if selectedTemplate.type == .folder {
            templateViewModel.navigateToFolder(selectedTemplate.path)
        } else {
            // Template file selected - this will be handled by ExecutionDetailView
        }
    }
}