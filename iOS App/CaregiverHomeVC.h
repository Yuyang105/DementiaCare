//
//  CaregiverHomeVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 20/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaregiverHomeVC : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *txtWelcome;
@property (weak, nonatomic) IBOutlet UITextField *txtRequest;

- (IBAction)infoButton:(id)sender;
- (IBAction)patientButton:(id)sender;
- (IBAction)sendRequest:(id)sender;


@end
