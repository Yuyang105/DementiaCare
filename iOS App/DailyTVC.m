//
//  DailyTVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 01/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "DailyTVC.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "DateTools.h"

@interface DailyTVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrPeopleInfo;
@property (nonatomic) int dailyIDToEdit;

-(void)loadData;

@end

@implementation DailyTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make self the delegate and datasource of the table view.
    self.tblPeople.delegate = self;
    self.tblPeople.dataSource = self;
    
    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
    
    // Load the data.
    [self loadData];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrPeopleInfo.count;
}

- (IBAction)newDaily:(id)sender {
    // Before performing the segue, set the -1 value to the recordIDToEdit. That way we'll indicate that we want to add a new record and not to edit an existing one.
    self.dailyIDToEdit = -1;
    [self performSegueWithIdentifier:@"idSegueNewDaily" sender:self];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idDailyIssue" forIndexPath:indexPath];
    
    NSInteger indexOfTitle = [self.dbManager.arrColumnNames indexOfObject:@"title"];
    NSInteger indexOfTime = [self.dbManager.arrColumnNames indexOfObject:@"time"];
    NSInteger indexOfCycle = [self.dbManager.arrColumnNames indexOfObject:@"cycle"];
    NSInteger indexOfCTime = [self.dbManager.arrColumnNames indexOfObject:@"ctime"];
    NSInteger indexOFState = [self.dbManager.arrColumnNames indexOfObject:@"state"];
    
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSString *dateFormat = @"yyyy-MM-dd HH:mm";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate * timeDate= [dateFormatter dateFromString:[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfTime]];
    NSDate * cTimeDate= [dateFormatter dateFromString:[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfCTime]];
    NSInteger cycle = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfCycle] integerValue];
    
    // Switch button
    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switcher;
    [switcher setOnTintColor:[UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00]];
    [switcher addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    switcher.tag = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] integerValue];
    
    // Compute subtitle
    NSDate *ddl = [self compute:timeDate withDate:cTimeDate withCycle:cycle];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:ddl
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    // temp time is later than last complete time
    if ([ddl compare:[NSDate date]] == NSOrderedDescending)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Next time is %@", dateString];
    else if ([self compare:timeDate withDate:cTimeDate accordingToCycle:cycle]) {
        
        cell.detailTextLabel.text = [[@"Greate! You completed it " stringByAppendingString:cTimeDate.shortTimeAgoSinceNow] stringByAppendingString:@" ago"];
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"It should be done at %@", dateString];
    }
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfTitle]];
    
    if ([self compare:timeDate withDate:cTimeDate accordingToCycle:cycle]) {
        [[cell imageView] setImage:[UIImage imageNamed:@"checkbox-checked"]];
    }
    else {
        [[cell imageView] setImage:[UIImage imageNamed:@"checkbox-unchecked"]];
        NSDate *ddl = [self recent:timeDate withDate:cTimeDate withCycle:cycle];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:ddl
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"It should be done at %@", dateString];
    }
    
    NSString *cState = [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOFState];
    if ([cState isEqualToString:@"YES"]) {
        [switcher setOn:YES];
    }
    else {
        [[cell imageView] setImage:[UIImage imageNamed:@"checkbox"]];
        cell.detailTextLabel.text = @"OFF";
        [switcher setOn:NO];
    }
    
    
    /*
     
     UPDATE in table view cell; INSERT when create new daily; DELETE when delete.
     
     Now: UPDATE
     
     */
    
    // Prepare data to upload :)
    NSString *description = [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"description"]];
    NSString *stime = [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfTime];
    int c = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfCycle] intValue];
    NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    NSString *ct = [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfCTime];
    int daily_ID = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"dailyID"]] intValue];
    
    // Post to MySQL database, in order to enable caregiver's tracking
    NSString *post = [[NSString alloc] initWithFormat:@"title=%@&description=%@&stime=%@&cycle=%d&user=%@&ctime=%@&state=%@&ID=%d&job=%@",[[cell textLabel] text], description, stime, c, user, ct, cState, daily_ID, @"update"];
    NSLog(@"PostData: %@", post);
    
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/daily_update.php"];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSHTTPURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Feedback
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
    }
    else {
        if (error) {
            NSLog(@"Error:%@", error);
        }
    }

    
    
    return cell;
}


// ON/OFF switch
- (void)changeSwitch:(UISwitch *)sender{
    int dailyID = (int)[sender tag];
    NSLog(@"%d",dailyID);
    
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from daily where dailyID=%d", dailyID];
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSString *state = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"state"]];
    NSString *notifID = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"notifID"]];
    NSLog(@"state!!!!%@",state);
    if ([state isEqualToString:@"YES"]) {

        UILocalNotification *notifToCancel = nil;
        for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            NSLog(@"%@", [aNotif.userInfo objectForKey:@"notifID"]);
            if ([[aNotif.userInfo objectForKey:@"notifID"] isEqualToString:notifID]) {
                NSLog(@"%@", [aNotif.userInfo objectForKey:@"notifID"]);
                notifToCancel = aNotif;
                if (notifToCancel) {
                    [[UIApplication sharedApplication] cancelLocalNotification:notifToCancel];
                    NSLog(@"Deleted!!!");
                }
            }
        }
        
        
        
        query = [NSString stringWithFormat:@"update daily set state = '%@' where dailyID = %d", @"NO", dailyID];
        // Execute the query.
        [self.dbManager executeQuery:query];
    
        // If the query was successfully executed then pop the view controller.
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else{
            NSLog(@"Could not execute the query.");
        }
    }
    else {
        // Get all the info
        NSInteger cycle = [[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"cycle"]] integerValue];
        NSString *title = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"title"]];
        NSString *time = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"time"]];
