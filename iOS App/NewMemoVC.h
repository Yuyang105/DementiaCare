//
//  NewMemoVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 09/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemoDetailVC.h"

@protocol NewMemoViewControllerDelegate

- (void)newMemoWasFinished;
- (void)editWasFinished;

@end

@interface NewMemoVC : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtDetail;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) id<NewMemoViewControllerDelegate> delegate;
@property (nonatomic) int memoID;


- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;
- (IBAction)saveMemo:(id)sender;


@end
