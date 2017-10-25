//
//  LoginVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 05/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController <UITextFieldDelegate>

//@property (nonatomic, strong) NSMutableArray *jsonArray;
//@property (nonatomic, strong) NSMutableArray *usersArray;

@property (nonatomic, weak) IBOutlet UITextField *email;
@property (nonatomic, weak) IBOutlet UITextField *password;



#pragma mark - Class Methods

//- (void)retrieveData;

- (IBAction)loginButton:(id)sender;
- (IBAction)registerButton:(id)sender;
- (IBAction)forgottenButton:(id)sender;

@end
