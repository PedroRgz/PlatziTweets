//
//  Post.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 01/07/21.
//

import Foundation

struct Post:Codable {
    let id:String
    let author:User
    let imagenUrl:String
    let videoUrl:String
    let text:String
    let location:PostLocation
    let hasVideo:Bool
    let hasImage:Bool
    let hasLocation:Bool
    let createdAt:String
}
