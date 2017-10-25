//
//  LocationsTableVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 21/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "LocationsTableVC.h"

@interface LocationsTableVC ()

@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) NSString *locationsFileName;
@property (nonatomic) NSInteger locationID;

@end

@implementation LocationsTableVC


// ==================================================================
// Lazy instantiation of location Array and filename
// ==================================================================

- (NSString *) locationsFileName {
    if (_locationsFileName == nil) {
        // Find the locations.plist file in the user's Documents Directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        
        // <Application Home>/Documents/locations.plist
        _locationsFileName = [documentsPath stringByAppendingPathComponent:@"locations.plist"];
        
    }
    return _locationsFileName;
}

- (NSMutableArray *) locationArray {
    if (_locationArray == nil) {
        // Load the data into the Array
        if((_locationArray = [[NSMutableArray alloc] initWithContentsOfFile:[self locationsFileName]]) == nil) {
            // Failed to find file - probably doesn't exist.  Just create an empty array
            _locationArray = [[NSMutableArray alloc] init];
        }
    }
    return _locationArray;
}

- (void) syncLocationArray {
    [[self locationArray] writeToFile:[self locationsFileName] atomically:YES];
}

// =================================================
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self locationArray] count];
}

// Configure the cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *entryDict = (NSDictionary *)[[self locationArray] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[entryDict objectForKey:@"label"]];
    
    NSString *locStr = [NSString stringWithFormat:@"%.3f, %.3f",
                        [[entryDict objectForKey:@"latitude"] doubleValue],
                        [[entryDict objectForKey:@"longitude"] doubleValue]];
    [[cell detailTextLabel] setText:locStr];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[self locationArray] removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Detail
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.locationID = indexPath.row;
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueLocation" sender:self];
}

// =================================================
#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // wo shi chu nv zhuo
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Ensure the table data is reloaded when the view appear
    [[self tableView] reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Ensure the locationArray is always saved when the view disappears
    [self syncLocationArray];
    [self setLocationArray:nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"idSegueLocation"]) {
        LocationDetailVC *locationDetailVC = [segue destinationViewController];
        locationDetailVC.delegate = self;
        locationDetailVC.locationID = self.locationID;
    }
    
}


@end
