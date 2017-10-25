//
//  DailyTVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 01/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewDailyVC.h"
#import "DailyDetailVC.h"

@interface DailyTVC : UITableViewController <NewDailyViewControllerDelegate, DailyDetailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblPeople;

- (IBAction)newDaily:(id)sender;

@end
