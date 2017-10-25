//
//  NewDailyVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 01/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "NewDailyVC.h"
#import "DBManager.h"
#import "AppDelegate.h"

@interface NewDailyVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;

// Private method
-(void)loadIssueToEdit;

@end

@implementation NewDailyVC

@synthesize txtTitle, txtDescription, scheduleControl, datePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make self the delegate of the textfields.
    self.txtTitle.delegate = self;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
    
    // Check if should load specific record for editing.
    if (self.dailyIDToEdit != -1) {
        // Load the record with the specific ID from the database.
        [self loadIssueToEdit];
    }
    
    [datePicker setLocale:[NSLocale systemLocale]];
    
    // Minimum date
    //datePicker.minimumDate = [NSDate date];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Resign the textfield from first responder
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


// Show Reminder
- (void)showReminder:(NSString *)text {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reminder"
//                                                        message:text delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//    [alertView show];
//    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Reminder" message:@"i am a message" preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Actions
        NSLog(@"Pressed OK...");
    }]];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertView animated:true completion:nil];
}

// Save
- (IBAction)saveInfo:(id)sender {
    // Set local notification..
    [txtTitle resignFirstResponder];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    int cycle = 0;
    Class cls = NSClassFromString(@"UILocalNotification");
    NSString *notifID = [[NSProcessInfo processInfo] globallyUniqueString];
    if (cls != nil) {
        UILocalNotification *notif = [[cls alloc] init];
        notif.fireDate = [datePicker date];
        notif.timeZone = [NSTimeZone systemTimeZone];
        
        NSString *alertBody = @"Did you forget something is called \"";
        alertBody = [[alertBody stringByAppendingString:[[self txtTitle] text]] stringByAppendingString:@"\""];
        
        notif.alertBody = alertBody;
        notif.alertAction = @"Show me";
        notif.soundName = UILocalNotificationDefaultSoundName;
        notif.applicationIconBadgeNumber = 1;
        
        [notif setUserInfo:[NSDictionary dictionaryWithObject:notifID forKey:@"notifID"]];
        NSLog(@"Set notifID%@", notifID);
        
        NSInteger index = [scheduleControl selectedSegmentIndex];
        switch (index) {
            case 1:
                // 测试阶段 用分钟计时
                //notif.repeatInterval = NSCalendarUnitMinute;
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
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
    
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSString *dateFormat = @"yyyy-MM-dd HH:mm";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *dateString, *currentTimeString;
    dateString = [dateFormatter stringFromDate:[datePicker date]];
    currentTimeString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"Date test: setTime -> %@; currentTime -> %@", dateString, currentTimeString);
    
    // Create SQLite daily table.
    NSString *query;
    query = @" CREATE TABLE daily(dailyID integer primary key, title text, description text, time text, cycle integer, user text, ctime text, notifID text, state text);";
    [self.dbManager executeQuery:query];
    
    // New Daily
    if (self.dailyIDToEdit == -1) {
        query = [NSString stringWithFormat:@"insert into daily values(null, '%@', '%@', '%@', %d, '%@', '%@', '%@', '%@')", self.txtTitle.text, self.txtDescription.text, dateString, cycle, [[NSUserDefaults standardUserDefaults] stringForKey:@"email"], currentTimeString, notifID, @"YES"];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // If the query was successfully executed then pop the view controller.
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rowID = %lld", self.dbManager.lastInsertedRowID);
            
            // Inform the delegate that the editing was finished.
            [self.delegate newDailyWasFinished];
            
            // Pop the view controller.
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSLog(@"Could not execute the query.");
        }
        
        int rowID = self.dbManager.lastInsertedRowID;
        NSLog(@"ROW ID: %d", rowID);
        
        // Post to MySQL database, in order to enable caregiver's tracking
        NSString *post = [[NSString alloc] initWithFormat:@"title=%@&description=%@&stime=%@&cycle=%d&user=%@&ctime=%@&state=%@&ID=%d&job=%@",self.txtTitle.text, self.txtDescription.text, dateString, cycle, [[NSUserDefaults standardUserDefaults] stringForKey:@"email"], currentTimeString, @"YES", rowID, @"create"];
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
    // Edit case
    else {
        // Delete old notification
        query = [NSString stringWithFormat:@"select * from daily where dailyID=%d", self.dailyIDToEdit];
        NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
        NSString *oldNotif = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"notifID"]];
        UILocalNotification *notifToCancel = nil;
        for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            NSLog(@"%@", [aNotif.userInfo objectForKey:@"notifID"]);
            if ([[aNotif.userInfo objectForKey:@"notifID"] isEqualToString:oldNotif]) {
                NSLog(@"%@", [aNotif.userInfo objectForKey:@"notifID"]);
                notifToCancel = aNotif;
                if (notifToCancel) {
                    [[UIApplication sharedApplication] cancelLocalNotification:notifToCancel];
                    NSLog(@"Deleted!!!");
                }
            }
        }
        // Update
        query = [NSString stringWithFormat:@"update daily set title='%@', description='%@', time='%@', cycle='%d', ctime='%@', notifID='%@', state='%@' where dailyID=%d", self.txtTitle.text, self.txtDescription.text, dateString, cycle, currentTimeString, notifID, @"YES", self.dailyIDToEdit];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // If the query was successfully executed then pop the view controller.
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            
            // Inform the delegate that the editing was finished.
            [self.delegate editWasFinished];
            
            // Pop the view controller.
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSLog(@"Could not execute the query.");
        }
    }
}

// Edit existed daily issue
-(void)loadIssueToEdit{
    // Set title
    self.navigationItem.title = @"Edit Daily Issue";
    
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from daily where dailyID=%d", self.dailyIDToEdit];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set the loaded data to the textfields.
    self.txtTitle.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"title"]];
    self.txtDescription.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"description"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSString *dateFormat = @"yyyy-MM-dd HH:mm";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSDate *timeDate= [dateFormatter dateFromString:[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"time"]]];
    self.datePicker.date = timeDate;
    
    self.scheduleControl.selectedSegmentIndex = [[[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"cycle"]] integerValue];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Remove the keyboard..
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
}

@end
