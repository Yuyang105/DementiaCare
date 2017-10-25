//
//  AppDelegate.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 25/03/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "AppDelegate.h"
#import "NewDailyVC.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate

// Lazy instantiation design pattern
// Create getter method locationManager to obtain the current location manager object
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        // Allocation and initialisation
        _locationManager = [[CLLocationManager alloc] init];
        // Set accuracy of the nearest 10 meters
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        // Set distance filter to 10 meters
        [_locationManager setDistanceFilter:10];
        // Set delegate
        [_locationManager setDelegate:self];
        [self.locationManager requestAlwaysAuthorization];
    }
    return _locationManager;
}

NSString *kRemindMeNotificationDataKey = @"kRemindMeNotificationDataKey";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }
    
    
    Class cls = NSClassFromString(@"UILocalNotification");
    if (cls) {
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        
        if (notification) {

            NSString *reminderText = [notification.userInfo objectForKey:kRemindMeNotificationDataKey];
            [newDailyVC showReminder:reminderText];
        }
    }
    
    application.applicationIconBadgeNumber = 0;
    
    [window addSubview:newDailyVC.view];
    [window makeKeyAndVisible];
    
    
    // Update location
    // =================================================
    // Update to database, 可以的话就移到appdelegate
    [[self locationManager] startUpdatingLocation];
    
    // Use string to store location
    NSString *latitude = [NSString stringWithFormat:@"%+.6f", [[_locationManager location] coordinate].latitude];
    NSString *longtitude = [NSString stringWithFormat:@"%+.6f", [[_locationManager location] coordinate].longitude];
    NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    
    // Post to MySQL database, in order to enable caregiver's tracking
    NSString *post = [[NSString alloc] initWithFormat:@"user=%@&latitude=%@&longtitude=%@", user, latitude, longtitude];
    NSLog(@"PostData: %@", post);
    
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/location.php"];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSHTTPURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Feedback
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
    }
    else {
        if (error) {
            NSLog(@"Error:%@", error);
        }
    }
    
    [[self locationManager] startUpdatingLocation];
    // =================================================
    
    
    
    return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application

{
    // Add registration for remote notifications
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // Clear application badge when app launches
    application.applicationIconBadgeNumber = 0;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self saveContext];
}


- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
    // UIApplicationState state = [application applicationState];
    // if (state == UIApplicationStateInactive) {
    
    // Application was in the background when notification
    // was delivered.
    // }
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Daily Issue"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        
        [alert show];
    }

}


/*
 
 * --------------------------------------------------------------------------------------------------------------
 
 *  BEGIN APNS CODE
 
 * --------------------------------------------------------------------------------------------------------------
 
 */


/*
 
 * Fetch and Format Device Token and Register Important Information to Remote Server
 
 */

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
#if !TARGET_IPHONE_SIMULATOR
    
    
    // Get Bundle Info for Remote Registration (handy if you have more than one app)
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
    NSUInteger rntypes = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    // Set the defaults to disabled unless we find otherwise...
    NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
    NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
    NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceName = dev.name;
    NSString *deviceModel = dev.model;
    NSString *deviceSystemVersion = dev.systemVersion;
    
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"deviceToken: %@",deviceToken);
    
    // upload
    NSString *post = [[NSString alloc] initWithFormat:@"user=%@&token=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"email"], deviceToken];
    NSLog(@"PostData: %@", post);
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/fetch.php"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSError *error;
    NSHTTPURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
    }

    
   
    
    // Build URL String for Registration
    // !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
    // !!! SAMPLE: "secure.awesomeapp.com"
    NSString *host = @"www.cloudcampus.xyz/DementiaCare";
    
    
    // !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
    // !!! ( MUST START WITH / AND END WITH ? ).
    // !!! SAMPLE: "/path/to/apns.php?"
//    NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&appname=%@&appversion=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
//    
//    
//    // Register the Device Data
//    // !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
//    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *urlR, NSData *returnData, NSError *e) {
//                               NSLog(@"Return Data: %@", returnData);
//                           }];
//    
//    NSLog(@"Register URL: %@", url);
//    
    
#endif
    
    
}



/**
 
 * Failed to Register for Remote Notifications
 
 */

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
#if !TARGET_IPHONE_SIMULATOR
    
    
    NSLog(@"Error in registration. Error: %@", error);
    
    
#endif
    
}



/**
 
 * Remote Notification Received while application was open.
 
 */

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateActive)
    {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]] message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    
    
    NSLog(@"remote notification: %@",[userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    
    NSString *alert = [apsInfo objectForKey:@"alert"];
    NSLog(@"Received Push Alert: %@", alert);
    
    
    NSString *sound = [apsInfo objectForKey:@"sound"];
    NSLog(@"Received Push Sound: %@", sound);
    
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    
    NSString *badge = [apsInfo objectForKey:@"badge"];
    NSLog(@"Received Push Badge: %@", badge);
    
    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];

    
#endif
    
}



/*
 
 * --------------------------------------------------------------------------------------------------------------
 
 *  END APNS CODE
 
 * --------------------------------------------------------------------------------------------------------------
 
 */



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "yuyang.DementiaCare" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DementiaCare" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DementiaCare.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
