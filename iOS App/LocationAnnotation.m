//
//  LocationAnnotation.m
//  DementiaCare
//
//  Created by 喻 煜阳 on 21/04/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import "LocationAnnotation.h"

@interface LocationAnnotation ()

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *subtitle;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end

@implementation LocationAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate title:(NSString *)newTitle subtitle:(NSString *)newSubtitle {
    
    if ((self = [super init])) {
        [self setTitle:[newTitle copy]];
        [self setSubtitle:[newSubtitle copy]];
        [self setCoordinate:newCoordinate];
    }
    return self;
}

@end