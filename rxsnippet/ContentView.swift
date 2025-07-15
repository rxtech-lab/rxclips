//
//  ContentView.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var repositoryViewModel = RepositoryViewModel()
    @State private var templateViewModel = TemplateViewModel()
    @State private var executionViewModel = ExecutionViewModel()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: repositoryViewModel)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } content: {
            TemplateListView(
                repositoryViewModel: repositoryViewModel,
                templateViewModel: templateViewModel
            )
            .navigationSplitViewColumnWidth(min: 400, ideal: 500)
        } detail: {
            ExecutionDetailView(
                templateViewModel: templateViewModel,
                executionViewModel: executionViewModel
            )
            .navigationSplitViewColumnWidth(min: 500, ideal: 600)
        }
        .onAppear {
            repositoryViewModel.setModelContext(modelContext)
        }
    }
}
