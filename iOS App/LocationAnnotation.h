//
//  LocationAnnotation.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 21/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface LocationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate title:(NSString *)newTitle subtitle:(NSString *)newSubtitle;

@end
