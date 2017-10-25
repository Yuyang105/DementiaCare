//
//  MapVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 20/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationDetailVC.h"

#define METERS_PER_MILE 1609.344


@interface MapVC : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)addAction:(id)sender;

@end
