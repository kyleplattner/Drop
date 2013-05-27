//
//  UserPickerTextView.h
//  UserPicker
//
//  Created by Kyle Plattner on 5/27/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBubble.h"

@class UserPickerView;

@protocol UserPickerDelegate <NSObject>

- (void)userPickerTextViewDidChange:(NSString *)textViewText;
- (void)userPickerDidRemoveUser:(id)user;
- (void)userPickerDidResize:(UserPickerView *)userPickerView;

@end

@interface UserPickerView : UIView <UITextViewDelegate, UserBubbleDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UserBubble *selectedUserBubble;
@property (nonatomic, assign) IBOutlet id <UserPickerDelegate> delegate;
@property (nonatomic, assign) BOOL limitToOne;
@property (nonatomic, assign) CGFloat viewPadding;
@property (nonatomic, strong) UIFont *font;

- (void)addUser:(id)user withName:(NSString *)name;
- (void)removeUser:(id)user;
- (void)removeAllUsers;
- (void)setPlaceholderString:(NSString *)placeholderString;
- (void)disableDropShadow;
- (void)resignKeyboard;
- (void)setBubbleColor:(UserBubbleColor *)color selectedColor:(UserBubbleColor *)selectedColor;
    
@end
