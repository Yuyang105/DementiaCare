//
//  TrackLocationVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 23/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define METERS_PER_MILE 1609.344

@interface TrackLocationVC : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

-(IBAction)refresh:(id)sender;


@end
