//
//  File.swift
//  
//
//  Created by Maurício de Freitas Sayão on 17/05/21.
//

import Fluent
import Vapor

final class Acronym: Model {
    
    static let schema: String = "acronym"
    
    @ID
    var id: UUID?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    @Parent(key: "userID")
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self,
              from: \.$acronym,
              to: \.$category)
    var categories: [Category]
    
    init() {}
    
    init(id: UUID? = nil, short: String, long: String, userId: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userId
    }
    
}

extension Acronym: Content {}
