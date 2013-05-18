//
//  Drop.h
//  Drop
//
//  Created by Kyle Plattner on 5/15/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface Drop : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *uuid;
@property (nonatomic, readonly, strong) PFObject *object;
@property (nonatomic, readonly, strong) PFGeoPoint *geopoint;
@property (nonatomic, readonly, strong) PFUser *user;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithDrop:(PFObject *)object;
- (void)setDropBoxFile:(PFObject *)object;
- (BOOL)equalToDrop:(Drop *)drop;

@end
