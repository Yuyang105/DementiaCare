//
//  MemoTVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 10/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "MemoTVC.h"
#import "DBManager.h"

@interface MemoTVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrMemo;
@property (nonatomic) int memoID;

@end

@implementation MemoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make self the delegate and datasource of the table view.
    self.tblMemo.delegate = self;
    self.tblMemo.dataSource = self;

    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:self.navigationItem.rightBarButtonItem.tintColor}];
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
    
    // Load the data
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrMemo.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idMemo" forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger indexOfTitle = [self.dbManager.arrColumnNames indexOfObject:@"title"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [[self.arrMemo objectAtIndex:indexPath.row] objectAtIndex:indexOfTitle];
    
    [cell setTintColor:[UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00]];
    
    return cell;
}

// Load data
- (void)loadData {
    // Form the query.
    NSString *query = @"select * from memo";
    
    // Get the results.
    if (self.arrMemo != nil) {
        self.arrMemo = nil;
    }
    self.arrMemo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    [self.tblMemo reloadData];
    
}

// New Memo is added
-(void)newMemoWasFinished{
    // Reload the data.
    [self loadData];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int dailyIDToDelete = [[[self.arrMemo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from memo where memoID=%d", dailyIDToDelete];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // Reload the table view.
        [self loadData];
    }
    
}

// Select a row to view details
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.memoID = [[[self.arrMemo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueMemoDetail" sender:self];
}

// Click the detail button of a cell
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.memoID = [[[self.arrMemo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueMemoDetail" sender:self];
}


#pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     
     if ([segue.identifier isEqualToString:@"idSegueMemoDetail"]) {
         NSLog(@"segue test");
         MemoDetailVC *memoDetailVC = [segue destinationViewController];
         memoDetailVC.delegate = self;
         memoDetailVC.memoID = self.memoID;
     }
     else {
         NewMemoVC *newMemoVC = [segue destinationViewController];
         newMemoVC.delegate = self;
         newMemoVC.memoID = -1;
     }
     
}


@end
