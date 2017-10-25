//
//  LoginVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 05/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "LoginVC.h"
#import "SBJson.h"
#import "DBManager.h"

//#define getDataURL @"http://www.cloudcampus.xyz/DementiaCare/userJson.php"

@interface LoginVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation LoginVC
//@synthesize jsonArray, usersArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.email.delegate = self;
    self.password.delegate = self;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class Methods

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];   //it hides
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *logged_email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    if (logged_email.length != 0) {
        // A time pause indicates the user you have auto logged in
        [NSThread sleepForTimeInterval:0.5];
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"type"] isEqualToString:@"Patient"]) {
            [self performSegueWithIdentifier:@"idLoginSegue" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"idSegueCaregiver" sender:self];
        }
    }
}

// Resign the textfield from first responder
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

// Success
- (void)alertSuccess:(NSString *)msg :(NSString *)title {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Back", nil];
//    
//    [alertView show];
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Actions
        NSLog(@"Pressed Continue...");
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"type"] isEqualToString:@"Patient"]) {
            [self performSegueWithIdentifier:@"idLoginSegue" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"idSegueCaregiver" sender:self];
        }
    }]];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertView animated:true completion:nil];
    
    
}

// Failed
- (void)alertFailed:(NSString *)msg :(NSString *)title {
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Try-again" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Actions
    }]];
    
    [self presentViewController:alertView animated:true completion:nil];
    
    
}


- (IBAction)loginButton:(id)sender {
    
    @try {
        if([[_email text] isEqualToString:@""] || [[_password text] isEqualToString:@""]) {
            [self alertFailed:@"Please enter both Username and Password" :@"Login Failed!"];
        }
        else {
            NSString *post = [[NSString alloc] initWithFormat:@"email=%@&password=%@",[_email text], [_password text]];
            NSLog(@"PostData: %@", post);
            
            NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/login.php"];
            
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
                NSString *name, *email;
                int gender = 100, age = 100, type = 100;
                
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                
                // Get the top level value as a dictionary
                NSDictionary *jsonObject = [jsonParser objectWithString:responseData error:NULL];
                // Get the success object as an array
                NSArray *list = [jsonObject objectForKey:@"response"];
                // Iterate the array; each element is a dictionary..
                for (NSDictionary *response in list) {
                    success = [[response objectForKey:@"success"] integerValue];
                    // .. that contains a string for the key "name", "email", etc..
                    name = [response objectForKey:@"name"];
                    email = [response objectForKey:@"email"];
                    gender = [[response objectForKey:@"gender"] intValue];
                    age = [[response objectForKey:@"age"] intValue];
                    type = [[response objectForKey:@"type"] intValue];
                    
                    NSLog(@"Name:%@",name);
                    NSLog(@"Email:%@",email);
                    NSLog(@"Gender:%d",gender);
                    NSLog(@"Age:%d",age);
                    NSLog(@"User_Type:%d",type);
                    
                    // Save user info for further usage
                    // Prepare the query string.
                    NSString *query = [NSString stringWithFormat:@"insert into user values('%@', '%@', %d, %d, %d)", name, email, gender, age, type];
                    
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
                
                
//                NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
//                NSLog(@"%@",jsonData);
                
//                NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                
                if (success == 1) {
                    NSLog(@"Login Success");
                    // Set user state
                    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
                    // Patient
                    if (type == 1) {
                        [[NSUserDefaults standardUserDefaults] setObject:@"Patient" forKey:@"type"];
                    }
                    else {
                        [[NSUserDefaults standardUserDefaults] setObject:@"Caregiver" forKey:@"type"];
                    }
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self alertSuccess:@"Logged in Successfully" :@"Login Success!"];
                }
                else {
                    NSString *error_msg = (NSString *) [jsonObject objectForKey:@"error_message"];
                    [self alertFailed:error_msg :@"Login Failure! Correct your credentials"];
                    NSLog(@"Correct your credentials");
                }
            }
            else {
                if (error) {
                    NSLog(@"Error:%@", error);
                    [self alertFailed :@"Connection Failed" :@"Login Failed!"];
                }
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
        [self alertFailed:@"Login Failed." :@"Login Failed!"];
    }
}

- (IBAction)registerButton:(id)sender {
    
}

- (IBAction)forgottenButton:(id)sender {
    
}


@end
