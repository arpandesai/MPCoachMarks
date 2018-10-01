//
//  MPCoachMarks.m
//  Example
//
//  Created by marcelo.perretta@gmail.com on 7/8/15.
//  Copyright (c) 2015 MAWAPE. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MPCoachMarks.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 5.0f;
static const CGFloat kMaxLblWidth = 230.0f;
static const CGFloat kLblSpacing = 100.0f;
static const CGFloat kLabelMargin = 5.0f;
static const CGFloat kMaskAlpha = 0.75f;
static const BOOL kEnableContinueLabel = YES;
static const BOOL kEnableSkipButton = YES;
static const BOOL kEnableNextButton = YES;
NSString *const kSkipButtonText = @"Skip";
NSString *const kNextButtonText = @"Next";
NSString *const kContinueLabelText = @"Tap to continue";

@interface MPCoachMarks()
#ifdef __IPHONE_11_0
-(UIEdgeInsets)getSafeAreaInsets;
#endif
    @end

@implementation MPCoachMarks {
    CAShapeLayer *mask;
    NSUInteger markIndex;
    UIView *currentView;
    CGFloat btnNextWidth;
    CGFloat btnSkipWidth;
}
    
#pragma mark - Properties
    
    @synthesize delegate;
    @synthesize coachMarks;
    @synthesize lblCaption;
    @synthesize lblDescription;
    @synthesize lblContinue;
    @synthesize btnSkipCoach;
    @synthesize btnNextCoach;
    @synthesize maskColor = _maskColor;
    @synthesize animationDuration;
    @synthesize cutoutRadius;
    @synthesize maxLblWidth;
    @synthesize lblSpacing;
    @synthesize enableContinueLabel;
    @synthesize enableSkipButton;
    @synthesize enableNextButton;
    @synthesize continueLabelText;
    @synthesize skipButtonText;
    @synthesize nextButtonText;
    @synthesize arrowImage;
    @synthesize continueLocation;
    
#pragma mark - Methods
    
- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks {
    self = [super initWithFrame:frame];
    if (self) {
        // Save the coach marks
        self.coachMarks = marks;
        
        // Setup
        [self setup];
    }
    return self;
}
    
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}
    
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}
    
- (void)setup {
    // Default
    
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    self.maxLblWidth = kMaxLblWidth;
    self.lblSpacing = kLblSpacing;
    self.enableContinueLabel = kEnableContinueLabel;
    self.enableSkipButton = kEnableSkipButton;
    self.enableNextButton = kEnableNextButton;
    self.continueLabelText = kContinueLabelText;
    self.skipButtonText = kSkipButtonText;
    
    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:kMaskAlpha] CGColor]];
    [self.layer addSublayer:mask];
    
    // Captions
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.frame.size.width - 20, self.frame.size.height /2}}];
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.font = [UIFont fontWithName:@"Gotham-Medium" size:18.0f];
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.textAlignment = NSTextAlignmentLeft;
    self.lblCaption.alpha = 0.0f;
    [self addSubview:self.lblCaption];
    
    // Description
    self.lblDescription = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.frame.size.width - 30, self.frame.size.width /2}}];
    self.lblDescription.backgroundColor = [UIColor clearColor];
    self.lblDescription.textColor = [UIColor whiteColor];
    self.lblDescription.font = [UIFont fontWithName:@"Gotham-Book" size:15.0f];
    self.lblDescription.numberOfLines = 0;
    self.lblDescription.textAlignment = NSTextAlignmentLeft;
    self.lblDescription.alpha = 0.0f;
    self.lblDescription.minimumScaleFactor = 0.7;
    self.lblDescription.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.lblDescription];
    //Location Position
    self.continueLocation = LOCATION_BOTTOM;
    
    // Hide until unvoked
    self.hidden = YES;
}
    
#pragma mark - Cutout modify
    
- (void)setCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
    cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
    cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
    cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    mask.path = maskPath.CGPath;
}
    
