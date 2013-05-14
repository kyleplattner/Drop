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

@property (nonatomic, copy) NSNumber *UUID;
@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;

@end

@implementation DroppedPinModel

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        [self setCoordinate:_coordinate];
        
    }
    return self;
}

@end
