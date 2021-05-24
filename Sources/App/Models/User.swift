//
//  File.swift
//  
//
//  Created by Maurício de Freitas Sayão on 18/05/21.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema: String = "user"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    @Children(for: \.$user)
    var acronyms: [Acronym]
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String) {
        self.name = name
        self.username = username
    }
    
}
