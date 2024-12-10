//
//  ViewModelCreateNote.swift
//  Fusion
//
//  Created by Apple on 02/01/23.
//

import UIKit
import SDWebImage
import FirebaseDatabase

enum imageError: Error{
    case badurl
}
class OpenAIService: ObservableObject{
    var viewModel = ImgUploadVM()

    func generateImage(from prompt: String,obj:CreateNotesVC) async throws -> [Photo]{
//        DispatchQueue.main.async {
//            activityIndicatorBegin(view: keyWindow)
//        }
       
        saveDotStatus(dot: 1)
        await obj.checkDotStatus()
        guard let urlRequest = URL(string: apiForImageCreate) else { throw imageError.badurl }
        var request = URLRequest(url: urlRequest)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "size": Store.imageSize ?? ""
        ]
        print(parameters)
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        request.httpBody = jsonData

        let (data, _) = try await URLSession.shared.data(for: request)
        let dalleResponse = try? JSONDecoder().decode(DALLEResponse.self, from: data)
        print(dalleResponse?.data ?? [])
        if dalleResponse?.data.count ?? 0 == 0{
            saveDotStatus(dot: 2)
            await obj.checkDotStatus()
        }else{
            saveDotStatus(dot: 1)
            await obj.checkDotStatus()
        }
        return dalleResponse?.data ?? []

    }
    func generateImageUpload(from prompt: String,obj:CreditsVC) async throws -> [Photo]{
//        DispatchQueue.main.async {
//            activityIndicatorBegin(view: keyWindow)
//        }
        saveDotStatus(dot: 1)
        await obj.checkDotStatus()
        guard let urlRequest = URL(string: apiForImageCreate) else { throw imageError.badurl }
        var request = URLRequest(url: urlRequest)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "size": Store.imageSize ?? ""
        ]
        print(parameters)
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        request.httpBody = jsonData

        let (data, _) = try await URLSession.shared.data(for: request)
        let dalleResponse = try? JSONDecoder().decode(DALLEResponse.self, from: data)
        print(dalleResponse?.data ?? [])

        if dalleResponse?.data.count ?? 0 == 0{
            saveDotStatus(dot: 2)
            await obj.checkDotStatus()
        }else{
            saveDotStatus(dot: 1)
            await obj.checkDotStatus()
        }
        return dalleResponse?.data ?? []

    }
    func generateImageNotes(from prompt: String,name:String,obj:LoginVC) async throws -> [Photo]{
//        DispatchQueue.main.async {
//            activityIndicatorBegin(view: keyWindow)
//        }
        saveDotStatus(dot: 1)
//        await obj.checkDotStatus()
        guard let urlRequest = URL(string: apiForImageCreate) else { throw imageError.badurl }
        var request = URLRequest(url: urlRequest)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "size": Store.imageSize ?? ""
        ]
        print(parameters)
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        request.httpBody = jsonData

        let (data, _) = try await URLSession.shared.data(for: request)
        let dalleResponse = try? JSONDecoder().decode(DALLEResponse.self, from: data)
        print(dalleResponse?.data ?? [])
    
//        if dalleResponse?.data.count ?? 0 == 0{
//            saveDotStatus(dot: 2)
//            await obj.checkDotStatus()
//        }else{
//            saveDotStatus(dot: 1)
//            await obj.checkDotStatus()
//        }
        return dalleResponse?.data ?? []

    }
}
