/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AddressBook/AddressBook.h>

#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK
#import <Contacts/Contacts.h>

@interface Diagnostic()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
@property (nonatomic, retain) CNContactStore* contactStore;
#endif

@end


@implementation Diagnostic

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
ABAddressBookRef _addressBook;
#endif
- (void)pluginInitialize {
    
    [super pluginInitialize];
    
    self.locationRequestCallbackId = nil;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.bluetoothManager = [[CBCentralManager alloc]
                             initWithDelegate:self
                             queue:dispatch_get_main_queue()
                             options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

/*************
 * Plugin API
 *************/

// Location
- (void) isLocationAvailable: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([CLLocationManager locationServicesEnabled] && [self isLocationAuthorized]) {
            NSLog(@"Location is available.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            NSLog(@"Location is not available.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([CLLocationManager locationServicesEnabled]) {
            NSLog(@"Location setting is enabled");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            NSLog(@"Location setting is disabled");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isLocationAuthorized]) {
            NSLog(@"This app is authorized to use location.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        } else {
            NSLog(@"This app is not authorized to use location.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status = [self getLocationAuthorizationStatusAsString:[CLLocationManager authorizationStatus]];
        NSLog(@"%@",[NSString stringWithFormat:@"Location authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)])
        {
            BOOL always = [[command argumentAtIndex:0] boolValue];
            if(always){
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationAlwaysUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationAlwaysUsageDescription in its Info.plist");
                [self.locationManager requestAlwaysAuthorization];
                NSLog(@"Requesting location authorization: always");
            }else{
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationWhenInUseUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationWhenInUseUsageDescription in its Info.plist");
                [self.locationManager requestWhenInUseAuthorization];
                NSLog(@"Requesting location authorization: when in use");
            }
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    self.locationRequestCallbackId = command.callbackId;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Camera
- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isCameraPresent] && [self isCameraAuthorized]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isCameraPresent: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isCameraPresent]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isCameraAuthorized]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == AVAuthorizationStatusAuthorized){
            status = @"authorized";
        }
        NSLog(@"%@",[NSString stringWithFormat:@"Camera authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            CDVPluginResult* pluginResult;
            if(granted){
                NSLog(@"Granted access to camera");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            } else {
                NSLog(@"Not granted access to camera");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    @catch (NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([[self getCameraRollAuthorizationStatus]  isEqual: @"authorized"]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status = [self getCameraRollAuthorizationStatus];
        
        NSLog(@"%@",[NSString stringWithFormat:@"Camera Roll authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) requestCameraRollAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authStatus) {
            NSString* status = [self getCameraRollAuthorizationStatusAsString:authStatus];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    @catch (NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// Wifi
- (void) isWifiAvailable: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self connectedToWifi]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Bluetooth
- (void) isBluetoothAvailable: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if(self.bluetoothEnabled) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getBluetoothState: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* state = self.bluetoothState;
        NSLog(@"%@",[NSString stringWithFormat:@"Bluetooth state is: %@", state]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

// Settings
- (void) switchToSettings: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if (UIApplicationOpenSettingsURLString != nil ){
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not supported below iOS 8"];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Audio
- (void) isMicrophoneAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
#ifdef __IPHONE_8_0
        AVAudioSessionRecordPermission recordPermission = [AVAudioSession sharedInstance].recordPermission;
        
        if(recordPermission == AVAudioSessionRecordPermissionGranted) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
#else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Only supported on iOS 8 and higher"];
#endif
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getMicrophoneAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
#ifdef __IPHONE_8_0
        NSString* status;
        AVAudioSessionRecordPermission recordPermission = [AVAudioSession sharedInstance].recordPermission;
        switch(recordPermission){
            case AVAudioSessionRecordPermissionDenied:
                status = @"denied";
                break;
            case AVAudioSessionRecordPermissionGranted:
                status = @"granted";
                break;
            case AVAudioSessionRecordPermissionUndetermined:
                status = @"not_determined";
                break;
        }
        
        NSLog(@"%@",[NSString stringWithFormat:@"Microphone authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
#else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Only supported on iOS 8 and higher"];
#endif
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) requestMicrophoneAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            NSLog(@"HAs access to microphone: %d", granted);
            CDVPluginResult* pluginResult;
            if(granted) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    @catch (NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// Remote (Push) Notifications
- (void) isRemoteNotificationsEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    BOOL isEnabled;
    @try {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // iOS8+
            BOOL remoteNotificationsEnabled = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
            UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
            isEnabled = remoteNotificationsEnabled && userNotificationSettings.types != UIUserNotificationTypeNone;
        } else {
            // iOS7 and below
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
            UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
            isEnabled = enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
#endif
        }
        
        if(isEnabled) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getRemoteNotificationTypes: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    BOOL noneEnabled,alertsEnabled, badgesEnabled, soundsEnabled;
    @try {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // iOS8+
            UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
            noneEnabled = userNotificationSettings.types == UIUserNotificationTypeNone;
            alertsEnabled = userNotificationSettings.types & UIUserNotificationTypeAlert;
            badgesEnabled = userNotificationSettings.types & UIUserNotificationTypeBadge;
            soundsEnabled = userNotificationSettings.types & UIUserNotificationTypeSound;
        } else {
            // iOS7 and below
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
            UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
            noneEnabled = enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone;
            alertsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeAlert;
            badgesEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeBadge;
            soundsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeSound;
#endif
        }
        
        NSMutableDictionary* types = [[NSMutableDictionary alloc]init];
        if(alertsEnabled) {
            [types setValue:@"1" forKey:@"alert"];
        } else {
            [types setValue:@"0" forKey:@"alert"];
        }
        if(badgesEnabled) {
            [types setValue:@"1" forKey:@"badge"];
        } else {
            [types setValue:@"0" forKey:@"badge"];
        }
        if(soundsEnabled) {
            [types setValue:@"1" forKey:@"sound"];
        } else {;
            [types setValue:@"0" forKey:@"sound"];
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self objectToJsonString:types]];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isRegisteredForRemoteNotifications: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    BOOL registered;
    @try {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // iOS8+
            registered = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
            // iOS7 and below
            UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
            registered = enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
#endif
        }
        if(registered) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Address Book (Contacts)

- (void) getAddressBookAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if(authStatus == CNAuthorizationStatusDenied || authStatus == CNAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == CNAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == CNAuthorizationStatusAuthorized){
            status = @"authorized";
        }
#else
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        if(authStatus == kABAuthorizationStatusDenied || authStatus == kABAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == kABAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == kABAuthorizationStatusAuthorized){
            status = @"authorized";
        }
        
#endif
        
        NSLog(@"%@",[NSString stringWithFormat:@"Address book authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isAddressBookAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if(authStatus == CNAuthorizationStatusAuthorized) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
#else
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        if(authStatus == kABAuthorizationStatusAuthorized) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
#endif
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) requestAddressBookAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            NSLog(@"Access request to address book: %d", granted);
            CDVPluginResult* pluginResult;
            if(granted) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            
        });
        
#else
        [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            CDVPluginResult* pluginResult;
            if(error == nil) {
                NSLog(@"Access request to address book: %d", granted);
                if(granted) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
                }
            }
            else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
#endif
    }
    @catch (NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// Calendar Events

- (void) getCalendarAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status;
        
        EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        
        if(authStatus == EKAuthorizationStatusDenied || authStatus == EKAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == EKAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == EKAuthorizationStatusAuthorized){
            status = @"authorized";
        }
        NSLog(@"%@",[NSString stringWithFormat:@"Calendar event authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isCalendarAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        if(authStatus == EKAuthorizationStatusAuthorized) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) requestCalendarAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        
        if (!self.eventStore) {
            self.eventStore = [EKEventStore new];
        }
        
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            NSLog(@"Access request to calendar events: %d", granted);
            CDVPluginResult* pluginResult;
            if(granted) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    @catch (NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// Reminder Events

- (void) getRemindersAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status;
        
        EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
        
        if(authStatus == EKAuthorizationStatusDenied || authStatus == EKAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == EKAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == EKAuthorizationStatusAuthorized){
            status = @"authorized";
        }
        NSLog(@"%@",[NSString stringWithFormat:@"Reminders authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isRemindersAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
        if(authStatus == EKAuthorizationStatusAuthorized) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) requestRemindersAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        
        if (!self.eventStore) {
            self.eventStore = [EKEventStore new];
        }
        
        [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            NSLog(@"Access request to reminders: %d", granted);
            CDVPluginResult* pluginResult;
            if(granted) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    @catch (NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// Background refresh
- (void) getBackgroundRefreshStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status;
        
        if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
            status = @"authorized";
            NSLog(@"Background updates are available for the app.");
        }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
            status = @"denied";
            NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
        }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
            status = @"restricted";
            NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

/*********************
 * Internal functions
 *********************/
- (void)jsCallback: (NSString*)jsString
{
    [self.commandDelegate evalJs:jsString];
}

- (NSString*) getLocationAuthorizationStatusAsString: (CLAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == kCLAuthorizationStatusNotDetermined){
        status = @"not_determined";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedAlways){
        status = @"authorized";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        status = @"authorized_when_in_use";
    }
    return status;
}

- (BOOL) isLocationAuthorized
{
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    if([status  isEqual: @"authorized"] || [status  isEqual: @"authorized_when_in_use"]) {
        return true;
    } else {
        return false;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)authStatus {
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    NSLog(@"%@",[NSString stringWithFormat:@"Location authorization status changed to: %@", status]);
    
    if(self.locationRequestCallbackId != nil){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.locationRequestCallbackId];
        self.locationRequestCallbackId = nil;
    }
    
    [self jsCallback:[NSString stringWithFormat:@"cordova.plugins.diagnostic._onLocationStateChange(\"%@\");", status]];
}

- (BOOL) isCameraPresent
{
    BOOL cameraAvailable =
    [UIImagePickerController
     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(cameraAvailable) {
        NSLog(@"Camera available");
        return true;
    }
    else {
        NSLog(@"Camera unavailable");
        return false;
    }
}

- (BOOL) isCameraAuthorized
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        return true;
    } else {
        return false;
    }
}

- (NSString*) getCameraRollAuthorizationStatus
{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    return [self getCameraRollAuthorizationStatusAsString:authStatus];
    
}

- (NSString*) getCameraRollAuthorizationStatusAsString: (PHAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == PHAuthorizationStatusNotDetermined ){
        status = @"not_determined";
    }else if(authStatus == PHAuthorizationStatusAuthorized){
        status = @"authorized";
    }
    return status;
}

- (BOOL) connectedToWifi  // Don't work on iOS Simulator, only in the device
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    
    if (getifaddrs(&addresses) != 0) {
        return NO;
    }
    
    cursor = addresses;
    while (cursor != NULL)  {
        if (cursor -> ifa_addr -> sa_family == AF_INET && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                
                NSLog(@"Wifi ON");
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    freeifaddrs(addresses);
    return wiFiAvailable;
}

- (NSString*) arrayToJsonString:(NSArray*)inputArray
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString*) objectToJsonString:(NSDictionary*)inputObject
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (ABAddressBookRef)addressBook {
    if (!_addressBook) {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (addressBook) {
            [self setAddressBook:CFAutorelease(addressBook)];
        }
    }
    
    return _addressBook;
}

- (void)setAddressBook:(ABAddressBookRef)newAddressBook {
    if (_addressBook != newAddressBook) {
        if (_addressBook) {
            CFRelease(_addressBook);
        }
        
        if (newAddressBook) {
            CFRetain(newAddressBook);
        }
        
        _addressBook = newAddressBook;
    }
}

- (void)dealloc {
    if (_addressBook) {
        CFRelease(_addressBook);
        _addressBook = NULL;
    }
}
#endif

#pragma mark - CBCentralManagerDelegate

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString* state;
    NSString* description;
    
    switch(self.bluetoothManager.state)
    {
        case CBCentralManagerStateResetting:
            state = @"resetting";
            description =@"The connection with the system service was momentarily lost, update imminent.";
            break;
            
        case CBCentralManagerStateUnsupported:
            state = @"unsupported";
            description = @"The platform doesn't support Bluetooth Low Energy.";
            break;
            
        case CBCentralManagerStateUnauthorized:
            state = @"unauthorized";
            description = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"powered_off";
            description = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"powered_on";
            description = @"Bluetooth is currently powered on and available to use.";
            break;
        default:
            state = @"unknown";
            description = @"State unknown, update imminent.";
            break;
    }
    NSLog(@"Bluetooth state changed: %@",description);
    
    self.bluetoothState = state;
    if([state  isEqual: @"powered_on"]){
        self.bluetoothEnabled = true;
    }else{
        self.bluetoothEnabled = false;
    }
    
    NSString* jsString = [NSString stringWithFormat:@"cordova.plugins.diagnostic._onBluetoothStateChange(\"%@\");", state];
    [self jsCallback:jsString];
}

@end
