//
//  RegisterVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 07/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "RegisterVC.h"
#import "SBJson.h"

@interface RegisterVC ()

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.txtName.delegate = self;
    self.txtEmail.delegate = self;
    self.txtPassword.delegate = self;
    self.txtConfirmation.delegate = self;
    self.txtGender.delegate = self;
    self.txtAge.delegate = self;
    self.txtType.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Class Methods

// Resign the textfield from first responder
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

// Success
- (void)alertSuccess:(NSString *)msg :(NSString *)title {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Actions
        NSLog(@"Pressed Continue...");
        [self performSegueWithIdentifier:@"idRegisterBackSegue" sender:self];
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

- (IBAction)saveButton:(id)sender {
    // 1 for male and patient, 0 for female and caregiver
    int gender = 0, type = 0;
    
    @try {
        if([[_txtName text] isEqualToString:@""] || [[_txtEmail text] isEqualToString:@""] || [[_txtPassword text] isEqualToString:@""] || [[_txtConfirmation text] isEqualToString:@""] || [[_txtGender text] isEqualToString:@""] || [[_txtAge text] isEqualToString:@""] || [[_txtType text] isEqualToString:@""]) {
            [self alertFailed:@"Please complete all the blanks" :@"Sign up Failed!"];
        }
        else if(![[_txtPassword text] isEqualToString:[_txtConfirmation text]]) {
            [self alertFailed:@"Please check that your passwords match and try again" :@"Sign up Failed!"];
        }
        else if(![[_txtGender text] isEqualToString:@"M"] && ![[_txtGender text] isEqualToString:@"F"]) {
            [self alertFailed:@"Please make sure that your Gender should be M or F" :@"Sign up Failed!"];
        }
        else if(![[_txtType text] isEqualToString:@"Patient"] && ![[_txtType text] isEqualToString:@"Caregiver"]) {
            [self alertFailed:@"Your User Type should be Patient or Caregiver" :@"Sign up Failed!"];
        }
        else if (![[_txtEmail text] containsString:@"@"]) {
            [self alertFailed:@"Your email address has an invalid email address format. Please correct and try agian" :@"Sign up Failed!"];
        }
        else {
            
            if([[_txtGender text] isEqualToString:@"M"])
                gender = 1;
            if ([[_txtType text] isEqualToString:@"Patient"])
                type = 1;

            NSString *post = [[NSString alloc] initWithFormat:@"name=%@&email=%@&password=%@&gender=%d&age=%d&type=%d",[_txtName text], [_txtEmail text], [_txtPassword text], gender, [[_txtAge text] intValue], type];
            NSLog(@"PostData: %@", post);
            
            NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/register.php"];
            
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
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                NSLog(@"%@",jsonData);
                NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                NSLog(@"%ld", (long)success);
                if (success == 1) {
                    NSLog(@"Register Success");
                    [self alertSuccess:@"Welcome to DementiaCare" :@"Registration Successful!"];
                }
                else {
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    [self alertFailed:error_msg :@"Sign up Failed! Please check your details and try again!"];
                }
            }
            else {
                if (error) {
                    NSLog(@"Error:%@", error);
                    [self alertFailed :@"Connection Failed" :@"Sign up Failed!"];
                }
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
        [self alertFailed:@"Sign up Failed." :@"Sign up Failed!"];
    }
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
