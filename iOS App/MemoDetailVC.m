//
//  MemoDetailVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 10/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "MemoDetailVC.h"
#import "DBManager.h"

@interface MemoDetailVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrMemo;
// Private method
- (void)loadMemo;
- (void)editWasFinished;

@end

@implementation MemoDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
    [self loadMemo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMemo {
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from memo where memoID=%d", self.memoID];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    self.navigationItem.title = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"title"]];
    
    
    // Set the loaded data to the textfields.
    self.txtLabel.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"title"]];
    self.txtDetail.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"detail"]];
    NSString *imagePath = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"image"]];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      imagePath ];
    NSLog(@"path: %@",path);
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    [_imageView setImage:image];
}

- (IBAction)EditButton:(id)sender {
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEditMemo" sender:self];
}

- (void)editWasFinished {
    [self loadMemo];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //idSegueEditMemo
    if ([segue.identifier isEqualToString:@"idSegueEditMemo"]) {
        NewMemoVC *newMemoVC = [segue destinationViewController];
        newMemoVC.delegate = self;
        newMemoVC.memoID = self.memoID;
    }
}


@end
