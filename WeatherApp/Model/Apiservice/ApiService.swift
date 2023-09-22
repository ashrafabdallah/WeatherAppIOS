//
//  ApiSerice.swift
//  WeatherApp
//
//  Created by Ashraf Eltantawy on 21/09/2023.
//

import Foundation
import Alamofire
class Api {
    static let shared = Api() // singltone
    func fetchData <T:Codable> (url:String,completion:@escaping(T?,Error?)->Void){
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                switch response.result{
                case.success(_):
                    do{
                        print(response)
                        guard let data = response.data else {return}
                        let responseData = try JSONDecoder().decode(T.self, from: data)
                        completion(responseData,nil)
                    }catch let jsonError{
                        print(jsonError)
                    }
                    
                case .failure(let error):
                    let statusCode = response.response?.statusCode ?? 0
                    if(statusCode>300)
                    {
                        // error from backEnd when backend return json error
                        completion(nil,error)
                    }else{
                        // error not internet ofline
                        completion(nil,error)
                    }
                }
                
            }
        
    }
}
