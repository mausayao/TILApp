//
//  File.swift
//  
//
//  Created by Maurício de Freitas Sayão on 23/05/21.
//

import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userRoute = routes.grouped("api", "v1", "user")
        userRoute.post(use: create)
        userRoute.get(use: getAll)
        userRoute.get(":id", use: getUser)
        userRoute.get(":id", "acronyms", use: getAcronyms)
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        
        return user.save(on: req.db).map { user }
    }
    
    func getAll(_ req: Request) -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func getUser(_ req: Request) -> EventLoopFuture<User> {
        return User
            .find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronyms(_ req: Request) -> EventLoopFuture<[Acronym]> {
        return User
            .find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.noContent))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
    
    
}
