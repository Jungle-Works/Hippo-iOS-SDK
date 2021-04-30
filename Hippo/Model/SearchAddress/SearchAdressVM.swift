//
//  SearchAdressVM.swift
//  Hippo
//
//  Created by Arohi Magotra on 28/04/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation

protocol SearchAddressProtocol {
    func getaddress(indexPath : Int) -> Address
    func getAddressCount() -> Int
    func removeAllAddress()
}

final
class SearchAdressVM {
    
    
    //MARK:- Variables
    var searchText : String? {
        didSet {
            getAddress()
        }
    }
    private var addressArr : [Address]?
    var responseRecieved : (()->())?
    
    private func getAddress() {
        
        let params = ["text" : searchText ?? "", "currentlatitude" : 0, "currentlongitude" : 0, "skip_cache" : 0, "fm_token" : "e07a4b30-524a-11ea-ad3a-9bfad3330c22", "offering" : 2] as [String : Any]
        
        HTTPClient.makeConcurrentConnectionWith(method: .GET, enCodingType: .url, para: params,baseUrl: FuguEndPoints.searchAddress.rawValue, extendedUrl: "") { (response, error, _, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                self.responseRecieved?()
                print("Error",error ?? "")
                return
            }
            
            guard let response = response as? [String : Any], let data = response["data"] as? [[String : Any]] else {
                return
            }
            
            let jsonData = self.jsonToNSData(json: data)
            let address = try? JSONDecoder().decode([Address].self, from: jsonData ?? Data())
            self.addressArr = [Address]()
            self.addressArr = address
            self.responseRecieved?()
        }
        
    }
    
    // Convert from JSON to nsdata
    private func jsonToNSData(json: Any) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
}
extension SearchAdressVM : SearchAddressProtocol{
    func getAddressCount() -> Int {
        addressArr?.count ?? 0
    }
    
    func getaddress(indexPath: Int) -> Address {
        addressArr?[indexPath] ?? Address()
    }
    
    func removeAllAddress() {
        addressArr = nil
        responseRecieved?()
    }
}
