//
//  DroppedPinViewController.m
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "DroppedPinViewController.h"
#import "Drop.h"
#import "AppDelegate.h"
#import "PreviewController.h"
#import "UserPickerViewController.h"
#import "NPReachability.h"
#import "GIKPopoverBackgroundView.h"
#import "BButton.h"
#import "DCRoundSwitch.h"
#import "MBProgressHUD.h"

@interface DroppedPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *isPublicLabel;
@property (weak, nonatomic) IBOutlet BButton *deleteButton;
@property (weak, nonatomic) IBOutlet BButton *shareButton;
@property (weak, nonatomic) IBOutlet BButton *viewButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (retain, nonatomic) DCRoundSwitch *publicSwitch;
-(IBAction)publicSwitch:(id)sender;
-(IBAction)viewFileButtonPressed:(id)sender;
-(IBAction)deleteDropButtonPressed:(id)sender;
-(IBAction)shareFileButtonPressed:(id)sender;
-(NSString *)fileExtension;
@end

@implementation DroppedPinViewController

-(id)initWithNibName:(NSString *)nibName mapView:(MKMapView *)mapView annotation:(Drop*)droppedPin {
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        _mapView = mapView;
        _droppedPin = droppedPin;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopover) name:@"CloseUserSharingPopoverNotification" object:nil];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[_droppedPin filename] isEqualToString:@""]) {
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        PFObject *object = [query getObjectWithId:_droppedPin.object.objectId];
        [object fetchIfNeeded];
        [_droppedPin setFilename:[object objectForKey:kParseFilenameKey]];
        [_label setText:[object objectForKey:kParseFilenameKey]];
    } else {
        [_label setText:[_droppedPin filename]];
    }
    _publicSwitch = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(11, 118, 89, 30)];
    [_publicSwitch addTarget:self action:@selector(publicSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_publicSwitch];
    [_usernameLabel setText:[NSString stringWithFormat:@"Posted by: %@", [_droppedPin getUsername]]];
    [_shareButton setHidden:![self shouldAllowDeleteAndShare]];
    [_deleteButton setHidden:![self shouldAllowDeleteAndShare]];
    [_publicSwitch setHidden:![self shouldAllowDeleteAndShare]];
    [_isPublicLabel setHidden:![self shouldAllowDeleteAndShare]];
    [_thumbnail setImage:[self fileThumbnail]];
    [_publicSwitch setOn:[_droppedPin isFilePublic]];
    [_shareButton setEnabled:![_droppedPin isFilePublic]];
    if (![_droppedPin isFilePublic]) _shareButton.alpha = .7;
    CAGradientLayer *background = [CAGradientLayer layer];
    [background setFrame:self.view.frame];
    [background setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.964 green:0.955 blue:0.914 alpha:1.000]CGColor], (id)[[UIColor colorWithRed:0.964 green:0.959 blue:0.867 alpha:1.000]CGColor], nil]];
    [self.view.layer insertSublayer:background atIndex:0];
    [_deleteButton setColor:[UIColor colorWithRed:0.964 green:0.955 blue:0.914 alpha:1.000]];
    [_deleteButton addAwesomeIcon:FAIconRemove beforeTitle:YES];
    [_shareButton setColor:[UIColor colorWithRed:0.964 green:0.955 blue:0.914 alpha:1.000]];
    [_shareButton addAwesomeIcon:FAIconGroup beforeTitle:YES];
    [_viewButton setColor:[UIColor colorWithRed:0.964 green:0.955 blue:0.914 alpha:1.000]];
    [_viewButton addAwesomeIcon:FAIconFile beforeTitle:YES];
    [_publicSwitch setOnText:@"Public"];
    [_publicSwitch setOffText:@"Private"];
    [_publicSwitch setOnTintColor:[UIColor darkGrayColor]];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)viewFileButtonPressed:(id)sender {
    NSURL *fileURL;
    if([[_droppedPin url] length] > 1) {
        fileURL = [[NSURL alloc] initFileURLWithPath:[_droppedPin url] isDirectory:NO];
        PreviewController* previewController = [[PreviewController alloc] initWithItems:1 fileUrl:fileURL];
        [previewController setModalInPopover:YES];
        [previewController setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:previewController animated:YES completion:nil];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        PFObject *object = [query getObjectWithId:_droppedPin.object.objectId];
        [object fetchIfNeeded];
        PFFile *file = [object objectForKey:kParseFileKey];
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        HUD.mode = MBProgressHUDModeDeterminate;
        HUD.labelText = @"Retrieving...";
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* localPath = [documentsPath stringByAppendingPathComponent:file.name];
            [data writeToFile:localPath atomically:YES];
            [_droppedPin setUrl:localPath];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:localPath isDirectory:NO];
            PreviewController* previewController = [[PreviewController alloc] initWithItems:1 fileUrl:fileURL];
            [previewController setModalInPopover:YES];
            [previewController setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:previewController animated:YES completion:nil];
        } progressBlock:^(int percentDone) {
            HUD.progress = (float)percentDone/100;
            if(percentDone == 100) [HUD hide:YES];
        }];
    }
}

