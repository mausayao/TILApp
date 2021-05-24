//
//  File.swift
//  
//
//  Created by Maurício de Freitas Sayão on 18/05/21.
//

import Vapor
import Fluent

struct AcronymController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let acronymRoutes = routes.grouped("api", "v1", "acronym")
        acronymRoutes.get(use: getAll)
        acronymRoutes.post(use: create)
        acronymRoutes.put(":id", use: update)
        acronymRoutes.delete(":id", use: delete)
        acronymRoutes.get( use: search)
        acronymRoutes.get("first", use: getFirst)
        acronymRoutes.get("sorted", use: sorted)
        acronymRoutes.get(":id", "user", use: getUser)
        
        acronymRoutes.post(":acronymID","categories", ":categoryID", use: addCategory)
        acronymRoutes.get(":acronymID","categories", use: getAcronymCategories)
        acronymRoutes.delete(":acronymID","categories", ":categoryID", use: removeCategory)
    }
    
    func getUser(_ req: Request) -> EventLoopFuture<User> {
       return Acronym
        .find(req.parameters.get("id"), on: req.db)
        .unwrap(or: Abort(.noContent))
        .flatMap { acronym in
            acronym.$user.get(on: req.db)
        }
    }
    
    func getAll(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let dto = try req.content.decode(CreateAcronymData.self)
        
        let acronym = Acronym(short: dto.short,
                              long: dto.long,
                              userId: dto.userID)
        
        return acronym.save(on: req.db).map { acronym }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let update = try req.content.decode(CreateAcronymData.self)
        
        return Acronym.find(
            req.parameters.get("id"),
            on: req.db
        ).unwrap(or: Abort(.notFound))
        .flatMap { acronym in
            acronym.short = update.short
            acronym.long = update.long
            acronym.$user.id = update.userID
            
            return acronym.save(on: req.db).map{ acronym }
        }
    }
    
    func delete(_ req: Request) -> EventLoopFuture<HTTPStatus>  {
        Acronym.find(
            req.parameters.get("id"),
            on: req.db
        ).unwrap(or: Abort(.noContent))
        .flatMap{ acronym in
            acronym.delete(on: req.db)
                .transform(to: .noContent)
        }
    }
    
    func search(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        
        guard let search = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == search)
            or.filter(\.$long == search)
        }.all()
    }
    
    func getFirst(_ req: Request) -> EventLoopFuture<Acronym> {
        return Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.noContent))
    }
    
    func sorted(_ req: Request) -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db)
            .sort(\.$short, .ascending).all()
    }
    
    func addCategory(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.noContent))
        
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.noContent))
        
        return acronymQuery.and(categoryQuery).flatMap { acronym, category in
            acronym.$categories
                .attach(category, on: req.db)
                .transform(to: .created)
        }
    }
    
    func getAcronymCategories(_ req: Request) -> EventLoopFuture<[Category]> {
        return Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.noContent))
            .flatMap { acronym in
                acronym.$categories.query(on: req.db).all()
            }
    }
    
    func removeCategory(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.noContent))
        
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.noContent))
        
        return acronymQuery.and(categoryQuery).flatMap { acronym, category in
            acronym.$categories
                .detach(category, on: req.db)
                .transform(to: .noContent)
        }
    }
    
}

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
