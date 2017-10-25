//
//  AlarmVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 14/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmVC : UIViewController <UITextViewDelegate, UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *txtCancelMessage;
@property(nonatomic, retain) IBOutlet UIView *masterView;

- (IBAction)emergencyButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

@end
