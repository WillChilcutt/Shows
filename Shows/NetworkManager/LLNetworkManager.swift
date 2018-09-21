//
//  LLNetworkManager.swift
//  Shows
//
//  Created by Will Chilcutt on 9/18/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

protocol LLNetworkManagerServer
{
    var rawValue : String { get }
}

protocol LLNetworkManagerRequest
{
    var rawValue : String { get }
}

enum LLNetworkManagerNoResultResponse
{
    case success
    case failure(withError : Error)
}

enum LLNetworkManagerResultResponse<ResultType>
{
    case success(withResult : ResultType)
    case failure(withError : Error)
}

enum LLNetworkManagerError : Error
{
    case badURL
    case badReponse
}

typealias kLLNetworkManagerNoResultResponseBlock            = (LLNetworkManagerNoResultResponse) -> Void
typealias kLLNetworkManagerResultResponseBlock<ResultType>  = (LLNetworkManagerResultResponse<ResultType>) -> Void

class LLNetworkManager: NSObject
{
    private var server : LLNetworkManagerServer?
        
    static let sharedInstance : LLNetworkManager = LLNetworkManager()
    
    func setUp(withServer server : LLNetworkManagerServer)
    {
        self.server = server
    }
    
    func performRequest<ResultType : Codable>(_ request : LLNetworkManagerRequest, withResultType resultType : ResultType.Type, andCompletionBlock completionBlock : @escaping kLLNetworkManagerResultResponseBlock<ResultType>)
    {
        guard   let server = self.server,
                let rawURLString =  "\(server.rawValue)\(request.rawValue)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: rawURLString)
        else
        {
            completionBlock(.failure(withError:LLNetworkManagerError.badURL))
            return
        }
        
        print("Performing request: \(rawURLString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest)
        { (data, response, error) in
            
            if let error = error
            {
                completionBlock(.failure(withError:error))
            }
            else if let data = data
            {
                do
                {
                    let requestResult = try JSONDecoder().decode(ResultType.self, from: data)
                    
                    completionBlock(.success(withResult:requestResult))
                }
                catch let error
                {
                    completionBlock(.failure(withError:error))
                }
            }
            else
            {
                completionBlock(.failure(withError:LLNetworkManagerError.badReponse))
            }
        }
        
        task.resume()
    }
}
