//
//  PostController.swift
//  
//
//  Created by Noah Pikielny on 3/19/22.
//

import Fluent
import Vapor

struct PostController: RouteCollection {
    // Adds routes
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.get("all", use: getAllPosts)
        posts.get(":postID", use: getPost)
        
        posts.post(use: create)
        
        posts.put(":postID", use: update)
        
        posts.delete(":postID", use: delete)
        posts.delete("reset", ":username", ":password", use: reset)
    }
    
    func getAllPosts(req: Request) -> EventLoopFuture<[Post]> {
        if let poster = req.parameters.get("poster") {
            return Post.query(on: req.db)
                .filter(\.$poster == poster)
                .all()
        }
        return Post.query(on: req.db).all()
    }
    
    func getPost(req: Request) throws -> EventLoopFuture<Post> {
        Post.find(req.parameters.get("postID"), on: req.db)
            .unwrap(or: RouteError.notFound)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Post> {
        guard let post = try? req.content.decode(Post.self) else { throw RouteError.unsupportedMediaType }
        if let _ = post.poster, let _ = post.body, let _ = post.title {
            return post.save(on: req.db).transform(to: post)
        } else {
            throw RouteError.partialInformation("Requires poster, body, and title")
        }
    }
    
    func update(req: Request) throws -> EventLoopFuture<Post> {
        guard let newPost = try? req.content.decode(Post.self) else { throw RouteError.unsupportedMediaType }
        
        guard let id: UUID = req.parameters.get("postID"),
              let poster = newPost.poster,
              let body = newPost.body else {
                  throw RouteError.partialInformation("Requires poster: <String> and body: <String>")
              }
        
        return Post.query(on: req.db)
            .filter(\.$id == id)
            .filter(\.$poster == poster)
            .first()
            .unwrap(or: RouteError.notFound)
            .flatMap { post in
                post.body = body;
                return post.update(on: req.db)
                    .transform(to: post)
            }
    }
    
    var username: String
    var password: String
    
    func reset(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        if req.parameters.get("username") == username && req.parameters.get("password") == password { // change these to secrets
            return Post.query(on: req.db).all()
                .map { $0.delete(on: req.db) }
                .transform(to: .ok)
        } else {
            throw RouteError.unauthorized
        }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<Post> {
        guard let postInformation = try? req.content.decode(Post.self) else { throw RouteError.unsupportedMediaType }
        guard let id: UUID = req.parameters.get("postID"),
              let poster = postInformation.poster else {
                  throw RouteError.partialInformation("Requires poster: <String>")
              }
        
        return Post.query(on: req.db)
            .filter(\.$id == id)
            .filter(\.$poster == poster)
            .first()
            .unwrap(or: RouteError.notFound)
            .flatMap { post in
                post.delete(on: req.db).transform(to: post)
            }
    }
}
