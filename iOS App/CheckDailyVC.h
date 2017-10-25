//
//  CheckDailyVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 24/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckDailyViewControllerDelegate
@end

@interface CheckDailyVC : UIViewController

@property (nonatomic) int dailyIDToEdit;

@property (nonatomic, strong) id<CheckDailyViewControllerDelegate> delegate;
@property (nonatomic) int dailyID;

@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UILabel *txtDate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scheduleControl;
@property (weak, nonatomic) IBOutlet UISwitch *completeSwich;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTime;


@end
