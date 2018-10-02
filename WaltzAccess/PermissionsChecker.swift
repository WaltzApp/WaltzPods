//
//  PermissionsChecker.swift
//  WaltzAccess
//
//  Created by Guillaume Vachon on 2018-09-11.
//  Copyright © 2018 Waltz. All rights reserved.
//

import AVFoundation

public class PermissionsChecker {
    
    public static let sharedInstance = PermissionsChecker()

    public var appCameraPermissions: CameraPersmissionsAuthStatus
    
    // MARK: INITIAL PERMISSIONS CHECK
    init() {
        appCameraPermissions = CameraPersmissionsDefault
        checkCameraPermissions()
    }
    
    // MARK: CHECK CAMERA PERMISSIONS
    func checkCameraPermissions() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            print("camera permissions - DENIED")
            appCameraPermissions = CameraPermissionsDenied
            return
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined || AVCaptureDevice.authorizationStatus(for: .video) == .restricted {
            print("camera permissions - RESTRICTED/NOT DETERMINED")
            appCameraPermissions = CameraPermissionsNotDeterminedOrRestricted
            return
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            print("camera permissions - AUTHORIZED")
            appCameraPermissions = CameraPermissionsGranted
        }
    }
    
    public func requestLocationPermission() {
        LocationHelper.sharedInstance().locationManager.requestAlwaysAuthorization()
    }
    
    public func requestPermissionForNotifications() {
        LocationHelper.sharedInstance().requestPermissionForNotifications()
    }
    
    public func cameraPermissionsHaveBeenGranted() {
        checkCameraPermissions()
    }
}
