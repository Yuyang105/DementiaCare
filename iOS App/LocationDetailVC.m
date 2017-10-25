//
//  LocationDetailVC.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 21/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "LocationDetailVC.h"
#import "LocationAnnotation.h"

@interface LocationDetailVC ()

@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) NSString *locationsFileName;

@end

@implementation LocationDetailVC

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

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_locationID == -1) {
        // Set title of navigation bar and the prompt
        [[[self navigationBar] topItem] setTitle:@"Add Location"];
        [[[self navigationBar] topItem] setPrompt:@"Locations can be saved with a name for later"];
    
        // Scale the map accordingly to show the area around the location property
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([[self location] coordinate],
                                                                       0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [[self mapView] regionThatFits:viewRegion];
        [[self mapView] setRegion:adjustedRegion animated:YES];
    
        // Reverse Geocode the address
        CLGeocoder *gcrev = [[CLGeocoder alloc] init];
        [gcrev reverseGeocodeLocation:[self location] completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* revMark = [placemarks objectAtIndex:0];
            NSArray *addressLines = [[revMark addressDictionary] objectForKey:@"FormattedAddressLines"];
            NSString *revAddress = [addressLines componentsJoinedByString:@"\n"];
        
            [[self addressLabel] setText:revAddress];
            // Add any code that also wants to utilise this address here in the geocoder block
        
            LocationAnnotation *annotation = [[LocationAnnotation alloc]
                                                    initWithCoordinate:[[self location] coordinate]
                                                    title:@"Save Location?"
                                                    subtitle:revAddress];
            [[self mapView] addAnnotation:annotation];
        }];
    }
    else {
        [[self navigationBar] setHidden:YES];
        NSDictionary *entryDict = (NSDictionary *)[[self locationArray] objectAtIndex:_locationID];
        [[self nameTextField] setText:[entryDict objectForKey:@"label"]];
        
        CLLocation *theLocation = [[CLLocation alloc] initWithLatitude:[[entryDict objectForKey:@"latitude"] doubleValue] longitude:[[entryDict objectForKey:@"longitude"] doubleValue]];
        CLLocationCoordinate2D coordinate = {[[entryDict objectForKey:@"latitude"] doubleValue], [[entryDict objectForKey:@"longitude"] doubleValue]};
        
        // Scale the map accordingly to show the area around the location property
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate,
                                                                           0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [[self mapView] regionThatFits:viewRegion];
        [[self mapView] setRegion:adjustedRegion animated:YES];
        // Reverse Geocode the address
        CLGeocoder *gcrev = [[CLGeocoder alloc] init];
        [gcrev reverseGeocodeLocation:theLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* revMark = [placemarks objectAtIndex:0];
            NSArray *addressLines = [[revMark addressDictionary] objectForKey:@"FormattedAddressLines"];
            NSString *revAddress = [addressLines componentsJoinedByString:@"\n"];
            
            [[self addressLabel] setText:revAddress];
            [[self nameTextField] setEnabled:NO];
            // Add any code that also wants to utilise this address here in the geocoder block
            
            LocationAnnotation *annotation = [[LocationAnnotation alloc]
                                              initWithCoordinate:coordinate
                                              title:[entryDict objectForKey:@"label"]
                                              subtitle:revAddress];
            [[self mapView] addAnnotation:annotation];
        }];

        
    }
}

// The UITextFieldDelegate protocol defines the method textFieldSHouldReturn
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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

- (IBAction)saveAction:(id)sender {
    [[self delegate] newLocationEntryComplete:self wasCancelled:NO];
}

- (IBAction)cancelAction:(id)sender {
    [[self delegate] newLocationEntryComplete:self wasCancelled:YES];
}

@end
