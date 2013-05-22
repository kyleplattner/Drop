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
//@property (nonatomic, strong) PFObject *object;
//@property (nonatomic, strong) PFGeoPoint *geopoint;
//@property (nonatomic, strong) PFUser *user;
//@property (nonatomic, strong) PFFile *file;
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
        self.file = nil;
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
        self.coordinate = location;
        self.file = [object objectForKey:kParseFileKey];
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
		if (drop.coordinate.latitude != self.coordinate.latitude || drop.coordinate.longitude != self.coordinate.longitude) {
			return NO;
		}
		return YES;
	}
}

- (void)setDropBoxFile:(PFFile *)file {
    self.file = file;
}

- (NSString *)getUsername {
    PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
    [query includeKey:kParseUserKey];
    PFObject *object = [query getObjectWithId:self.object.objectId];
    PFUser *testUser = [object objectForKey:kParseUserKey];
    return testUser.username;
}

@end
