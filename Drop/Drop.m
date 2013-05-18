//
//  Drop.m
//  Drop
//
//  Created by Kyle Plattner on 5/15/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "Drop.h"
#import "AppDelegate.h"

@interface Drop ()
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;
//add pffile
@end

@implementation Drop

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        [self setCoordinate:_coordinate];
        [self.geopoint setLatitude:coordinate.latitude];
        [self.geopoint setLongitude:coordinate.longitude];
        self.user = [PFUser currentUser];
        self.user.username = [[PFUser currentUser] username];
        NSUUID  *UUID = [NSUUID UUID];
        self.uuid = [UUID UUIDString];
    }
    return self;
}

- (id)initWithDrop:(PFObject *)object {
    self = [super init];
    if (self) {
        [object fetchIfNeeded];
        self.object = object;
        self.geopoint = [object objectForKey:kParseLocationKey];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
        _coordinate = location;
        [self setCoordinate:_coordinate];
        self.user = [object objectForKey:kParseUserKey];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
        self.coordinate = coordinate;
        NSUUID  *UUID = [NSUUID UUID];
        self.uuid = [UUID UUIDString];
    }
    return self;
}

- (BOOL)equalToDrop:(Drop *)drop {
	if (drop == nil) {
		return NO;
	}
    
	if (drop.object && self.object) {
		if ([drop.object.objectId compare:self.object.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		NSLog(@"%s Testing equality of Drops where one or both objects lack a backing PFObject", __PRETTY_FUNCTION__);
        
		if (drop.coordinate.latitude != self.coordinate.latitude || drop.coordinate.longitude != self.coordinate.longitude) {
			return NO;
		}
		return YES;
	}
}

- (void)setDropBoxFile:(PFObject *)object {
    self.object = object;
}

@end
