//
//  AppDelegate.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 25/03/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioServices.h>

@class NewDailyVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    NewDailyVC *newDailyVC;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

extern NSString *kRemindMeNotificationDataKey;

@end

