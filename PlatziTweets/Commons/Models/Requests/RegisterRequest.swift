//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 01/07/21.
//

import Foundation

struct RegisterRequest:Codable {
    let email:String
    let password:String
    let names:String
}
