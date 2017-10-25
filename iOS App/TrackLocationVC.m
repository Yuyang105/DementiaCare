//
//  TrackLocationVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 23/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "TrackLocationVC.h"
#import "LocationAnnotation.h"
#import "SBJson.h"
#import <CoreLocation/CoreLocation.h>

@interface TrackLocationVC ()

@end

@implementation TrackLocationVC


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
    }
    return _locationManager;
}

// =================================================
#pragma mark - Core Location Delegate Methods

// Report new location, i.e. the user has moved at least distanceFilter meters
- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:( CLLocation *)oldLocation {
    
    // Ensure that if we do something here, it is because we *are* in a different location
    if (([newLocation coordinate].latitude == [oldLocation coordinate].latitude) &&
        ([newLocation coordinate].longitude == [oldLocation coordinate].longitude))
        return;
    
    // Update location in log
    
    NSLog(@"MapVC new location: latitude %+.6f, longtitude %+.6f\n",
          [newLocation coordinate].latitude, [newLocation coordinate].longitude);
    [self showSpecifiedRegionAtLocation:newLocation];
    
}

// Error! Handle with errors
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // For now, do nothing other than report to the log
    NSLog(@"Unable to get location events");
}

// =================================================
#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];
    [self setAnnotations];
    
}

/* Show a specified region, which focused to a given location. */
- (void)showSpecifiedRegionAtLocation:(CLLocation *)loc {
    // Create a new region given the location of the central point
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([loc coordinate],
                                                                       2*METERS_PER_MILE, 2*METERS_PER_MILE);
    // Create a second region based on the dimensions of the map view, and adjust its aspect ratio
    MKCoordinateRegion adjustedRegion = [[self mapView] regionThatFits:viewRegion];
    // Display the specified region
    [[self mapView] setRegion:adjustedRegion animated:YES];
}


- (void)setAnnotations {
    NSString *post = [[NSString alloc] initWithFormat:@"email=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"email"]];
    NSLog(@"PostData: %@", post);
    
    NSURL *url = [NSURL URLWithString:@"http://www.cloudcampus.xyz/DementiaCare/getLocation.php"];
    
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
        NSString *name;
        float latitude, longtitude;
        
        NSArray *locList = [responseData componentsSeparatedByString:@"|"];
        
        for (int i = 0; i < locList.count; i++) {
            NSDictionary *jsonObject = [jsonParser objectWithString:locList[i] error:NULL];
            // Get the success object as an array
            NSArray *list = [jsonObject objectForKey:@"response"];
            // Iterate the array; each element is a dictionary..
            for (NSDictionary *response in list) {
                name = [response objectForKey:@"name"];
                latitude = [[response objectForKey:@"latitude"] floatValue];
                longtitude = [[response objectForKey:@"longtitude"] floatValue];
                
                CLLocation *theLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
                CLLocationCoordinate2D coordinate = {latitude, longtitude};
                
                // Reverse Geocode the address
                CLGeocoder *gcrev = [[CLGeocoder alloc] init];
                [gcrev reverseGeocodeLocation:theLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                    CLPlacemark* revMark = [placemarks objectAtIndex:0];
                    NSArray *addressLines = [[revMark addressDictionary] objectForKey:@"FormattedAddressLines"];
                    NSString *revAddress = [addressLines componentsJoinedByString:@"\n"];
                    
                    // Add any code that also wants to utilise this address here in the geocoder block
                    
                    LocationAnnotation *annotation = [[LocationAnnotation alloc]
                                                      initWithCoordinate:coordinate
                                                      title:name
                                                      subtitle:revAddress];
                    [[self mapView] addAnnotation:annotation];
                }];
            }
        }
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"MapVC about to appear");
    [[self locationManager] startUpdatingLocation];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"MapVC about to disappear");
    [[self locationManager] stopUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
    [self setAnnotations];
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
