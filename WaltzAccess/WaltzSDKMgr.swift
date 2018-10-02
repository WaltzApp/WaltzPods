//
//  WaltzSDKMgr.swift
//  WREFramework
//
//  Created by Guillaume Vachon on 2018-08-10.
//  Copyright © 2018 Waltz. All rights reserved.
//

public protocol WltzSDKMgrDelegate {
    func didFinishWaltzTransactionWithErrorCode(_ errorCode: SDKResponseCodes)
    func didFinishWaltzGeofenceSetupWithErrorCode(_ errorCode: SDKResponseCodes)
    func didGetWaltzMyGuestsWithErrorCode(_ errorCode: SDKResponseCodes, guests: [InvitationResponse]?)
    func didGetWaltzMyInvitationsWithErrorCode(_ errorCode: SDKResponseCodes, invitations: [InvitationResponse]?)
    func didSendWaltzInvitationWithErrorCode(_ errorCode: SDKResponseCodes)
}

public class WaltzSDKMgr: WaltzUserDelegate {
    
    private let DATE_FORMAT_TO_USE = "yyyy-MM-dd HH:mm"
    
    public static let sharedManager = WaltzSDKMgr()
    
    public var delegate: WltzSDKMgrDelegate?
    
    private var enteredWaltzGeofence: ((String)->())?
    
    public func initManager(licenseKey: String, appUid: String) {
        // Check for first run
        AppUser.sharedInstance().checkFirstRun()
        
        AppUser.sharedInstance().storeVendorInfo(licenseKey, vendorUUID: appUid)
        
        checkValidity()
    }
    
    func didFinishTransactionWithError(_ errorCodes: SDKResponseCodes) {
        if let newDelegate = delegate {
            newDelegate.didFinishWaltzTransactionWithErrorCode(errorCodes)
        }
    }
    
    func didFinishGeofenceSetupWithErrorCode(_ errorCodes: SDKResponseCodes) {
        if let newDelegate = delegate {
            newDelegate.didFinishWaltzGeofenceSetupWithErrorCode(errorCodes)
        }
    }
    
    func didGetMyGuestsWithErrorCode(_ errorCode: SDKResponseCodes, guests: [InvitationResponse]?) {
        if let newDelegate = delegate {
            newDelegate.didGetWaltzMyGuestsWithErrorCode(errorCode, guests: guests)
        }
    }
    
    func didGetMyInvitationsWithErrorCode(_ errorCode: SDKResponseCodes, invitations: [InvitationResponse]?) {
        if let newDelegate = delegate {
            newDelegate.didGetWaltzMyInvitationsWithErrorCode(errorCode, invitations: invitations)
        }
    }
    
    func didSendInvitationWithErrorCode(_ errorCode: SDKResponseCodes) {
        if let newDelegate = delegate {
            newDelegate.didSendWaltzInvitationWithErrorCode(errorCode)
        }
    }
    
    func handleGeofence(_ name: String) -> Bool {
        if let newEnteredWaltzGeofence = enteredWaltzGeofence {
            newEnteredWaltzGeofence(name)
            
            return false
        }
        else {
            return true
        }
    }
    
    private func checkValidity() {
        if let _ = AppUser.sharedInstance().getJWToken() {
            if AppUser.sharedInstance().checkIfTokenIsValid() {
                if let _ = AppUser.sharedInstance().getEmail() {
                    AppUser.sharedInstance().readOrFetchJWTToken(startTransaction: false)
                }
            }
        }
    }
    
    // MARK: WALTZ USER DELEGATE
    public func beginTransaction() {
        AppUser.sharedInstance().delegate = self
        AppUser.sharedInstance().performWaltzTransaction()
    }

//    public func beginTransaction(withJWT jwt: String? = nil) {
//        AppUser.sharedInstance().delegate = self
//        AppUser.sharedInstance().performWaltzTransaction(withJWT: jwt)
//    }
    
    // MARK: GEOFENCE
    public func startGeofenceService(enteredWaltzGeofence: ((String)->())? = nil) {
        if !AppUser.sharedInstance().checkIfTokenIsValid() {
            didFinishGeofenceSetupWithErrorCode(SHOULD_LOGIN)
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            if WaltzLocationHelper.sharedInstance().getCurrentGeofences() == nil {
                didFinishGeofenceSetupWithErrorCode(NO_INTERNET_CONNECTION)
                return
            }
            else {
                WaltzLocationHelper.sharedInstance().start()
            }
        }
        
        self.enteredWaltzGeofence = enteredWaltzGeofence

        RequestHelper.sharedInstance().fetchGeofences { (error) in
            if let _ = error {
                self.didFinishGeofenceSetupWithErrorCode(FAILURE)
            }
        }
    }
    