//        NSString *ctime = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"ctime"]];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
        //[dateFormatter setDateFormat:@"YYYY-MM-DD HH:MM"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate * timeDate= [dateFormatter dateFromString:time];
//        NSDate * cTimeDate= [dateFormatter dateFromString:ctime];
        
        
        Class cls = NSClassFromString(@"UILocalNotification");
        if (cls != nil) {
            UILocalNotification *notif = [[cls alloc] init];
            notif.fireDate = timeDate;
            notif.timeZone = [NSTimeZone defaultTimeZone];
            
            NSString *alertBody = @"Did you forget something is called \"";
            alertBody = [[alertBody stringByAppendingString:title] stringByAppendingString:@"\""];
            
            notif.alertBody = alertBody;
            notif.alertAction = @"Show me";
            notif.soundName = UILocalNotificationDefaultSoundName;
            notif.applicationIconBadgeNumber = 1;
            
            [notif setUserInfo:[NSDictionary dictionaryWithObject:notifID forKey:@"notifID"]];
            NSLog(@"TURN ON, SET ID%@", notifID);
            NSInteger index = cycle;
            switch (index) {
                case 1:
                    // 测试阶段 用分钟计时
                    notif.repeatInterval = NSCalendarUnitHour;
                    cycle = 1;
                    break;
                case 2:
                    notif.repeatInterval = NSCalendarUnitDay;
                    cycle = 2;
                    break;
                case 3:
                    notif.repeatInterval = NSCalendarUnitWeekOfYear;
                    cycle = 3;
                    break;
                case 4:
                    notif.repeatInterval = NSCalendarUnitMonth;
                    cycle = 4;
                    break;
                default:
                    notif.repeatInterval = 0;
                    cycle = 0;
                    break;
            }
            
//            NSDictionary *userDict = [NSDictionary dictionaryWithObject:title
//                                                                 forKey:kRemindMeNotificationDataKey];
//            notif.userInfo = userDict;
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        }
        query = [NSString stringWithFormat:@"update daily set state = '%@' where dailyID = %d", @"YES", dailyID];
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // If the query was successfully executed then pop the view controller.
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        }
        else{
            NSLog(@"Could not execute the query.");
        }

    }
    
    [self loadData];
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


// Load data
-(void)loadData {
    // Form the query.
    NSString *query = @"select * from daily";
    
    // Get the results.
    if (self.arrPeopleInfo != nil) {
        self.arrPeopleInfo = nil;
    }
    self.arrPeopleInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    [self.tblPeople reloadData];
}

// New Daily is added
-(void)newDailyWasFinished{
    // Reload the data.
    [self loadData];
}


// Delete
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int dailyIDToDelete;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        dailyIDToDelete = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Create the query.
        NSString *query = [NSString stringWithFormat:@"select * from daily where dailyID=%d", dailyIDToDelete];
        // Load the relevant data.
        NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
        NSString *notifID = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"notifID"]];
            
        UILocalNotification *notifToCancel = nil;
        for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            NSLog(@"%@", [aNotif.userInfo objectForKey:@"notifID"]);
            if ([[aNotif.userInfo objectForKey:@"notifID"] isEqualToString:notifID]) {
                NSLog(@"%@", [aNotif.userInfo objectForKey:@"notifID"]);
                notifToCancel = aNotif;
                if (notifToCancel) {
                    [[UIApplication sharedApplication] cancelLocalNotification:notifToCancel];
                    NSLog(@"Deleted!!!");
                }
            }
        }
        
        // Prepare the query.
         query = [NSString stringWithFormat:@"delete from daily where dailyID=%d", dailyIDToDelete];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // Reload the table view.
        [self loadData];
        
    }
    
    // Post to MySQL database, in order to enable caregiver's tracking
    NSString *post = [[NSString alloc] initWithFormat:@"user=%@&ID=%d&job=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"email"], dailyIDToDelete, @"delete"];
    NSLog(@"PostData: %@", post);
    
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/daily_update.php"];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSHTTPURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Feedback
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
    }
    else {
        if (error) {
            NSLog(@"Error:%@", error);
        }
    }

}

// Detail
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.dailyIDToEdit = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    NSLog(@"a%d", self.dailyIDToEdit);
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueDailyDetail" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"idSegueDailyDetail"]) {
        NSLog(@"b%d", self.dailyIDToEdit);
        DailyDetailVC *dailyDetailVC = [segue destinationViewController];
        dailyDetailVC.delegate = self;
        dailyDetailVC.dailyIDToEdit = self.dailyIDToEdit;
    }
    else {
        NewDailyVC *newDailyVC = [segue destinationViewController];
        newDailyVC.delegate = self;
        newDailyVC.dailyIDToEdit = -1;
    }
}

@end
