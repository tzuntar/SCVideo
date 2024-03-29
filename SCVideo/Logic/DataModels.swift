//
//  User.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/12/22.
//

import Foundation

public let APIURL = SettingsHelper.getApiUrl()

struct Token: Codable {
    let accessToken: String
    let refreshToken: String
}

struct UserSession: Codable {
    let token: Token
    let user: User
}

class User: Codable {
    let id_user: Int
    let identifier: String
    let full_name: String
    let username: String
    let email: String?
    let phone: String?
    let password: String
    //let registration_date: Date
    let registration_date: String
    let is_deleted: Int
    let bio: String?
    let photo_uri: String?
}

enum PostType: String {
    case photo = "photo", video = "video"
}

class Post: Codable {
    let id_post: Int
    let identifier: String
    let type: String
    let title: String?
    let description: String?
    let content_uri: String
    let user: User?
    //let added_on: Date
    let added_on: String
    //let is_deleted: Bool
    let is_deleted: Int
    //let is_hidden: Bool
    let is_hidden: Int
    var is_liked: Int
    let comments: [Comment]?
}

struct Comment: Codable {
    let id_comment: Int
    let identifier: String
    let content: String
    let user: User
    let is_hidden: Int
    let is_deleted: Int
}
