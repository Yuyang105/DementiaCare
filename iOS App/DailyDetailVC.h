//
//  DailyDetailVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 05/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewDailyVC.h"

@protocol DailyDetailViewControllerDelegate

- (void)editWasFinished;

@end

@interface DailyDetailVC : UIViewController

@property (nonatomic, strong) id<DailyDetailViewControllerDelegate> delegate;
@property (nonatomic) int dailyIDToEdit;

@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UILabel *txtDate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scheduleControl;
@property (weak, nonatomic) IBOutlet UISwitch *completeSwich;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTime;

- (IBAction)EditButton:(id)sender;

@end
