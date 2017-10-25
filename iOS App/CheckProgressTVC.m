//
//  CheckProgressTVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 23/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "CheckProgressTVC.h"
#import "SBJson.h"
#import "DateTools.h"

@interface CheckProgressTVC ()

// Private property
@property (nonatomic, strong) NSArray *arrProgress;
@property (nonatomic) int dailyID;

// Private method
-(void)loadData;

@end

@implementation CheckProgressTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make self the delegate and datasource of the table view.
    self.progressTable.delegate = self;
    self.progressTable.dataSource = self;
    
    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00];
    // Load the data.
    [self loadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (IBAction)refresh:(id)sender {
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrProgress.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idTrackDailyCell" forIndexPath:indexPath];
    
    NSString *name, *title, *description, *stime, *ctime, *state;
    NSInteger cycle = 0;
    
    SBJsonParser *jsonParser = [SBJsonParser new];
    
    // Get the top level value as a dictionary
    NSDictionary *jsonObject = [jsonParser objectWithString:_arrProgress[indexPath.row] error:NULL];
    // Get the success object as an array
    NSArray *list = [jsonObject objectForKey:@"response"];
    // Iterate the array; each element is a dictionary..
    for (NSDictionary *response in list) {
        name = [response objectForKey:@"name"];
        title = [response objectForKey:@"title"];
        description = [response objectForKey:@"description"];
        stime = [response objectForKey:@"stime"];
        cycle = [[response valueForKey:@"cycle"] integerValue];
        ctime = [response objectForKey:@"ctime"];
        state = [response objectForKey:@"state"];
    }
    //list = nil;
  
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSString *dateFormat = @"yyyy-MM-dd HH:mm";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
//    NSDate *timeDate = [self parseDate:stime format:@"yyyy-MM-dd HH:mm"];
//    NSDate * cTimeDate= [self parseDate:ctime format:@"yyyy-MM-dd HH:mm"];
    NSDate *timeDate = [dateFormatter dateFromString:stime];
    NSDate *cTimeDate = [dateFormatter dateFromString:ctime];
    NSLog(@"stime%@",stime);
    NSLog(@"ctime%@",ctime);
    NSLog(@"timeDate%@", timeDate);
    NSLog(@"cTimeDate%@", cTimeDate);

    [cell setTintColor:[UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00]];
    
    // Compute subtitle
    NSDate *ddl = [self compute:timeDate withDate:cTimeDate withCycle:cycle];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:ddl
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];

    cell.detailTextLabel.text = title;
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    if ([self compare:timeDate withDate:cTimeDate accordingToCycle:cycle]) {
        [[cell imageView] setImage:[UIImage imageNamed:@"checkbox-checked"]];
        
    }
    else {
        [[cell imageView] setImage:[UIImage imageNamed:@"checkbox-unchecked"]];
    }
    
    if ([state isEqualToString:@"YES"]) {
        
    }
    else {
        [[cell imageView] setImage:[UIImage imageNamed:@"checkbox"]];
        cell.detailTextLabel.text = @"OFF";
    }
    
    return cell;
}

- (NSDate*)parseDate:(NSString*)inStrDate format:(NSString*)inFormat {
    NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setLocale:[NSLocale systemLocale]];
    [dtFormatter setDateFormat:inFormat];
    NSDate* dateOutput = [dtFormatter dateFromString:inStrDate];
    return dateOutput;
}


// Load data
-(void)loadData {
    NSString *post = [[NSString alloc] initWithFormat:@"email=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"email"]];
    NSLog(@"PostData: %@", post);
    
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/trackProgress.php"];
    
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
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    
    //self.arrProgress = [[NSMutableArray alloc] init];
    
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        
        _arrProgress = [responseData componentsSeparatedByString:@"|"];
    }
    
    
    [self.progressTable reloadData];
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

// Detail
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.dailyID = (int)[indexPath row];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueCheckDaily" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CheckDailyVC *checkDailyVC = [segue destinationViewController];
    checkDailyVC.delegate = self;
    checkDailyVC.dailyID = _dailyID;
}


@end
