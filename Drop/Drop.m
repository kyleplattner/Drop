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
        self.username = [[PFUser currentUser] username];
        self.file = nil;
        self.filename = nil;
        self.url = nil;
        self.sharedUsers = nil;
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
        self.filename = [object objectForKey:kParseFilenameKey];
        self.username = [object objectForKey:kParseUsernameKey];
        self.sharedUsers = [object objectForKey:kParseSharedUserArrayKey];
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

-(BOOL)canUserSeeDrop:(Drop *)drop {
    if ([_sharedUsers containsObject:[drop getUsername]] || [_sharedUsers containsObject:@"public"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setDropBoxFile:(PFFile *)file {
    self.file = file;
}

- (NSString *)getUsername {
    if([_username isEqualToString:@""]) {
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        [query includeKey:kParseUserKey];
        PFObject *object = [query getObjectWithId:self.object.objectId];
        PFUser *user = [object objectForKey:kParseUserKey];
        return user.username;
    } else {
        return _username;
    }
}

-(void)shareFileWithUsers:(NSArray *)users {
    NSMutableArray *userArray = [[NSMutableArray alloc] initWithArray:self.sharedUsers];
    [userArray addObjectsFromArray:users];
    PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
    [query includeKey:kParseSharedUserArrayKey];
    PFObject *object = [query getObjectWithId:self.object.objectId];
    [object setObject:userArray forKey:kParseSharedUserArrayKey];
    [object save];
}

-(void)makeFilePublic {
    NSMutableArray *userArray = [[NSMutableArray alloc] initWithArray:self.sharedUsers];
    if (![userArray containsObject:@"public"]) {
        NSArray *public = [[NSArray alloc] initWithObjects:@"public", nil];
        [userArray addObjectsFromArray:public];
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        [query includeKey:kParseSharedUserArrayKey];
        PFObject *object = [query getObjectWithId:self.object.objectId];
        [object setObject:userArray forKey:kParseSharedUserArrayKey];
        [object save];
    }
}

-(void)deleteDrop {
    PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
    PFObject *object = [query getObjectWithId:self.object.objectId];
    [object delete];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* localPath = [documentsPath stringByAppendingPathComponent:self.filename];
    if([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    }
}

@end