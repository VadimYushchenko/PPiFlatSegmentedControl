//
//  PPiFlatSegmentedControl.h
//  PPiFlatSegmentedControl
//
//  Created by Pedro Piñera Buendía on 12/08/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIAwesomeButton.h"
#import "PPiFlatSegmentItem.h"

typedef void(^selectionBlock)(NSUInteger segmentIndex);


@interface PPiFlatSegmentedControl : UIControl

@property (nonatomic,strong) UIColor *selectedColor;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic,strong) UIFont *textFont;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic,strong) NSDictionary *textAttributes;
@property (nonatomic,strong) NSDictionary *selectedTextAttributes;
@property (nonatomic)  IconPosition iconPosition;
@property (nonatomic,readonly) NSUInteger numberOfSegments;
@property (nonatomic) CGFloat padding;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) NSUInteger currentSelected;

- (id)initWithFrame:(CGRect)frame items:(NSArray*)items iconPosition:(IconPosition)position andSelectionBlock:(selectionBlock)block;

- (id)initWithFrame:(CGRect)frame
              items:(NSArray*)items
       iconPosition:(IconPosition)position
  andSelectionBlock:(selectionBlock)block
     iconSeparation:(CGFloat)separation;
- (void)setItems:(NSArray*)items;
- (void)setSelected:(BOOL)selected segmentAtIndex:(NSUInteger)segment;
- (BOOL)isSelectedSegmentAtIndex:(NSUInteger)index;
- (void)setTitle:(id)title forSegmentAtIndex:(NSUInteger)index;
- (void)setSelectedTextAttributes:(NSDictionary*)attributes;
- (void)setSegmentAtIndex:(NSUInteger)index enabled:(BOOL)enabled;
- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;
-(UIAwesomeButton *)itemAtIndex:(NSInteger)index;
-(CGRect)frameItemAtIndex:(NSInteger)index;
-(void)setTextAttributes:(NSDictionary *)textAttributes atIndex:(NSInteger)index;
@end
