//
//  NewDailyVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 01/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyDetailVC.h"

@protocol NewDailyViewControllerDelegate

-(void)newDailyWasFinished;
-(void)editWasFinished;

@end


@interface NewDailyVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *txtTitle;
@property (nonatomic, weak) IBOutlet UITextView *txtDescription;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UISegmentedControl *scheduleControl;
@property (nonatomic, weak) IBOutlet UILabel *help;

@property (nonatomic, strong) id<NewDailyViewControllerDelegate> delegate;
@property (nonatomic) int dailyIDToEdit;
//@property (nonatomic, strong) NSString *kRemindMeNotificationDataKey;

- (IBAction)saveInfo:(id)sender;

- (void) showReminder:(NSString *) text;

@end
