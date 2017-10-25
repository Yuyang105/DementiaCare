//
//  HomeVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 19/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeVC : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *txtWelcome;
@property (weak, nonatomic) IBOutlet UILabel *txtMemo;
@property (weak, nonatomic) IBOutlet UILabel *txtDaily;
@property (weak, nonatomic) IBOutlet UILabel *txtCaregiver;
@property (weak, nonatomic) IBOutlet UITextField *txtRequest;

- (IBAction)infoButton:(id)sender;
- (IBAction)memoButton:(id)sender;
- (IBAction)dailyButton:(id)sender;
- (IBAction)caregiverButton:(id)sender;
- (IBAction)sendRequest:(id)sender;

@end