    public func stopGeofenceService() {
        LocationHelper.sharedInstance().stopLocationValidation()
    }
    
    // MARK: Guest feature
    public func getMyGuests() {
        if !AppUser.sharedInstance().checkIfTokenIsValid() {
            didGetMyGuestsWithErrorCode(SHOULD_LOGIN, guests: nil)
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            if WaltzLocationHelper.sharedInstance().getCurrentGeofences() == nil {
                didGetMyGuestsWithErrorCode(NO_INTERNET_CONNECTION, guests: nil)
                return
            }
        }
        
        RequestHelper.sharedInstance().getGuestsList() { (guests, error, _) in
            if let _ = error {
                self.didGetMyGuestsWithErrorCode(FAILURE, guests: nil)
                return
            }
            
            self.didGetMyGuestsWithErrorCode(SUCCESS, guests: guests)
        }
    }
    
    public func getMyInvitations() {
        if !AppUser.sharedInstance().checkIfTokenIsValid() {
            didGetMyInvitationsWithErrorCode(SHOULD_LOGIN, invitations: nil)
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            if WaltzLocationHelper.sharedInstance().getCurrentGeofences() == nil {
                didGetMyInvitationsWithErrorCode(NO_INTERNET_CONNECTION, invitations: nil)
                return
            }
        }
        
        RequestHelper.sharedInstance().getInvitationsList() { (invitations, error, _) in
            if let _ = error {
                self.didGetMyInvitationsWithErrorCode(FAILURE, invitations: nil)
                return
            }
            
            self.didGetMyInvitationsWithErrorCode(SUCCESS, invitations: invitations)
        }
    }
    
    public func sendInvitation(firstName: String, lastName: String, email: String, phoneNumber: String?, startDate: Date, endDate: Date) {
        if !AppUser.sharedInstance().checkIfTokenIsValid() {
            didSendInvitationWithErrorCode(SHOULD_LOGIN)
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            if WaltzLocationHelper.sharedInstance().getCurrentGeofences() == nil {
                didSendInvitationWithErrorCode(NO_INTERNET_CONNECTION)
                return
            }
        }
        
        if firstName.isEmpty {
            didSendInvitationWithErrorCode(INVALID_FIRST_NAME)
            return
        }
        if lastName.isEmpty {
            didSendInvitationWithErrorCode(INVALID_LAST_NAME)
            return
        }
        let regex = Regex(regex: EMAIL_REGEX)
        if !regex.testInput(email) {
            didSendInvitationWithErrorCode(INVALID_EMAIL_FORMAT)
            return
        }
        if AppUser.sharedInstance().userRolesCanInvite == nil || AppUser.sharedInstance().userRolesCanInvite?.count == 0 {
            didSendInvitationWithErrorCode(USER_CANNOT_INVITE)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT_TO_USE
        let fromDateTime = dateFormatter.string(from: startDate)
        let toDateTime = dateFormatter.string(from: endDate)
        let fromDate = DateHelper.getDateFrom(fromDateTime, for: DateHelper.DateTimeType.TypeDate)!
        let toDate = DateHelper.getDateFrom(toDateTime, for: DateHelper.DateTimeType.TypeDate)!
        let hours = Day(start: DateHelper.getDateFrom(fromDateTime, for: DateHelper.DateTimeType.TypeTime)!, stop: DateHelper.getDateFrom(toDateTime, for: DateHelper.DateTimeType.TypeTime)!)
        let validity = Day(start: fromDate, stop: toDate)
        let doorSchedule = DoorSchedule(hours: hours, days: DateHelper.getDaysOfWeek(fromDates: fromDate, toDate: toDate)!, validity: validity)
        let doorSchedules = [doorSchedule]
        
        let person = Person(firstName: firstName, lastName: lastName, email: email, phone: phoneNumber)
        let request = SendInvitationRequest(person: person, doorSchedules: doorSchedules)
        RequestHelper.sharedInstance().sendInvitation(invitation: SendInvitation(invitation: request), roleKey: AppUser.sharedInstance().userRolesCanInvite![0].key) { (error, _) in
            if let _ = error {
                self.didSendInvitationWithErrorCode(FAILURE)
                return
            }
            
            self.didSendInvitationWithErrorCode(SUCCESS)
        }
    }
}
