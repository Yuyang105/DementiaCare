//
//  MemoTVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 10/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemoDetailVC.h"
#import "NewMemoVC.h"

@interface MemoTVC : UITableViewController <MemoDetailViewControllerDelegate, NewMemoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblMemo;

@end

