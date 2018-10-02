//
//  Person.swift
//  Building Access
//
//  Created by Guillaume Vachon on 2018-01-11.
//  Copyright © 2018 Waltz. All rights reserved.
//

import Foundation
import Freddy

public class Person: NSObject, JSONDecodable, JSONEncodable {

    public let firstName: String?
    public let lastName: String?
    @objc public let name: String
    @objc public let email: String
    public let phone: String?
    public let avatarPath: String?
    
    @objc public init(firstName: String, lastName: String, email: String, phone: String?, avatarPath: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        name = "\(firstName) \(lastName)"
        self.email = email
        self.phone = phone
        self.avatarPath = avatarPath
    }
    
    public init(name: String, email: String, phone: String?, avatarPath: String? = nil) {
        self.firstName = nil
        self.lastName = nil
        self.name = name
        self.email = email
        self.phone = phone
        self.avatarPath = avatarPath
    }
    
    public required convenience init(json: JSON) throws {
        self.init(firstName: try! json.getString(at: "firstName"), lastName: try! json.getString(at: "lastName"), email: try! json.getString(at: "email"), phone: try! json.getString(at: "mobile"))
    }
    
    open func toJSON() -> JSON {
        return .dictionary(getDictionnary())
    }
    
    open func getDictionnary() -> [String: JSON] {
        var dictionnary = ["firstName": firstName!.toJSON(),
                     "lastName": lastName!.toJSON(),
                     "email": email.toJSON()]
        if let newPhone = phone {
            dictionnary["mobile"] = newPhone.toJSON()
        }
        return dictionnary
    }
}
