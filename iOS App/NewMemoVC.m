//
//  NewMemoVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 09/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "NewMemoVC.h"
#import "DBManager.h"

@interface NewMemoVC ()

// Private property
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSString *imagePath;

// Private method
-(void)loadMemoToEdit;

@end

@implementation NewMemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.txtTitle.delegate = self;
    self.txtDetail.delegate = self;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"localdb.sql"];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    }
    
    // Check if should load specific record for editing.
    if (self.memoID != -1) {
        // Load the record with the specific ID from the database.
        [self loadMemoToEdit];
    }
    else {
        NSBundle *mainBundle = [NSBundle mainBundle];
        _imagePath = [mainBundle pathForResource: @"defualt" ofType: @"jpg"];
    
        // Save defualt image
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:
                          @"defualt.jpg" ];
        NSData* data = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:_imagePath]);
        [data writeToFile:path atomically:YES];
    
        _imagePath = @"defualt.jpg";
        NSLog(@"Main bundle path: %@", mainBundle);
        NSLog(@"imageFile path: %@", _imagePath);
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Class Method

- (IBAction)saveMemo:(id)sender {
    // Prepare the query string.
    // If the recordIDToEdit property has value other than -1, then create an update query. Otherwise create an insert query.
    NSString *query;
    
    if (self.memoID == -1) {
        query = [NSString stringWithFormat:@"insert into memo values(null, '%@', '%@', '%@')", self.txtTitle.text, self.txtDetail.text, [[@"" stringByAppendingString:_imagePath] stringByAppendingString:@""]];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // If the query was successfully executed then pop the view controller.
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            
            // Inform the delegate that the editing was finished.
            [self.delegate newMemoWasFinished];
            
            // Pop the view controller.
            // [self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSLog(@"Could not execute the query.");
        }

    }
    else{
        query = [NSString stringWithFormat:@"update memo set title='%@', detail='%@', image='%@' where memoID=%d", self.txtTitle.text, self.txtDetail.text, [[@"" stringByAppendingString:_imagePath] stringByAppendingString:@""], self.memoID];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // If the query was successfully executed then pop the view controller.
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            
            // Inform the delegate that the editing was finished.
            [self.delegate editWasFinished];
            
            // Pop the view controller.
            //[self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSLog(@"Could not execute the query.");
        }
    }
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    _imagePath = [[NSProcessInfo processInfo] globallyUniqueString] ;
    
    NSLog(@"uniqueFileName: '%@'", _imagePath);
    
    
    _imagePath = [_imagePath stringByAppendingString:@".jpg"];
    
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      _imagePath ];
    NSData* data = UIImagePNGRepresentation(chosenImage);
    [data writeToFile:path atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

// Edit existed memo issue
-(void)loadMemoToEdit{
    // Set title
    self.navigationItem.title = @"Edit Memo";
    
    // Create the query.
    NSString *query = [NSString stringWithFormat:@"select * from memo where memoID=%d", self.memoID];
    
    // Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set the loaded data to the textfields.
    self.txtTitle.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"title"]];
    self.txtDetail.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"detail"]];
    _imagePath = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"image"]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      _imagePath ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    [_imageView setImage:image];
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
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
}


@end
