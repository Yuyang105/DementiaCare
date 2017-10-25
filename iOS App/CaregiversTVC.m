//
//  CaregiversTVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 23/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "CaregiversTVC.h"

@interface CaregiversTVC ()

@property (nonatomic, strong) NSArray *arrPair;

@end

@implementation CaregiversTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make self the delegate and datasource of the table view.
    self.pairTable.delegate = self;
    self.pairTable.dataSource = self;
    
    // Change navigation title color
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00]}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self arrPair] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pairCell" forIndexPath:indexPath];
    
    // Get name
    NSString *post = [[NSString alloc] initWithFormat:@"email=%@",_arrPair[indexPath.row]];
    NSLog(@"PostData: %@", post);
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/getName.php"];
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
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        cell.textLabel.text = responseData;
    }
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@", _arrPair[indexPath.row]];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *post = [[NSString alloc] initWithFormat:@"user=%@&email=%@&unpair=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"email"], _arrPair[indexPath.row], @"unpair"];
        NSLog(@"PostData: %@", post);
        NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/fetch.php"];
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
        if ([response statusCode] >= 200 && [response statusCode] < 300) {
            NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"Response ==> %@", responseData);
        }
        
        
        [self loadData];
    }
    
}


// Load data
-(void)loadData {
    NSString *post = [[NSString alloc] initWithFormat:@"email=%@&list=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"email"], @"list"];
    NSLog(@"PostData: %@", post);
    
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/fetch.php"];
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
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        _arrPair = [responseData componentsSeparatedByString:@","];
        [self.pairTable reloadData];
    }
}


@end
