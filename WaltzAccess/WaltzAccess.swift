//
//  WaltzAccess.swift
//  WREFramework
//
//  Created by Guillaume Vachon on 2018-08-10.
//  Copyright © 2018 Waltz. All rights reserved.
//

public class InvitationResponse : NSObject, JSONDecodable, JSONEncodable {
    
    public enum InvitationStatus : String {
        
        case SENT
        
        case APPROVED_BY_ADMIN
        
        case APPROVED_BY_SECURITY_GUARD
        
        case REJECTED_BY_ADMIN
        
        case REJECTED_BY_SECURITY_GUARD
        
        case NO_APPROVAL_REQUIRED
        
        case CHECK_IN_REQUIRED
        
        case INVALID
    }
    
    public let status: WaltzAccess.InvitationResponse.InvitationStatus
    
    @objc public func getStatusName() -> String
    
    @objc public let organizationName: String
    
    @objc public let organizationAddress: String
    
    @objc public let doorScheduleStart: String
    
    @objc public let doorScheduleStop: String
    
    @objc public let guest: WaltzAccess.Person
    
    public let host: WaltzAccess.Person
    
    public let contact: WaltzAccess.Person?
    
    /// Creates an instance of the model with a `JSON` instance.
    /// - parameter json: An instance of a `JSON` value from which to
    ///             construct an instance of the implementing type.
    /// - throws: Any `JSON.Error` for errors derived from inspecting the
    ///           `JSON` value, or any other error involved in decoding.
    required public init(json: Freddy.JSON) throws
    
    /// Converts an instance of a conforming type to `JSON`.
    /// - returns: An instance of `JSON`.
    /// - Note: If conforming to `JSONEncodable` with a custom type of your own, you should return an instance of
    /// `JSON.dictionary`.
    public func toJSON() -> Freddy.JSON
}

public class PermissionsChecker {
    
    public static let sharedInstance: WaltzAccess.PermissionsChecker
    
    public var appCameraPermissions: CameraPersmissionsAuthStatus
    
    public func requestLocationPermission()
    
    public func requestPermissionForNotifications()
    
    public func cameraPermissionsHaveBeenGranted()
}

public class Person : NSObject, JSONDecodable, JSONEncodable {
    
    public let firstName: String?
    
    public let lastName: String?
    
    @objc public let name: String
    
    @objc public let email: String
    
    public let phone: String?
    
    public let avatarPath: String?
    
    @objc public init(firstName: String, lastName: String, email: String, phone: String?, avatarPath: String? = default)
    
    public init(name: String, email: String, phone: String?, avatarPath: String? = default)
    
    /// Creates an instance of the model with a `JSON` instance.
    /// - parameter json: An instance of a `JSON` value from which to
    ///             construct an instance of the implementing type.
    /// - throws: Any `JSON.Error` for errors derived from inspecting the
    ///           `JSON` value, or any other error involved in decoding.
    required public convenience init(json: Freddy.JSON) throws
    
    /// Converts an instance of a conforming type to `JSON`.
    /// - returns: An instance of `JSON`.
    /// - Note: If conforming to `JSONEncodable` with a custom type of your own, you should return an instance of
    /// `JSON.dictionary`.
    open func toJSON() -> Freddy.JSON
    
    open func getDictionnary() -> [String : Freddy.JSON]
}

public class WaltzSDKMgr {
    
    public static let sharedManager: WaltzAccess.WaltzSDKMgr
    
    public var delegate: WltzSDKMgrDelegate?
    
    public func initManager(licenseKey: String, appUid: String)
    
    public func beginTransaction()
    
    public func startGeofenceService(enteredWaltzGeofence: ((String) -> ())? = default)
    
    public func stopGeofenceService()
    
    public func getMyGuests()
    
    public func getMyInvitations()
    
    public func sendInvitation(firstName: String, lastName: String, email: String, phoneNumber: String?, startDate: Date, endDate: Date)
}

public protocol WltzSDKMgrDelegate {
    
    public func didFinishWaltzTransactionWithErrorCode(_ errorCode: SDKResponseCodes)
    
    public func didFinishWaltzGeofenceSetupWithErrorCode(_ errorCode: SDKResponseCodes)
    
    public func didGetWaltzMyGuestsWithErrorCode(_ errorCode: SDKResponseCodes, guests: [WaltzAccess.InvitationResponse]?)
    
    public func didGetWaltzMyInvitationsWithErrorCode(_ errorCode: SDKResponseCodes, invitations: [WaltzAccess.InvitationResponse]?)
    
    public func didSendWaltzInvitationWithErrorCode(_ errorCode: SDKResponseCodes)
}

extension ZBarSymbolSet : Sequence {
    
    /// Returns an iterator over the elements of this sequence.
    public func makeIterator() -> NSFastEnumerationIterator
}
