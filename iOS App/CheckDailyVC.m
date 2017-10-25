//
//  CheckDailyVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 24/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "CheckDailyVC.h"
#import "DateTools.h"
#import "SBJson.h"

@interface CheckDailyVC ()

// Private property
@property (nonatomic, strong) NSArray *arrProgress;

@end

@implementation CheckDailyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00]}];
    [self loadDaily];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDaily {
    
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

    
    NSString *name, *title, *description, *stime, *ctime, *state;
    NSInteger cycle = 0;
    
    SBJsonParser *jsonParser = [SBJsonParser new];
    
    // Get the top level value as a dictionary
    NSDictionary *jsonObject = [jsonParser objectWithString:_arrProgress[_dailyID] error:NULL];
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

    self.title = title;

    
    // Set the loaded data to the textfields.
    self.txtTitle.text = title;
    self.txtDescription.text = description;
    self.txtDate.text = stime;
    self.scheduleControl.selectedSegmentIndex = cycle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSString *dateFormat = @"yyyy-MM-dd HH:mm";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate * timeDate= [dateFormatter dateFromString:stime];
    NSDate * cTimeDate= [dateFormatter dateFromString:ctime];
    if ([self compare:timeDate withDate:cTimeDate accordingToCycle:cycle]) {
        [[self completeSwich] setOn:YES animated:YES];
        [[self completeSwich] setEnabled:NO];
        NSString *ctimeString = [NSDateFormatter localizedStringFromDate:cTimeDate
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterShortStyle];
        [[self statusLabel] setText:@"Greate! The mission is already completed on"];
        [[self statusTime] setText:[NSString stringWithFormat:@"%@.", ctimeString]];
    }
    else {
        [[self completeSwich] setOn:NO];
        [[self completeSwich] setEnabled:NO];
        [[self statusLabel] setText:@"This mission is not completed yet.."];
        [[self statusTime] setText:@""];
        
    }
    if ([state isEqualToString:@"NO"]) {
        [[self completeSwich] setOn:NO];
        [[self completeSwich] setEnabled:NO];
        [[self statusLabel] setText:@"This issue has been turned off."];
        [[self statusTime] setText:@""];
    }
    
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
