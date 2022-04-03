# ios-course-message-board

A simple server in Swift (Fluent & Vapor) for use in AppDev's Intro to iOS Course

## Endpoints

All endpoints use the following `Song` model:
```
{
    id: <UUID?>,
    title: <String?>,
    body: <String?>,
    poster: <Int?>,
    timeStamp: <Date?>
}
```

Both id and timeStamp are fully managed by the backend.

### Status Codes
200: Success

400: Partial Information – The route was not supplied with enough information (whether parameters or body)

400: Unsupported Media Type – Unable to convert request body into a Song. This usually arises from having no body.

401: Unauthorized

404: Not found

### GET /
Return Type: `String`

Requirements: None

Returns "It works!".

### GET /hello/
Return Type: `String`

Requirements: None

Returns "Hello, world".

### GET /posts/all/
Return Type: `[Post]`

Requirements: None

Returns a list of all posts

### GET /posts/{postId}/
Return Type: `Post`

Requirements:

    - parameter: postid

Returns a song if there is a song in the database where `post.id == postid`

### POST /posts/

Return Type: `Post`

Requirements:

    - body: poster, body, title

Returns the new song

### PUT /posts/{postid}/
Return Type: `Post`

Requirements: 

    - parameters: postid

    - body: poster, body

Returns the updated song

### DELETE /posts/{postid}/
Return Type: `Post`

Requirements:

    - parameter: postid

    - body: poster
     
# Backend Walkthrough
The backend for this project is written entirely in Swift in hopes that future instructors of the Intro to iOS Course will be able to make the changes they see fit.
Also, because I wanted to make a backend in Swift.

This project uses Vapor for the actual server and Fluent (an ORM) for managing tables.

## Building
You will probably need to install vapor.
I did this with brew: `brew install vapor`

There are a few steps for runing this project locally.

1. Set the scheme to `Debug` instead of `ios-course-messageBoard`

2. Set your working directory

    1. Changing the Scheme
    
        a. edit the current scheme
        b. set run -> option -> use custom working directory = true
        c. set the working directory to the path that your project directory is located at
        
    2. Running your Database
    
        a. run the docker app (daemon)
        b. docker compose up db
        * control C to close when done testing *
        
    3. Run the Server
    
        a. press run on Xcode
        
## Potential Errors
1. If your ports are taken: Sometimes postgres doesn't exit properly. Check activity monitor for any processes with the keyword postgres. Kill all of them
2. Sometimes Xcode will detach from the project. This only happened to me once and Idk when it happens or why. In this case, go to Xcode, go to the debug menu, select attach to process, and find the process that matches the scheme. Press the stop button on Xcode.

## Vapor
### Configure
This just sets up the postgres database. This should be handled with the two schemes.

It will also set up migrations (you should only care about this if you are creating a new table).
It also sets up routes–don't touch this. All changes to routes should be in the routes file.

### Routes
You can configure specific routes in this file; however; I advise you create clusters in separate files if you will be adding a lot of routes. 
For individual routes, the syntax should be app.<insert request type>(String...) { req in <insert code> }
For complex closures where the compiler is unable to infer the return type you write the closure to be { req -> <return type> in <insert code> }
To take parameters in the url, start your parameter with ':'. This will make the result available in the closure through the `parameters.get(_: String): (String) -> String?` function.
For example:
```
app.delete(":postID") { req in 
    guard let id: UUID = req.parameters.get("postID") else { throw Abort(.notFound) }
    ...
}
        
```
Notice that we can implicitly convert to other types (for a set of convertible types)–I can't remember which protocol this is, but probably StringLiteral.
You can get the content or body of the request using `req.content`. `content` also has a method `decode<T: Codable.Type>(T.self)-> T` for your convenience.

### RouteError
Route error is my specially built error type because the one that Vapor provides had some odd error codes–probably because I was incorrectly interpreting the names but oh well. The errors will not produce an error for URLSessions because it will actually return a body.
Both `partialInformation` and `unsupportedMediaType` are a `400` error code (bad request). If users are curious for information, they can decode the error type or print the response's body.

## Fluent
Fluent is the ORM of choice for this project. An ORM will take in a model `Model & Content` in our case and will convert the fields of the model to a table in sequel. I presume this leverages `Mirror`, but I am not sure. Any changes to said model or tables are handled through migrations. I have heard these explained as almost like git, a set of changes that should be applied in sequece, but for a database instead of a repository. Migrations must be added in the configure function because these deal directly with the database. Lastly, Controllers or `RouteCollection`s are used to cluster our routes for a table–i.e. it's a techinque to keep things organized. We add the routes from a cluster to our app in the routes file: `app.register(collection: RouteCollection)`.

### Models
To create a new table we create a new model. These models need their fields marked with the @Field tag–look at the given models for more. Every model needs an initializer: `init() {}`. How an empty initializer is valid is beyond me, but we don't really need to worry about that.
Every field must be registered in the prepare function of the Migration. 

### Queries
There are two ways to get item(s) from the database. If you only want one, and you know its id, use `ModelType.find(_ id: UUID, _ on: Database)`.

If you do not know the id, or want a set, use `ModelType.query(on: Database)`. You can apply filters to get your desired item.
Filters do not use closures and hence require an understanding of KeyPaths.
Quick aside on keypaths: For closures where we can assume what the models we are comparing/using are, we can create a path for variables. KeyPaths use `\` as a standin for the variable. So for example, if we wanted to check if something's `name` property is "Noah" (the best name), we could use a filter like `.filter(\.$name == "noah"). The `$` character signifies we are using a column from the table. It can be scary. 

If you are expecting one item, follow your filter with a `.first()` call–think of this exactly like `Array.first()`. To deal with optionals, use the `.unwrap(or: Error)` which we can think of as optional chaining.

It will return an optional. If you are expecting a set and it has been properly filtered, follow your filter with a `.all()` call. This will return a `[Model]`.


