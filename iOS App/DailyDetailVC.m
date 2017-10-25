//
//  DailyDetailVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 05/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "DailyDetailVC.h"
#import "DBManager.h"
#import "DateTools.h"

@interface DailyDetailVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrDaily;
// Private method
- (void)loadDaily;
- (void)editWasFinished;

@end

@implementation DailyDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
    [self loadDaily];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDaily {
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from daily where dailyID=%d", self.dailyIDToEdit];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    self.navigationItem.title = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"title"]];
    
    
    // Set the loaded data to the textfields.
    self.txtTitle.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"title"]];
    self.txtDescription.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"description"]];
    self.txtDate.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"time"]];
    NSInteger cycle = [[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"cycle"]] integerValue];
    self.scheduleControl.selectedSegmentIndex = cycle;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSString *dateFormat = @"yyyy-MM-dd HH:mm";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate * timeDate= [dateFormatter dateFromString:[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"time"]]];
    NSDate * cTimeDate= [dateFormatter dateFromString:[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"ctime"]]];
    if ([self compare:timeDate withDate:cTimeDate accordingToCycle:cycle]) {
        [[self completeSwich] setOn:YES animated:YES];
        [[self completeSwich] setEnabled:NO];
        NSString *ctimeString = [NSDateFormatter localizedStringFromDate:cTimeDate
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        [[self statusLabel] setText:@"Greate! You've already completed this mission on"];
        [[self statusTime] setText:[NSString stringWithFormat:@"%@.", ctimeString]];
    }
    else {
        NSDate *ddl = [self recent:timeDate withDate:cTimeDate withCycle:cycle];
        if ([ddl compare:[NSDate date]] == NSOrderedDescending) {
            [[self completeSwich] setOn:NO];
            [[self completeSwich] setEnabled:NO];
            [[self statusLabel] setText:@"It's too early to do it.."];
            [[self statusTime] setText:@""];
        }
        else {
            [[self completeSwich] setOn:NO];
            [[self completeSwich] setEnabled:YES];
            [[self completeSwich] addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            [[self statusLabel] setText:@"Have you done it?"];
            [[self statusTime] setText:@""];
        }
    }
    if ([[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"state"]] isEqualToString:@"NO"]) {
        [[self completeSwich] setOn:NO];
        [[self completeSwich] setEnabled:NO];
        [[self statusLabel] setText:@"This issue has been turned off."];
        [[self statusTime] setText:@""];
    }
    
   
}

- (void)changeSwitch:(UISwitch *)sender{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSString *dateFormat = @"yyyy-MM-dd HH:mm";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *current = [NSDate date];
    NSString *currentTimeString = [dateFormatter stringFromDate:current];
    
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"update daily set ctime = '%@' where dailyID = %d", currentTimeString, _dailyIDToEdit];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else{
        NSLog(@"Could not execute the query.");
    }
    
    [[self completeSwich] setEnabled:NO];
    NSString *ctimeString = [NSDateFormatter localizedStringFromDate:current
                                                           dateStyle:NSDateFormatterShortStyle
                                                           timeStyle:NSDateFormatterShortStyle];
    [[self statusLabel] setText:@"Greate! You've already completed this mission on"];
    [[self statusTime] setText:[NSString stringWithFormat:@"%@.", ctimeString]];
}


// Next alert
- (NSDate *)compute:(NSDate *)time withDate:(NSDate *) ctime withCycle:(NSInteger)cycle {
    NSDate *temp = time;
    NSDate *current = [NSDate date];
    if (cycle == 1) {
        // temp time is not later than current time
        while ([temp compare:current] != NSOrderedDescending) {
            // 测试阶段 使用分钟
            temp = [temp dateByAddingHours:1];
        }
    }
    else if (cycle == 2) {
        while ([temp compare:current] != NSOrderedDescending) {
            temp = [temp dateByAddingDays:1];
        }
    }
    else if (cycle == 3) {
        while ([temp compare:current] != NSOrderedDescending) {
            temp = [temp dateByAddingWeeks:1];
        }
    }
    else if (cycle == 4) {
        while ([temp compare:current] != NSOrderedDescending) {
            temp = [temp dateByAddingMonths:1];
        }
    }
    return temp;
}

// Recent alert
- (NSDate *)recent:(NSDate *)time withDate:(NSDate *) ctime withCycle:(NSInteger)cycle {
    NSDate *temp = time;
    NSDate *current = [NSDate date];
    if (cycle == 1) {
        // temp time is not later than current time
        while ([[temp dateByAddingHours:1] compare:current] != NSOrderedDescending) {
            // 测试阶段 使用分钟
            temp = [temp dateByAddingHours:1];
        }
    }
    else if (cycle == 2) {
        while ([[temp dateByAddingDays:1] compare:current] != NSOrderedDescending) {
            temp = [temp dateByAddingDays:1];
        }
    }
    else if (cycle == 3) {
        while ([[temp dateByAddingWeeks:1] compare:current] != NSOrderedDescending) {
            temp = [temp dateByAddingWeeks:1];
        }
    }
    else if (cycle == 4) {
        while ([[temp dateByAddingMonths:1] compare:current] != NSOrderedDescending) {
            temp = [temp dateByAddingMonths:1];
        }
    }
    return temp;
}


- (bool)compare:(NSDate *)time withDate:(NSDate *)ctime accordingToCycle:(NSInteger)cycle {
    NSDate *temp = [self recent:time withDate:ctime withCycle:cycle];
    
    // temp time is later than last complete time
    if ([temp compare:ctime] == NSOrderedDescending)
        // Undo
        return NO;
    else
        // Done
        return YES;
}

- (IBAction)EditButton:(id)sender {
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEditDaily" sender:self];
}

- (void)editWasFinished {
    [self loadDaily];
}




// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //idSegueEditDaily
    if ([segue.identifier isEqualToString:@"idSegueEditDaily"]) {
        NewDailyVC *newDailyVC = [segue destinationViewController];
        newDailyVC.delegate = self;
        newDailyVC.dailyIDToEdit = self.dailyIDToEdit;
    }

}


@end
