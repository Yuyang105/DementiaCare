//
//  AlarmVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 14/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "AlarmVC.h"

@interface AlarmVC ()

@end

@implementation AlarmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtCancelMessage.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    //NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSTimeInterval animationDuration = 1000000;
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height - (keyboardRect.size.height - 50);
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    //NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSTimeInterval animationDuration = 1000000;
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height + (keyboardRect.size.height - 50);
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)emergencyButton:(id)sender {
    NSString *post = [[NSString alloc] initWithFormat:@"user=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"email"]];
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/apns.php"];
    NSData * postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Lenght"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSHTTPURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        [self alert:@"Emergency alert has been delivered to your caregiver" :@"Send Successfully"];
    }
    else {
        if (error) {
            NSLog(@"Error:%@", error);
            [self alert:@"Connection Failed" :@"Alert Message Delivery Failed!"];
        }
    }
}

- (IBAction)cancelButton:(id)sender {
    NSString *post = [[NSString alloc] initWithFormat:@"cancel_msg=%@&user=%@", self.txtCancelMessage.text, [[NSUserDefaults standardUserDefaults] stringForKey:@"email"]];
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/apns.php"];
    NSData * postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Lenght"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSHTTPURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        [self alert:@"Cancel message has been delivered to your caregiver" :@"Send Successfully!"];
    }
    else {
        if (error) {
            NSLog(@"Error:%@", error);
            [self alert:@"Connection Failed" :@"Cancel Message Delivery Failed!"];
        }
    }
}

// Status Alert
- (void)alert:(NSString *)msg :(NSString *)title {
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Actions
    }]];
    
    [self presentViewController:alertView animated:true completion:nil];
    
    
}

// Remove the keyboard..
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.backgroundColor = [UIColor whiteColor];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    textView.backgroundColor = [UIColor colorWithHue:0.67 saturation:0.02 brightness:0.96 alpha:1.00];
}



@end
