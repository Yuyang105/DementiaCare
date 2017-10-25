//
//  CaregiverHomeVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 20/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "CaregiverHomeVC.h"
#import "DBManager.h"
#import "FFNavbarMenu.h"
#import "SBJson.h"
#import "LoginVC.h"
#import "PairVC.h";

@interface CaregiverHomeVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NSArray *arrUser;
@property (nonatomic, strong) NSArray *arrDaily;

@property (assign, nonatomic) NSInteger numberOfItemsInRow;
@property (strong, nonatomic) FFNavbarMenu *menu;

// Private method
- (void)loadHome;

@end

@implementation CaregiverHomeVC

// pull down menu
- (FFNavbarMenu *)menu {
    if (_menu == nil) {
        FFNavbarMenuItem *item1 = [FFNavbarMenuItem ItemWithTitle:@"Application Setting" icon:nil];
        FFNavbarMenuItem *item2 = [FFNavbarMenuItem ItemWithTitle:@"Feedback" icon:nil];
        FFNavbarMenuItem *item3 = [FFNavbarMenuItem ItemWithTitle:@"Logout" icon:nil];
        
        _menu = [[FFNavbarMenu alloc] initWithItems:@[item1, item2, item3] width:375 maximumNumberInRow:_numberOfItemsInRow];
        _menu.backgroundColor = [UIColor colorWithHue:0.12 saturation:0.43 brightness:1.00 alpha:1.00];
        _menu.separatarColor = [UIColor lightGrayColor];
        //        _menu.textColor = [UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00];
        _menu.textColor = [UIColor blackColor];
        _menu.delegate = self;
    }
    return _menu;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    self.numberOfItemsInRow = 1;
    [[[self navigationItem] rightBarButtonItem] setTarget:self];
    [[[self navigationItem] rightBarButtonItem] setAction:@selector(openMenu:)];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00];
    
    // Change navigation title color
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00]}];
    
    // Make self the delegate of the textfields.
    self.txtRequest.delegate = self;
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
    [self loadHome];
}

- (void)loadHome {
    // Welcome
    NSString *query = @"select * from user";
    // Get the results.
    if (self.arrUser != nil) {
        self.arrUser = nil;
    }
    self.arrUser = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    NSInteger num = self.arrUser.count - 1;
    if (num >= 0) {
        NSString *name = [NSString stringWithFormat:@"Hello, %@!",[[self.arrUser objectAtIndex: num] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"name"]]];
        [[self txtWelcome] setText:name];
    }
    else {
        [[self txtWelcome] setText:@"Hello, Master! "];
    }
    
    // load caregivers
    
    
}


- (IBAction)sendRequest:(id)sender {
    @try {
        if ([[[self txtRequest] text] isEqualToString:@""]) {
            [self alert:@"Please enter his/her email account" :@"Request Failed!"];
        }
        else if (![[[self txtRequest] text] containsString:@"@"]) {
            [self alert:@"The email address has an invalid email address format. Please correct and try agian" :@"Request Failed!"];
        }
        else {
            NSString *post = [[NSString alloc] initWithFormat:@"email=%@&account=%@&pair=%@",[[self txtRequest] text], [[NSUserDefaults standardUserDefaults] stringForKey:@"email"], @"NewRequest"];
            NSLog(@"PostData: %@", post);
            
            NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/request.php"];
            
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
                NSInteger success = 100; // Defualt number, indicates error
                
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                
                
                
                NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                NSLog(@"%@",jsonData);
                
                success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                
                if (success == 1) {
                    NSLog(@"Request Successfully");
                    // Set user state
                    
                    [self alertSuccess:@"Pair request has been deliveried to your wanted patient. Please wait for his/her confirmation." :@"Request Successfully!"];
                }
                else {
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    [self alert:error_msg :@"Request Failed"];
                    NSLog(@"Request failed ");
                }
            }
            else {
                if (error) {
                    NSLog(@"Error:%@", error);
                    [self alert :@"Connection Failed" :@"Request Failed!"];
                }
            }
            
        }
        
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
        [self alert:@"Login Failed." :@"Login Failed!"];
    }
}

// Success
- (void)alertSuccess:(NSString *)msg :(NSString *)title {
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Back", nil];
    //
    //    [alertView show];
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Actions
        self.txtRequest.text = @"";
    }]];
    [self presentViewController:alertView animated:true completion:nil];
}

// Failed
- (void)alert:(NSString *)msg :(NSString *)title {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Try-Again" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Actions
    }]];
    [self presentViewController:alertView animated:true completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self loadHome];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.menu) {
        [self.menu dismissWithAnimation:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)openMenu:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(FFNavbarMenu *)menu {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(FFNavbarMenu *)menu {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(FFNavbarMenu *)menu atIndex:(NSInteger)index {
    
    // logout
    if (index == 2) {
        // Remove logged status
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
        [self performSegueWithIdentifier:@"idSegueCaregiverLogout" sender:self];
    }
    
}

// Resign the textfield from first responder
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    int move = 50 - keyboardRect.size.height;
    [self.view setFrame:CGRectMake(0, move, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)patientButton:(id)sender {

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