- (void)animateCutoutToRect:(CGRect)rect withShape:(MaskShape)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
    cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
    cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
    cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}
    
#pragma mark - Mask color
    
- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [mask setFillColor:[maskColor CGColor]];
}
    
#pragma mark - Touch handler
    
- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    // Go to the next coach mark
    [self goToCoachMarkIndexed:(markIndex+1)];
}
    
#pragma mark - Navigation
    
- (void)start {
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
                     }];
}
    
- (void)skipCoach {
    [self goToCoachMarkIndexed:self.coachMarks.count];
}
    
- (void)nextCoach {
    
    [self goToCoachMarkIndexed:(markIndex+1)];
    
}
    
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate coachMarksViewDidClicked:self atIndex:markIndex];
    [self cleanup];
}
    
- (UIImage*)fetchImage:(NSString*)name {
    // Check for iOS 8
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:name];
    }
}
    
- (void)goToCoachMarkIndexed:(NSUInteger)index {
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }
    
    // Current index
    markIndex = index;
    
    if (markIndex == 3){
        enableSkipButton = FALSE;
        [btnSkipCoach removeFromSuperview];
    }
    
    // Coach mark definition
    NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
    NSString *markCaption = [markDef objectForKey:@"caption"];
    NSString *markDescription = [markDef objectForKey:@"description"];
    NSString *markButtonName = [markDef objectForKey:@"buttonName"];
    nextButtonText = markButtonName;
    
    CGRect markRect = [[markDef objectForKey:@"rect"] CGRectValue];
    
    MaskShape shape = DEFAULT;
    if([[markDef allKeys] containsObject:@"shape"])
    shape = [[markDef objectForKey:@"shape"] integerValue];
    
    LabelPosition labelPosition = [[markDef objectForKey:@"position"] integerValue];
    if([markDef objectForKey:@"cutoutRadius"]) {
        self.cutoutRadius = [[markDef objectForKey:@"cutoutRadius"] floatValue];
    } else {
        self.cutoutRadius = kCutoutRadius;
    }
    
    if ([self.delegate respondsToSelector:@selector(coachMarksViewDidClicked:atIndex:)]) {
        [currentView removeFromSuperview];
        currentView = [[UIView alloc] initWithFrame:markRect];
        currentView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [currentView addGestureRecognizer:singleFingerTap];
        [self addSubview:currentView];
    }
    
    [self.arrowImage removeFromSuperview];
    BOOL showArrow = NO;
    if( [markDef objectForKey:@"showArrow"])
    showArrow = [[markDef objectForKey:@"showArrow"] boolValue];
    
    
    // Calculate the caption position and size
    self.lblCaption.alpha = 0.0f;
    self.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {self.frame.size.width - 20, self.frame.size.height /2}};
    self.lblCaption.text = markCaption;
    [self.lblCaption sizeToFit];
    
    // Calculate the Description position and size
    self.lblDescription.alpha = 0.0f;
    self.lblDescription.frame = (CGRect){{0.0, 0.0f}, {self.frame.size.width - 20, self.frame.size.width /5}};
    self.lblDescription.text = markDescription;
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:markDescription];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = 20.0;
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, markDescription.length)];
    lblDescription.attributedText = attrString;
    
    CGSize expectedLabelSize = [markDescription sizeWithFont:lblDescription.font
                                           constrainedToSize:lblDescription.frame.size
                                               lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect newFrame = lblDescription.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width = expectedLabelSize.width;
    lblDescription.frame = newFrame;
    lblDescription.numberOfLines = 0;
    [lblDescription sizeToFit];
    
    CGFloat y;
    CGFloat x;
    
    CGFloat y1;
    CGFloat x1;
    
    x = self.frame.origin.x + 15;
    x1 = self.frame.origin.x + 15;
    
    switch (labelPosition) {
        case LABEL_POSITION_TOP:
        {
            y = markRect.origin.y - self.lblCaption.frame.size.height - kLabelMargin;
            y1 = markRect.origin.y - self.lblDescription.frame.size.height - kLabelMargin;
            
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-down"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = x;
                imageViewFrame.origin.y = y;
                self.arrowImage.frame = imageViewFrame;
                y -= (self.arrowImage.frame.size.height + kLabelMargin);
                [self addSubview:self.arrowImage];
            }
        }
        break;
        case LABEL_POSITION_LEFT:
        {
            y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
            y1 = markRect.origin.y + markRect.size.height/2 - self.lblDescription.frame.size.height/2;
            
            x = self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin - markRect.size.width;
            x1 = self.bounds.size.width - self.lblDescription.frame.size.width - kLabelMargin - markRect.size.width;
            
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-right"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = self.bounds.size.width - self.arrowImage.frame.size.width - kLabelMargin - markRect.size.width;
                imageViewFrame.origin.y = y + self.lblCaption.frame.size.height/2 - imageViewFrame.size.height/2;
                self.arrowImage.frame = imageViewFrame;
                x -= (self.arrowImage.frame.size.width + kLabelMargin);
                [self addSubview:self.arrowImage];
            }
        }
        break;
        case LABEL_POSITION_RIGHT:
        {
            y = markRect.origin.y + markRect.size.height/2 - self.lblCaption.frame.size.height/2;
            y1 = markRect.origin.y + markRect.size.height/2 - self.lblDescription.frame.size.height/2;
            
            x = markRect.origin.x + markRect.size.width + kLabelMargin;
            x1 = markRect.origin.x + markRect.size.width + kLabelMargin;
            
            if(showArrow) {
                
            }
        }
        break;
        case LABEL_POSITION_RIGHT_BOTTOM:
        {
            y = markRect.origin.y + markRect.size.height + self.lblSpacing;
            
            CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
            if (bottomY > self.bounds.size.height) {
                y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
            }
            x = markRect.origin.x + markRect.size.width + kLabelMargin;
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-top"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = x - markRect.size.width/2 - imageViewFrame.size.width/2;
                imageViewFrame.origin.y = y - kLabelMargin; //self.lblCaption.frame.size.height/2
                y += imageViewFrame.size.height/2;
                self.arrowImage.frame = imageViewFrame;
                [self addSubview:self.arrowImage];
            }
        }
        break;
        default: {
            //changes
            y = markRect.origin.y - markRect.size.height - self.lblSpacing;
            y1 = markRect.origin.y + 20 - markRect.size.height - self.lblSpacing;
            
            CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
            if (bottomY > self.bounds.size.height) {
                y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
                y1 = markRect.origin.y - self.lblSpacing - self.lblDescription.frame.size.height;
            }
            if(showArrow) {
                self.arrowImage = [[UIImageView alloc] initWithImage:[self fetchImage:@"arrow-top"]];
                CGRect imageViewFrame = self.arrowImage.frame;
                imageViewFrame.origin.x = x;
                imageViewFrame.origin.y = y;
                self.arrowImage.frame = imageViewFrame;
                y += (self.arrowImage.frame.size.height + kLabelMargin);
                [self addSubview:self.arrowImage];
            }
        }
        break;
    }
    
    // Animate the caption label
    self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
    self.lblDescription.frame = (CGRect){{x1, y1}, self.lblDescription.frame.size};
    
    [UIView animateWithDuration:0.3f animations:^{
        self.lblCaption.alpha = 1.0f;
        self.lblDescription.alpha = 1.0f;
        
    }];
    
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:markIndex];
    }
    
    // If first mark, set the cutout to the center of first mark
    if (markIndex == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero withShape:shape];
    }
    
    // Animate the cutout
    [self animateCutoutToRect:markRect withShape:shape];
    
    btnNextWidth = self.enableSkipButton ? (70.0/100.0) * self.bounds.size.width : self.bounds.size.width;
    btnSkipWidth = self.bounds.size.width - btnNextWidth;
    UIColor *btnTextColor = [UIColor colorWithRed:22.0f/255.0f green:164.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
    
    if (self.enableSkipButton) {
        if ([[self subviews] containsObject:btnSkipCoach])
        {
            return;
        }
        btnSkipCoach = [[UIButton alloc] initWithFrame:(CGRect){{15, [self yOriginForContinueLabel]}, {btnSkipWidth - 5, 40.0f}}];
        [btnSkipCoach addTarget:self action:@selector(skipCoach) forControlEvents:UIControlEventTouchUpInside];
        [btnSkipCoach setTitle:self.skipButtonText forState:UIControlStateNormal];
        btnSkipCoach.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.0f];
        btnSkipCoach.backgroundColor = [UIColor clearColor];
        [btnSkipCoach setTitleColor:btnTextColor forState:UIControlStateNormal];
        btnSkipCoach.alpha = 0.0f;
        btnSkipCoach.tintColor = [UIColor whiteColor];
        
        [self addSubview:btnSkipCoach];
        [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
            btnSkipCoach.alpha = 1.0f;
        } completion:nil];
    }
    
    if (self.enableNextButton) {
        
        if([[self subviews] containsObject:btnNextCoach]){
            if (markIndex == 3){
                btnNextCoach.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:14.0f];
            }
            [btnNextCoach setTitle:self.nextButtonText forState:UIControlStateNormal];
            return;
        }
        
        btnNextCoach = [[UIButton alloc] initWithFrame:(CGRect){{btnNextWidth - 10, [self yOriginForContinueLabel]}, {btnSkipWidth - 5, 40.0f}}];
        [btnNextCoach addTarget:self action:@selector(nextCoach) forControlEvents:UIControlEventTouchUpInside];
        [btnNextCoach setTitle:self.nextButtonText forState:UIControlStateNormal];
        btnNextCoach.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.0f];
        btnNextCoach.alpha = 0.0f;
        btnNextCoach.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:164.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
        btnNextCoach.tintColor = [UIColor whiteColor];
        btnNextCoach.titleLabel.adjustsFontSizeToFitWidth = YES;
        btnNextCoach.titleLabel.lineBreakMode = NSLineBreakByClipping;
        btnNextCoach.layer.cornerRadius = 8.0f;
        [self addSubview:btnNextCoach];
        [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
            btnNextCoach.alpha = 1.0f;
        } completion:nil];
    }
}
    
