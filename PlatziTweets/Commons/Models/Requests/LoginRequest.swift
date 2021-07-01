//
//  LoginRequest.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 01/07/21.
//

import Foundation

struct LoginRequest:Codable {
    let email:String
    let password:String
}
