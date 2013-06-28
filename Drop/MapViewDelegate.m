//
//  MapViewDelegate.m
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "MapViewDelegate.h"
#import "DroppedPinViewController.h"
#import "DropboxBrowserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Drop.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "GIKPopoverBackgroundView.h"

@interface MapViewDelegate ()
-(void)removeDrop:(NSNotification*)notification;
@end

@implementation MapViewDelegate

-(id)initWithMapView:(MKMapView*)mapView viewController:(UIViewController*)view {
    self = [super init];
    if (self) {
        _mapView = mapView;
        _view = view;
		_allPosts = [[NSMutableArray alloc] initWithCapacity:100];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopover) name:@"DismissPopoverNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDrop:) name:@"RemoveAnnoationNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryForAllPosts) name:@"QueryForAllPosts" object:nil];
        [self queryForAllPosts];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mapView:(MKMapView *)MapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (![view.annotation isKindOfClass:[MKUserLocation class]]) {
        _droppedPin = view.annotation;
        DroppedPinViewController *droppedPinView = [[DroppedPinViewController alloc]initWithNibName:@"DroppedPinViewController" mapView:self.mapView annotation:_droppedPin];
        if (self.popoverController == nil) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:droppedPinView];
            popover.delegate = self;
            self.popoverController = popover;
        } else {
            [_popoverController setContentViewController:droppedPinView animated:YES];
        }
        if ([[_droppedPin getUsername] isEqualToString:[[PFUser currentUser] username]]) {
            [_popoverController setPopoverContentSize:CGSizeMake(337, 165)];
        } else {
            [_popoverController setPopoverContentSize:CGSizeMake(337, 113)];
        }
        [_popoverController setPopoverBackgroundViewClass:[GIKPopoverBackgroundView class]];
        CGPoint annotationPoint = [self.mapView convertCoordinate:view.annotation.coordinate toPointToView:self.mapView];
        CGRect box = CGRectMake(annotationPoint.x, annotationPoint.y, 5, 5);
        [_popoverController presentPopoverFromRect:box inView:_mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
    
	if ([annotation isKindOfClass:[Drop class]]) {
        static NSString* const kIdentifier = @"Annotation";
        MKPinAnnotationView* view = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kIdentifier];
		if (!view) {
			view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kIdentifier];
            view.pinColor = MKPinAnnotationColorGreen;
		}
		else {
			view.annotation = annotation;
		}
        Drop *drop = view.annotation;
        if([[drop username] isEqualToString:@""]) {
            PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
            [query includeKey:kParseUserKey];
            PFObject *object = [query getObjectWithId:drop.object.objectId];
            PFUser *user = [object objectForKey:kParseUserKey];
            [object fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if ([[[PFUser currentUser] username] isEqualToString:[user username]]) {
                    view.pinColor = MKPinAnnotationColorGreen;
                } else {
                    view.pinColor = MKPinAnnotationColorRed;
                }
            }];
        } else {
            if ([[[PFUser currentUser] username] isEqualToString:[drop username]]) {
                view.pinColor = MKPinAnnotationColorGreen;
            } else {
                view.pinColor = MKPinAnnotationColorRed;
            }
        }
		view.animatesDrop = YES;
		return view;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for(MKPinAnnotationView *eachView in views) {
        NSLog(@"");
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [_mapView deselectAnnotation:self.droppedPin animated:YES];
    _popoverController = nil;
}
         
- (void)linkDropboxFileForDrop:(Drop*)drop {
    DropboxDelegate* dropBoxDelegate = [[DropboxDelegate alloc] init];
    dropBoxDelegate.view = self.view;
    dropBoxDelegate.drop = drop;
    DropboxBrowserViewController *browser = [[DropboxBrowserViewController alloc] init];
    [browser setDelegate:dropBoxDelegate];
    UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"DropBoxStoryboard" bundle:[NSBundle mainBundle]];
    [DropboxBrowserViewController displayDropboxBrowserInPadStoryboard:iPadStoryboard onView:_view withPresentationStyle:UIModalPresentationFormSheet withTransitionStyle:UIModalTransitionStyleFlipHorizontal withDelegate:dropBoxDelegate];
}

-(void)removeDrop:(NSNotification*)notification {
    [_mapView removeAnnotation:[notification object]];
}

#pragma mark modal view controller delegate methods

-(void)dismissPopover {
    [_mapView deselectAnnotation:self.droppedPin animated:YES];
    [_popoverController dismissPopoverAnimated:YES];
}

#pragma mark - Fetch map pins

- (void)queryForAllPosts {
    if([PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        if ([self.allPosts count] == 0) {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            } else {
                NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:100];
                NSMutableArray *allNewPosts = [[NSMutableArray alloc] initWithCapacity:100];
                for (PFObject *object in objects) {
                    Drop *drop = [[Drop alloc] initWithDrop:object];
                    if ([drop canUserSeeDrop]) {
                        [allNewPosts addObject:drop];
                    } else {
                        NSLog(@"Denied Access");
                    }
                    BOOL found = NO;
                    for (Drop *currentDrop in _allPosts) {
                        if ([drop equalToDrop:currentDrop]) {
                            found = YES;
                        }
                    }
                    if (!found && [drop canUserSeeDrop]) {
                        [newPosts addObject:drop];
                    }
                }
                NSMutableArray *postsToRemove = [[NSMutableArray alloc] initWithCapacity:100];
                for (Drop *currentPost in _allPosts) {
                    BOOL found = NO;
                    for (Drop *allNewPost in allNewPosts) {
                        if ([currentPost equalToDrop:allNewPost]) {
                            found = YES;
                        }
                    }
                    if (!found) {
                        [postsToRemove addObject:currentPost];
                    }
                }
                [_mapView removeAnnotations:postsToRemove];
                [_mapView addAnnotations:newPosts];
                [_allPosts addObjectsFromArray:newPosts];
                [_allPosts removeObjectsInArray:postsToRemove];
            }
        }];
    }
}

@end
