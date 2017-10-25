//
//  CheckProgressTVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 23/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckDailyVC.h"

@interface CheckProgressTVC : UITableViewController <CheckDailyViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *progressTable;

- (IBAction)refresh:(id)sender;
@end
