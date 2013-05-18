//
//  DroppedPinModel.m
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "DroppedPinModel.h"
#import <MapKit/MapKit.h>

@interface DroppedPinModel ()

@end

@implementation DroppedPinModel

@dynamic latitude;
@dynamic longitude;
@dynamic UUID;
@dynamic object;
@dynamic geopoint;
@dynamic user;
@synthesize coordinate = _coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        [self setCoordinate:_coordinate];
    }
    return self;
}

@end
