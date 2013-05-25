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
@property (nonatomic, retain) PFObject *object;
@property (nonatomic, retain) PFGeoPoint *geopoint;
@property (nonatomic, retain) PFUser *user;
@property (nonatomic, retain) PFFile *file;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSArray *sharedUsers;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithDrop:(PFObject *)object;
- (void)setDropBoxFile:(PFFile *)file;
- (BOOL)equalToDrop:(Drop *)drop;
- (BOOL)canUserSeeDrop:(Drop *)drop;
- (NSString *)getUsername;
- (void)shareFileWithUsers:(NSArray *)users;
- (void)makeFilePublic;
- (void)deleteDrop;

@end
