//
//  File.swift
//  
//
//  Created by Maurício de Freitas Sayão on 24/05/21.
//

import Vapor

struct CategoryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "v1", "category")
        group.get( use: getAll)
        group.post(use: create)
        group.get(":id", use: getOne)
        group.get(":id", "acronyms", use: getAcronyms)
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        
        return category.save(on: req.db).map { category }
    }
    
    func getAll(_ req: Request) -> EventLoopFuture<[Category]> {
        return Category.query(on: req.db).all()
    }
    
    func getOne(_ req: Request) -> EventLoopFuture<Category> {
        return Category.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.noContent))
    }
    
    func getAcronyms(_ req: Request) -> EventLoopFuture<[Acronym]> {
        return Category.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.noContent))
            .flatMap { category in
                category.$acronyms.get(on: req.db)
            }
    }
    
}
