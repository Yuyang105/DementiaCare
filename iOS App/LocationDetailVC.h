//
//  LocationDetailVC.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 21/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define METERS_PER_MILE 1609.344

@protocol LocationDetailVCDelegate;

@interface LocationDetailVC : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@property (strong, nonatomic) id <LocationDetailVCDelegate> delegate;
@property (nonatomic) NSInteger locationID;
@property (strong, nonatomic)  CLLocation *location;


@end


// Dismiss
@protocol LocationDetailVCDelegate

// It will be called when the modal(child) VC asks the parent VC to be dismissed.
- (void) newLocationEntryComplete:(LocationDetailVC *)controller wasCancelled:(BOOL)cancelled;

@end