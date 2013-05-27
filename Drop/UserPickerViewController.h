//
//  UserPickerViewController.h
//  UserPicker
//
//  Created by Kyle Plattner on 5/27/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserPickerView.h"
#import "Drop.h"

@interface UserPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UserPickerDelegate>

@property (nonatomic, strong) UserPickerView *userPickerView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSArray *filteredUsers;
@property (nonatomic, retain) Drop *drop;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUsers:(NSArray *)users forDrop:(Drop *)drop;

@end
