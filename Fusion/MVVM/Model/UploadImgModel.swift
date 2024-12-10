//
//  UploadImgModel.swift
//  Fusion
//
//  Created by meet sharma on 23/01/23.
//

import Foundation

// MARK: - Welcome
struct UploadImgModel: Codable {
    var data: DataClass?
    var success: Bool?
    var status: Int?
}

// MARK: - DataClass
struct DataClass: Codable {
    var id, title: String?
    var urlViewer: String?
    var url, display_url: String?
    var width, height, size, time: Int?
    var expiration: Int?
    var image, thumb, medium: Image?
    var deleteURL: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case urlViewer
        case url
        case display_url
        case width, height, size, time, expiration, image, thumb, medium
        case deleteURL
    }
}

// MARK: - Image
struct Image: Codable {
    var filename, name, mime, imageExtension: String?
    var url: String?

    enum CodingKeys: String, CodingKey {
        case filename, name, mime
        case imageExtension
        case url
    }
}