- (IBAction)deleteDropButtonPressed:(id)sender {
    [_mapView removeAnnotation:_droppedPin];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopoverNotification" object:nil];
    [_droppedPin deleteDrop];
}

- (IBAction)shareFileButtonPressed:(id)sender {
    if (![[NPReachability sharedInstance] isCurrentlyReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"In order to share a file an internet connection is necessary." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:kParseUserClassKey];
        
        //TODO: can I run a fetch in the background and still have an array to populalate the UITableView with?
        
        NSArray *objects = [query findObjects];
        
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (PFObject *object in objects) {
            if(![[object objectForKey:kParseUsernameKey] isEqualToString:[[PFUser currentUser] username]]) {
                if(![[object objectForKey:kParseUsernameKey] isEqualToString:@"public"]) {
                    [users addObject:[object objectForKey:kParseUsernameKey]];
                }
            }
        }
        UserPickerViewController *userPicker = [[UserPickerViewController alloc] initWithNibName:@"UserPickerViewController" bundle:nil andUsers:users forDrop:_droppedPin];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPicker];
        if (self.userSelectorPopoverController == nil) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            popover.delegate = self;
            self.userSelectorPopoverController = popover;
        } else {
            [_userSelectorPopoverController setContentViewController:navigationController animated:YES];
        }
        [_userSelectorPopoverController setPopoverBackgroundViewClass:[GIKPopoverBackgroundView class]];
        [_userSelectorPopoverController setPopoverContentSize:CGSizeMake(320, 250)];
        UIButton *button = sender;
        [_userSelectorPopoverController presentPopoverFromRect:button.frame inView:self.view.superview permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
    }
}

-(NSString *)fileExtension {
    if([[_droppedPin filename] length] > 3) {
        return [[_droppedPin filename] substringFromIndex:[[_droppedPin filename] length] - 3];
    } else {
        return nil;
    }
}

-(UIImage *)fileThumbnail {
    UIImage *thumbnail = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [self fileExtension]]];
    if (thumbnail) {
        return thumbnail;
    } else {
        return [UIImage imageNamed:[NSString stringWithFormat:@"blank"]];
    }
}

-(BOOL)shouldAllowDeleteAndShare {
    if ([[_droppedPin getUsername] isEqualToString:[[PFUser currentUser] username]]) {
        return true;
    } else {
        return false;
    }
}

-(void)dismissPopover {
    [_userSelectorPopoverController dismissPopoverAnimated:YES];
}

- (IBAction)publicSwitch:(id)sender {
    if ([_publicSwitch isOn]) {
        [_droppedPin makeFilePublic];
        [_shareButton setEnabled:NO];
        [_shareButton setAlpha:.7];
    } else {
        [_droppedPin makeFilePrivate];
        [_shareButton setEnabled:YES];
        [_shareButton setAlpha:1];
    }
}

@end
