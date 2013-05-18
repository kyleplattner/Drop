//
//  DroppedPinModel.h
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface DroppedPinModel : NSManagedObject <MKAnnotation>

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber *UUID;;
@property (nonatomic, retain) PFObject *object;
@property (nonatomic, retain) PFGeoPoint *geopoint;
@property (nonatomic, retain) PFUser *user;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate;

@end
