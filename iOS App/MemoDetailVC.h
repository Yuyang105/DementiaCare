//
//  MemoDetailVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 10/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewMemoVC.h"

@protocol MemoDetailViewControllerDelegate

- (void)editWasFinished;

@end


@interface MemoDetailVC : UIViewController

@property (nonatomic, strong) id<MemoDetailViewControllerDelegate> delegate;
@property (nonatomic) int memoID;

@property (nonatomic, weak) IBOutlet UILabel *txtLabel;
@property (nonatomic, weak) IBOutlet UITextView *txtDetail;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (IBAction)EditButton:(id)sender;


@end
