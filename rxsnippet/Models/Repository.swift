//
//  Repository.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import Foundation
import SwiftData

@Model
final class Repository {
    @Attribute(.unique) var id: UUID
    var name: String
    var url: String
    var resolverType: ResolverType
    var repositoryDescription: String?
    var createdAt: Date
    
    enum ResolverType: String, CaseIterable, Codable {
        case http = "http"
        
        var displayName: String {
            switch self {
            case .http:
                return "HTTP"
            }
        }
    }
    
    init(name: String, url: String, resolverType: ResolverType = .http, repositoryDescription: String? = nil) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.resolverType = resolverType
        self.repositoryDescription = repositoryDescription
        self.createdAt = Date()
    }
}