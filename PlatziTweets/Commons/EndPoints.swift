//
//  EndPoints.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 01/07/21.
//

import Foundation

struct EndPoints {
    static let domain = "https://platzi-tweets-backend.herokuapp.com/api/v1"
    static let login = EndPoints.domain + "/auth"
    static let register = EndPoints.domain + "/register"
    static let getPost = EndPoints.domain + "/posts"
    static let post = EndPoints.domain + "/posts"
    static let delete = EndPoints.domain + "/posts/"
}
