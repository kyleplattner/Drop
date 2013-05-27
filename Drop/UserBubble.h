//
//  UserBubble.h
//  UserPicker
//
//  Created by Kyle Plattner on 5/27/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UserBubbleColor.h"

@class UserBubble;

@protocol UserBubbleDelegate <NSObject>

- (void)userBubbleWasSelected:(UserBubble *)userBubble;
- (void)userBubbleWasUnSelected:(UserBubble *)userBubble;
- (void)userBubbleShouldBeRemoved:(UserBubble *)userBubble;

@end

@interface UserBubble : UIView <UITextViewDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView; 
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) id <UserBubbleDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UserBubbleColor *color;
@property (nonatomic, strong) UserBubbleColor *selectedColor;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name color:(UserBubbleColor *)color selectedColor:(UserBubbleColor *)selectedColor;
- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;

@end
