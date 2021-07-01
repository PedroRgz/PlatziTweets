//
//  PostRequest.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 01/07/21.
//

import Foundation

struct PostRequest:Codable {
    let text:String
    let imageUrl:String?
    let videoUrl:String?
    let location:PostRequesLocation?
}
