//
//  InvitationResponse.swift
//  Building Access
//
//  Created by Guillaume Vachon on 2017-12-07.
//  Copyright © 2017 Waltz. All rights reserved.
//

import Alamofire
import Freddy

public class InvitationResponse: NSObject, JSONDecodable, JSONEncodable {
    
    public enum InvitationStatus: String {
        case SENT
        case APPROVED_BY_ADMIN
        case APPROVED_BY_SECURITY_GUARD
        case REJECTED_BY_ADMIN
        case REJECTED_BY_SECURITY_GUARD
        case NO_APPROVAL_REQUIRED
        case CHECK_IN_REQUIRED
        case INVALID
        
        func getNameDescription() -> String {
            switch self {
            case .SENT:
                return Langage.Localized("sent")
            case .APPROVED_BY_ADMIN:
                return Langage.Localized("approved_by_admin")
            case .APPROVED_BY_SECURITY_GUARD:
                return Langage.Localized("approved_by_security_guard")
            case .REJECTED_BY_ADMIN:
                return Langage.Localized("rejected_by_admin")
            case .REJECTED_BY_SECURITY_GUARD:
                return Langage.Localized("rejected_by_security_guard")
            case .NO_APPROVAL_REQUIRED:
                return Langage.Localized("ok")
            case .CHECK_IN_REQUIRED:
                return Langage.Localized("check_in_required")
            default:
                return Langage.Localized("unknown")
            }
        }
    }
    
    public let status: InvitationStatus
    @objc public func getStatusName() -> String { return status.getNameDescription() }
    @objc public let organizationName: String
    @objc public let organizationAddress: String
    @objc public let doorScheduleStart: String
    @objc public let doorScheduleStop: String
    @objc public let guest: Person
    public let host: Person
    public let contact: Person?
    
    public required init(json: JSON) throws {
        status = InvitationStatus(rawValue: try json.getString(at: "status")) ?? .INVALID
        organizationName = try! json.getString(at: "organizationName")
        organizationAddress = try! json.getString(at: "organizationAddress")
        doorScheduleStart = try! json.getString(at: "doorScheduleStart")
        doorScheduleStop = try! json.getString(at: "doorScheduleStop")
        guest = Person(firstName: try! json.getString(at: "guestFirstName"), lastName: try! json.getString(at: "guestLastName"), email: try! json.getString(at: "guestEmail"), phone: try! json.getString(at: "guestPhone"), avatarPath: try? json.getString(at: "guestAvatar"))
        host = Person(firstName: try! json.getString(at: "hostFirstName"), lastName: try! json.getString(at: "hostLastName"), email: try! json.getString(at: "hostEmail"), phone: try! json.getString(at: "hostPhone"), avatarPath: try? json.getString(at: "hostAvatar"))
        if let contactfirstName = try? json.getString(at: "contactFirstName") {
            contact = Person(firstName: contactfirstName, lastName: try! json.getString(at: "contactLastName"), email: try! json.getString(at: "contactEmail"), phone: try! json.getString(at: "contactPhone"))
        }
        else {
            contact = nil
        }
    }
    
    public func toJSON() -> JSON {
        var dictionary = [
            "status": status.toJSON(),
            "organizationName": organizationName.toJSON(),
            "organizationAddress": organizationAddress.toJSON(),
            "doorScheduleStart": doorScheduleStart.toJSON(),
            "doorScheduleStop": doorScheduleStop.toJSON(),
            "guestFirstName": guest.firstName!.toJSON(),
            "guestLastName": guest.lastName!.toJSON(),
            "guestEmail": guest.email.toJSON(),
            "guestPhone": guest.phone!.toJSON(),
            "hostFirstName": host.firstName!.toJSON(),
            "hostLastName": host.lastName!.toJSON(),
            "hostEmail": host.email.toJSON(),
            "hostPhone": host.phone!.toJSON()
            ]
        if let guestAvatar = guest.avatarPath {
            dictionary["guestAvatar"] = guestAvatar.toJSON()
        }
        if let hostAvatar = host.avatarPath {
            dictionary["hostAvatar"] = hostAvatar.toJSON()
        }
        
        if let newContact = contact {
            dictionary["contactFirstName"] = newContact.firstName!.toJSON()
            dictionary["contactLastName"] = newContact.lastName!.toJSON()
            dictionary["contactEmail"] = newContact.email.toJSON()
            dictionary["contactPhone"] = newContact.phone!.toJSON()
        }
        
        return .dictionary(dictionary)
    }
}
