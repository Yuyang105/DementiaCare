//
//  MapVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 20/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()

@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) NSString *locationsFileName;

@end

@implementation MapVC

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
#pragma mark - Core Location Methods

// Lazy instantiation design pattern
// Create getter method locationManager to obtain the current location manager object
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        // Allocation and initialisation
        _locationManager = [[CLLocationManager alloc] init];
        // Set accuracy of the nearest 10 meters
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        // Set distance filter to 10 meters
        [_locationManager setDistanceFilter:10];
        // Set delegate
        [_locationManager setDelegate:self];
        [self.locationManager requestAlwaysAuthorization];
    }
    return _locationManager;
}

// =================================================
#pragma mark - Core Location Delegate Methods

// Report new location, i.e. the user has moved at least distanceFilter meters
- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:( CLLocation *)oldLocation {
    
    [[self addButton] setEnabled:YES];
    
    // Ensure that if we do something here, it is because we *are* in a different location
    if (([newLocation coordinate].latitude == [oldLocation coordinate].latitude) &&
        ([newLocation coordinate].longitude == [oldLocation coordinate].longitude))
        return;
    
    // Update location in log
    
    NSLog(@"MapVC new location: latitude %+.6f, longtitude %+.6f\n",
          [newLocation coordinate].latitude, [newLocation coordinate].longitude);
    
    // =================================================
    // Update to database, 可以的话就移到appdelegate
    
    // Use string to store location
    NSString *latitude = [NSString stringWithFormat:@"%+.6f", [newLocation coordinate].latitude];
    NSString *longtitude = [NSString stringWithFormat:@"%+.6f", [newLocation coordinate].longitude];
    NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    
    // Post to MySQL database, in order to enable caregiver's tracking
    NSString *post = [[NSString alloc] initWithFormat:@"user=%@&latitude=%@&longtitude=%@", user, latitude, longtitude];
    NSLog(@"PostData: %@", post);
    
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/location.php"];
    
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
    
    // Feedback
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSString * responseData = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
    }
    else {
        if (error) {
            NSLog(@"Error:%@", error);
        }
    }
    // =================================================
    

    // Update location in labels
    [[self latitudeLabel] setText:latitude];
    [[self longitudeLabel] setText:longtitude];
    
    
    // Specified region
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([newLocation coordinate], 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [[self mapView] regionThatFits:viewRegion];
    [[self mapView] setRegion:adjustedRegion animated:YES];
}

// Error! Handle with errors
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // For now, do nothing other than report to the log
    NSLog(@"Unable to get location events");
    [[self addButton] setEnabled:NO];
}

// =================================================
#pragma mark - Delegate Methods

- (void) newLocationEntryComplete:(LocationDetailVC *)controller wasCancelled:(BOOL)cancelled {
    
    NSLog(@"The %@ button was pressed", (cancelled==NO?@"Done":@"Cancel"));
    if (cancelled == NO) {
        // We want to create a new entry in our locations array
        // each entry will be stored as a dictionary
        // First retrieve the data from the child controller
        NSString *locationName = [[controller nameTextField] text];
        CLLocation *newLocation = [controller location];
        
        // Create the entry.  Note that we need to construct NSNumber objects for the latitude and longitude doubles.
        NSDictionary *entryDict = @{@"label":locationName,
                                    @"latitude":[NSNumber numberWithDouble:[newLocation coordinate].latitude],
                                    @"longitude":[NSNumber numberWithDouble:[newLocation coordinate].longitude]};
        
        // Finally, add the object to the array and synchronise (save) to the file
        [[self locationArray] addObject:entryDict];
        [self syncLocationArray];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

// =================================================
#pragma mark - IBActions

- (IBAction)addAction:(id)sender {
    
    // Get current location
    CLLocation *location = [[self locationManager] location];
    if (location == nil) {
        return;
    }
    
//    LocationDetailVC *myVC = [[LocationDetailVC alloc]
//                                  initWithNibName:@"WAI_LocationDetailVC" bundle:nil];
    
    LocationDetailVC *myVC = [[LocationDetailVC alloc] init];
    myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"idLocationDetail"];
    
    [myVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [myVC setDelegate:self];
    myVC.locationID = -1;
    
    [myVC setLocation:location];
    
    [self presentViewController:myVC animated:YES completion:nil];
}

// =================================================
#pragma mark - Lifecycle Methods

//// Each view controller managed by a UITabBarController
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    /* Key:NSLocationWhenInUseUsageDescription value:Uses current location */
//    // Ask for permission
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
//        [self.locationManager requestWhenInUseAuthorization];
//    
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Map" image:[UIImage imageNamed:@"103-map.png"] tag:0]];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];
    
    [[self addButton] setEnabled:NO];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"MapVC about to appear");
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00];
    // Change navigation title color
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHue:0.09 saturation:0.65 brightness:0.99 alpha:1.00]}];
    [[self locationManager] startUpdatingLocation];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"MapVC about to disappear");
    [[self locationManager] stopUpdatingLocation];
    
    // Set the locationArray to nil when the view disappears. Because other view controllers may change the plist file.
    [self setLocationArray:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
