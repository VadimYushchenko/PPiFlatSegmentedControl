//
//  PPiFlatSwitch.m
//  PPiFlatSwitch
//
//  Created by Pedro Piñera Buendía on 12/08/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "PPiFlatSegmentedControl.h"
#import "UIAwesomeButton.h"
#define segment_corner 5.0

@interface PPiFlatSegmentedControl()
@property (nonatomic,strong) NSMutableArray *segments;
@property (nonatomic,strong) NSMutableArray *separators;
@property (nonatomic,copy) selectionBlock selBlock;
@property (nonatomic) CGFloat iconSeparation;
@property (nonatomic) BOOL isFixedWidth;
@property (nonatomic, strong) NSMutableDictionary *specialTextAttribute;
@end

@implementation PPiFlatSegmentedControl

- (id)initWithFrame:(CGRect)frame items:(NSArray*)items iconPosition:(IconPosition)position andSelectionBlock:(selectionBlock)block{
    self = [super initWithFrame:frame];
    if (self) {
        //Selection block
        self.selBlock=block;
        
        //        _segmentPadding = 15;
        //Background Color
        self.backgroundColor=[UIColor clearColor];
        
        //Generating segments
        float buttonWith=round(self.frame.size.width / items.count);
        int i=0;
        for(NSDictionary *item in items){
            NSString *text=item[@"text"];
            NSString *icon=item[@"icon"];
            //            buttonWith +=15;
            
            UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(buttonWith*i, 0, buttonWith, self.frame.size.height) text:text icon:icon textAttributes:nil andIconPosition:position];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectIntegral(button.frame);
            button.center = roundedCenterPoint(button.center);
            
            button.titleLabel.frame = CGRectIntegral(button.titleLabel.frame);
            button.titleLabel.center = roundedCenterPoint(button.titleLabel.center);
            
            [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            //Adding to self view
            
            [self.segments addObject:button];
            [self addSubview:button];
            
            
            //Adding separator
            if(i!=0){
                UIView *separatorView=[[UIView alloc] initWithFrame:CGRectMake(i*buttonWith, 0, self.borderWidth, frame.size.height)];
                [self addSubview:separatorView];
                [self.separators addObject:separatorView];
            }
            
            i++;
        }
        
        //        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        
        //Applying corners
        self.layer.masksToBounds=YES;
        self.layer.cornerRadius=segment_corner;
        
        //Default selected 0
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        _currentSelected=[ud integerForKey:@"jow_theme"];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
              items:(NSArray*)items
       iconPosition:(IconPosition)position
  andSelectionBlock:(selectionBlock)block
     iconSeparation:(CGFloat)separation
{
    self = [super initWithFrame:frame];
    if (self) {
        //Selection block
        _selBlock=block;
        
         self.isFixedWidth = CGRectGetWidth(frame)>0;
        
        //Icon separation
        self.iconSeparation = separation;
        
        //Icon position
        self.iconPosition = position;
        
        self.padding = 10.f;
        
        //Adding items
        [self addItems:items withFrame:frame];
        
        //Background Color
        self.backgroundColor=[UIColor clearColor];
        
        //Applying corners
        self.layer.masksToBounds=YES;
        self.cornerRadius=segment_corner;
        
        //Default selected 0
        _currentSelected=-1;
    }
    return self;
}

- (void)addItems:(NSArray*)items withFrame:(CGRect)frame
{
    // Removing segments and separators
    for (UIView *separator in self.separators) {
        [separator removeFromSuperview];
    }
    [self.separators removeAllObjects];
    for (UIView *segment in self.segments) {
        [segment removeFromSuperview];
    }
    [self.segments removeAllObjects];
    
    //Generating segments
    float buttonWith=ceil(frame.size.width / items.count);
   
    int i=0;
    for(PPiFlatSegmentItem *item in items){
        NSString *text=item.title;
        NSObject *icon=item.icon;

        UIAwesomeButton  *button;
        if([icon isKindOfClass:[UIImage class]]) {
            button = [[UIAwesomeButton alloc] initWithFrame:CGRectMake(buttonWith*i, 0, buttonWith, frame.size.height) text:text iconImage:(UIImage *)icon attributes:@{} andIconPosition:self.iconPosition];
        }
        else {
            button = [[UIAwesomeButton alloc] initWithFrame:CGRectMake(buttonWith*i, 0, buttonWith, frame.size.height) text:text icon:(NSString *)icon attributes:@{} andIconPosition:self.iconPosition];
            [button setIcon:item.selectedIcon forUIControlState:UIControlStateSelected];
        }
        
        UIAwesomeButton __weak *wbutton = button;
        [button setActionBlock:^(UIAwesomeButton *button) {
            [self segmentSelected:wbutton];
        }];
        
        //Adding to self view
        [self.segments addObject:button];
        [self addSubview:button];
        
        //Adding separator
        if(i!=0){
            UIView *separatorView=[[UIView alloc] initWithFrame:CGRectMake(i*buttonWith, 0, self.borderWidth, frame.size.height)];
            [self addSubview:separatorView];
            [self.separators addObject:separatorView];
        }
        
        i++;
    }
    
    // Bringins separators to the front
    for (UIView* separator in self.separators) {
        [self bringSubviewToFront:separator];
    }
}


#pragma mark - Lazy instantiations

-(NSMutableArray*)segments
{
    if(!_segments)_segments=[[NSMutableArray alloc] init];
    return _segments;
}
-(NSMutableArray*)separators
{
    if(!_separators)_separators=[[NSMutableArray alloc] init];
    return _separators;
}


#pragma mark - Actions

-(void)segmentSelected:(UIControl *)sender
{
//    sender.selected = !sender.selected;
    
    if(sender) {
        NSUInteger selectedIndex=[self.segments indexOfObject:sender];
        [self setSelected:YES segmentAtIndex:selectedIndex];
        if(self.selBlock) {
            self.selBlock(selectedIndex);
        }
    }
}


#pragma mark - Getters

-(BOOL)isSelectedSegmentAtIndex:(NSUInteger)index
{
    return (index==self.currentSelected);
}

- (NSUInteger)numberOfSegments
{
    return self.segments.count;
}


#pragma mark - Setters

- (void)setSegmentAtIndex:(NSUInteger)index enabled:(BOOL)enabled
{
    if (index >= self.segments.count) return;
    UIButton *button = self.segments[index];
    [button setEnabled:enabled];
    [button setUserInteractionEnabled:enabled];
}

-(void)updateSegmentsFormat
{
    //Setting border color
    if (self.borderColor) {
        self.layer.borderWidth=self.borderWidth;
        self.layer.borderColor=self.borderColor.CGColor;
    }
    else {
        self.layer.borderWidth=0;
    }
    
    if (self.isFixedWidth) {
        

    //Updating segments color
    for (UIView *separator in self.separators) {
        separator.backgroundColor=self.borderColor;
        separator.frame=CGRectMake(separator.frame.origin.x, separator.frame.origin.y,self.borderWidth , separator.frame.size.height);
    }
    }
    int i = 0;
    CGFloat width = 0;
    //Modifying buttons with current State
    for (UIAwesomeButton *segment in self.segments)
    {
        //Setting icon Position
        if (self.iconPosition)
            [segment setIconPosition:self.iconPosition];
        
        //Set text aligment
        [segment setTextAlignment:NSTextAlignmentCenter];
        
        //Setting icon separation
        [segment setSeparation:self.iconSeparation];
        

        
        //Setting format depending on if it's selected or not
        if([self.segments indexOfObject:segment]==self.currentSelected){
            //Selected-one
            if(self.selectedColor)[segment setBackgroundColor:self.selectedColor forUIControlState:UIControlStateNormal];
            if(self.selectedTextAttributes)
                [segment setAttributes:self.selectedTextAttributes forUIControlState:UIControlStateNormal];
        }
        else{
            //Non selected
            if(self.color)[segment setBackgroundColor:self.color forUIControlState:UIControlStateNormal];
            
            NSDictionary *specialAttribute = self.specialTextAttribute[@(i)];
            
            if (specialAttribute) {
                [segment setAttributes:specialAttribute forUIControlState:UIControlStateNormal];
            } else
            
            if(self.textAttributes){
           
                [segment setAttributes:self.textAttributes forUIControlState:UIControlStateNormal];

            }
        }
        if (!self.isFixedWidth) {
            
        
        if(i!=0){
            UIView *separator = [self.separators objectAtIndex:i-1];
            separator.backgroundColor=self.borderColor;
            
            separator.frame=CGRectMake(width, separator.frame.origin.y,self.borderWidth , separator.frame.size.height);
        }

     CGRect titleRect = [segment.getButtonText boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:self.textAttributes context:nil];
        
        CGRect iconRect = [segment.getIcon boundingRectWithSize:CGSizeMake(17, 17) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:nil context:nil];
        
        CGRect frame = segment.frame;
        frame.origin.x = width;
        frame.size.width = titleRect.size.width+iconRect.size.width+2*self.borderWidth+ 2*self.padding;
        segment.frame = frame;
        
        width += frame.size.width;
        
        i++;
        }
    }
    if (!self.isFixedWidth) {

    UIAwesomeButton *segment = [self.segments lastObject];
    
    CGRect contentFrame = self.frame;
    contentFrame.size.width = CGRectGetMaxX(segment.frame);
    self.frame = contentFrame;
    }
}

- (void)setItems:(NSArray*)items
{
    [self addItems:items withFrame:self.frame];
    [self updateSegmentsFormat];
}

-(void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor=selectedColor;
    [self updateSegmentsFormat];
}

-(void)setColor:(UIColor *)color
{
    _color=color;
    [self updateSegmentsFormat];
}

-(void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth=borderWidth;
    [self updateSegmentsFormat];
}

-(void)setIconPosition:(IconPosition)iconPosition
{
    _iconPosition=iconPosition;
    [self updateSegmentsFormat];
}

-(void)setTitle:(id)title forSegmentAtIndex:(NSUInteger)index
{
    //Getting the Segment
    if(index<self.segments.count) {
        UIAwesomeButton *segment=self.segments[index];
        if([title isKindOfClass:[NSString class]]){
            [segment setButtonText:title];
            [self updateSegmentsFormat];
        }
    }
}
-(void)setBorderColor:(UIColor *)borderColor{
    //Setting boerder color to all view
    _borderColor=borderColor;
    [self updateSegmentsFormat];
}

-(void)setSelected:(BOOL)selected segmentAtIndex:(NSUInteger)segment{
    
    int i = 0;
    for (UIAwesomeButton *button in self.segments) {
        if (segment == i) {
            button.selected = YES;
        }else {
            button.selected = NO;
        }
        i++;
    }
    
    if (selected) {
        self.currentSelected=segment;
        [self updateSegmentsFormat];
    }
}

-(void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment{
    [self setSelected:enabled segmentAtIndex:segment];
}

-(void)setTextAttributes:(NSDictionary *)textAttributes atIndex:(NSInteger)index{
    if (index > self.segments.count) {
        return;
    }
    
    if (!self.specialTextAttribute) {
        self.specialTextAttribute = [NSMutableDictionary dictionaryWithCapacity:self.segments.count];
    }
    if (!textAttributes) {
        [self.specialTextAttribute removeObjectForKey:@(index)];
    }else {
        self.specialTextAttribute[@(index)] = textAttributes;
    }
    [self updateSegmentsFormat];
}

-(void)setTextAttributes:(NSDictionary *)textAttributes
{
    _textAttributes=textAttributes;
    [self updateSegmentsFormat];
}

-(void)setSelectedTextAttributes:(NSDictionary *)selectedTextAttributes
{
    _selectedTextAttributes=selectedTextAttributes;
    [self updateSegmentsFormat];
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        self.layer.cornerRadius = cornerRadius;
    }
    
}

-(void)setPadding:(CGFloat)padding{
    if (_padding != padding) {
        _padding = padding;
        [self updateSegmentsFormat];
    }
}

CGPoint roundedCenterPoint(CGPoint pt) {
    return CGPointMake(round(pt.x), round(pt.y));
}

-(UIAwesomeButton *)itemAtIndex:(NSInteger)index{
    if (index > self.segments.count) {
        return nil;
    }
    UIAwesomeButton *button = self.segments[index];
    return button;
}

-(CGRect)frameItemAtIndex:(NSInteger)index{
    if (index > self.segments.count) {
        return CGRectZero;
    }
    
    UIAwesomeButton *button = [self itemAtIndex:index];
    return button.frame;
}
@end

