import Fluent
import Vapor

func routes(_ app: Application) throws {
    let acronymController = AcronymController()
    let userController = UserController()
    let categoryController = CategoryController()
    
    try app.register(collection: acronymController)
    try app.register(collection: userController)
    try app.register(collection: categoryController)

}
