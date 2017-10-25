//
//  RegisterVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 07/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *txtName;
@property (nonatomic, weak) IBOutlet UITextField *txtEmail;
@property (nonatomic, weak) IBOutlet UITextField *txtPassword;
@property (nonatomic, weak) IBOutlet UITextField *txtConfirmation;
@property (nonatomic, weak) IBOutlet UITextField *txtGender;
@property (nonatomic, weak) IBOutlet UITextField *txtAge;
@property (nonatomic, weak) IBOutlet UITextField *txtType;

- (IBAction)saveButton:(id)sender;




@end
