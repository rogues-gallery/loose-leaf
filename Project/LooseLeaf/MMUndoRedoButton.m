//
//  MMUndoRedoButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


@implementation MMUndoRedoButton

@synthesize reverseArrow;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}


- (void)setReverseArrow:(BOOL)_reverseArrow {
    reverseArrow = _reverseArrow;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, smallest - 2 * kWidthOfSidebarButtonBuffer, smallest - 2 * kWidthOfSidebarButtonBuffer);

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* barelyWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    UIColor* halfGreyFill = [self backgroundColor];

    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    if (reverseArrow) {
        [barelyWhite setFill];
    } else {
        [halfGreyFill setFill];
    }
    [ovalPath fill];

    [MMUndoRedoButton drawArrowInRect:frame reversed:reverseArrow withColor:darkerGreyBorder];

    [super drawRect:rect];
}

+ (UIImage*)undoIconWithColor:(UIColor*)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36, 40), NO, 0);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -2, 3);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 18, 18);
    CGContextRotateCTM(UIGraphicsGetCurrentContext(), M_PI);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -18, -18);

    [MMUndoRedoButton drawArrowInRect:CGRectMake(0, 0, 40, 40) reversed:YES withColor:color];
    UIImage* undoImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return undoImg;
}

+ (void)drawArrowInRect:(CGRect)frame reversed:(BOOL)reverseArrow withColor:(UIColor*)strokeColor {
    UIColor* halfGreyFill = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:0.5];
    UIColor* barelyWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];

    [strokeColor setStroke];

    //// Arrow Drawing
    UIBezierPath* arrowPath = [UIBezierPath bezierPath];
    if (reverseArrow) {
        [arrowPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 20, CGRectGetMinY(frame) + 12.99)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 32, CGRectGetMinY(frame) + 12.49)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 33, CGRectGetMinY(frame) + 25.49)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 21.99)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 27.49) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 21.99) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 24.72, CGRectGetMinY(frame) + 27.8)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 11.49) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 7.26, CGRectGetMinY(frame) + 26.76) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 5.89, CGRectGetMinY(frame) + 11.65)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 12, CGRectGetMinY(frame) + 18.49) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 7.11, CGRectGetMinY(frame) + 11.34) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 9.11, CGRectGetMinY(frame) + 16.43)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 20.49) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 15.25, CGRectGetMinY(frame) + 20.81) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 17.78, CGRectGetMinY(frame) + 20.88)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 24, CGRectGetMinY(frame) + 16.99) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 21.22, CGRectGetMinY(frame) + 20.11) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 24, CGRectGetMinY(frame) + 16.99)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 20, CGRectGetMinY(frame) + 12.99)];
    } else {
        [arrowPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 20, CGRectGetMinY(frame) + 26)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 32, CGRectGetMinY(frame) + 26.5)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 33, CGRectGetMinY(frame) + 13.5)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 17)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 11.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 17) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 24.72, CGRectGetMinY(frame) + 11.19)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 27.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 7.26, CGRectGetMinY(frame) + 12.23) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 5.89, CGRectGetMinY(frame) + 27.35)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 12, CGRectGetMinY(frame) + 20.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 7.11, CGRectGetMinY(frame) + 27.65) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 9.11, CGRectGetMinY(frame) + 22.56)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 18.5) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 15.25, CGRectGetMinY(frame) + 18.18) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 17.78, CGRectGetMinY(frame) + 18.11)];
        [arrowPath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 24, CGRectGetMinY(frame) + 22) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 21.22, CGRectGetMinY(frame) + 18.89) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 24, CGRectGetMinY(frame) + 22)];
        [arrowPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 20, CGRectGetMinY(frame) + 26)];
    }
    [arrowPath closePath];
    arrowPath.lineCapStyle = kCGLineCapRound;

    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    // clear the arrow and box, then fill with
    // border color
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [arrowPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    if (reverseArrow) {
        [halfGreyFill setFill];
        [arrowPath fill];
        [arrowPath stroke];
    } else {
        [barelyWhite setFill];
        [arrowPath fill];
        [arrowPath stroke];
    }
}


- (void)setTransform:(CGAffineTransform)transform {
    if (reverseArrow) {
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(M_PI));
    }
    [super setTransform:transform];
}

- (CGFloat)rotation {
    if (reverseArrow) {
        return [super rotation] + M_PI;
    }
    return [super rotation];
}


@end