- (CGFloat)yOriginForContinueLabel {
    float leftOffset = 20.0f;
    float rightOffset = 20.0f;
    float topOffset = 20.0f;
    float bottomOffset = 100.0f;
    
#ifdef __IPHONE_11_0
    UIEdgeInsets safeInsets = [self getSafeAreaInsets];
    rightOffset += safeInsets.right;
    leftOffset += safeInsets.left;
    topOffset += safeInsets.top;
    bottomOffset += safeInsets.bottom;
#endif
    
    switch (self.continueLocation) {
        case LOCATION_TOP:
        return topOffset;
        case LOCATION_CENTER:
        return self.bounds.size.height / 2 - 15.0f;
        default:
        return bottomOffset ;
    }
}
    
#ifdef __IPHONE_11_0
-(UIEdgeInsets)getSafeAreaInsets {
    UIEdgeInsets safeInsets = { .top = 0, .bottom = 0, .left = 0, .right = 0 };
    SEL selector = @selector(safeAreaInsets);
    if ([self respondsToSelector:selector])
    {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        invocation.selector = selector;
        invocation.target = self;
        [invocation invoke];
        
        [invocation getReturnValue:&safeInsets];
    }
    return safeInsets;
}
#endif
    
#pragma mark - Cleanup
    
- (void)cleanup {
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }
    
    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];
                         
                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
                         }
                     }];
}
    
#pragma mark - Animation delegate
    
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:markIndex];
    }
}
    
    @end
