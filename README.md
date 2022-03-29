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
     


