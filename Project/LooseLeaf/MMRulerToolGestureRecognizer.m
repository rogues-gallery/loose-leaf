//
//  MMRulerToolGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMRulerToolGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "MMBezelInRightGestureRecognizer.h"
#import "MMBezelInLeftGestureRecognizer.h"
#import "MMObjectSelectLongPressGestureRecognizer.h"
#import "NSMutableSet+Extras.h"
#import "NSArray+MapReduce.h"
#import "MMShadowedView.h"
#import <JotUI/JotUI.h>

@implementation MMRulerToolGestureRecognizer

@synthesize scale;
@synthesize initialDistance;

NSUInteger const minimumNumberOfRulerTouches = 2;


-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        self.cancelsTouchesInView = NO;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[MMBezelInRightGestureRecognizer class]] ||
           [preventingGestureRecognizer isKindOfClass:[MMBezelInLeftGestureRecognizer class]];
}

-(NSArray*)touches{
    return [validTouches array];
}

-(BOOL) containsTouch:(UITouch*)touch{
    return [validTouches containsObject:touch];
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyBeginning = [NSMutableOrderedSet orderedSetWithSet:touches];
    if(self.state != UIGestureRecognizerStatePossible &&
       [validTouches count] == minimumNumberOfRulerTouches){
        //
        // if we're already pinching
        [touches enumerateObjectsUsingBlock:^(id obj, BOOL* stop){
            [self ignoreTouch:obj forEvent:event];
        }];
        return;
    }
    // ignore all the touches that could be bezel touches
    if([validTouchesCurrentlyBeginning count]){
        [validTouches addObjectsFromArray:[validTouchesCurrentlyBeginning array]];
        if(([validTouches count] >= minimumNumberOfRulerTouches)){
            if(self.state == UIGestureRecognizerStatePossible){
                initialDistance = [self distanceBetweenTouches:validTouches];
                self.state = UIGestureRecognizerStateBegan;
            }
        }
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyMoving = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyMoving intersectSet:touches];
    if([validTouchesCurrentlyMoving count]){
        if(self.state == UIGestureRecognizerStateBegan ||
           self.state == UIGestureRecognizerStateChanged){
            if(self.state == UIGestureRecognizerStateBegan){
                initialDistance = 0;
            }
            if(self.numberOfTouches == 1){
                initialDistance = 0;
            }
            if([validTouches count] >= 2 && !initialDistance){
                initialDistance = [self distanceBetweenTouches:validTouches];
            }
            self.state = UIGestureRecognizerStateChanged;
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // pan and pinch and bezel
    NSMutableOrderedSet* validTouchesCurrentlyEnding = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyEnding intersectSet:touches];
    
    if(self.state == UIGestureRecognizerStateBegan ||
       self.state == UIGestureRecognizerStateChanged){
        //
        // make sure we've actually seen two fingers on the page
        // before we change state or worry about bezeling
        if([validTouches count] <= 1 && self.state == UIGestureRecognizerStateChanged){
            // only 1 finger during this gesture, and it's exited
            // so it doesn't count for bezeling or pan/pinch
            self.state = UIGestureRecognizerStateFailed;
        }else{
            self.state = UIGestureRecognizerStateEnded;
        }
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
    [validTouches minusOrderedSet:validTouchesCurrentlyEnding];
    [ignoredTouches removeObjectsInSet:touches];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableOrderedSet* validTouchesCurrentlyCancelling = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    [validTouchesCurrentlyCancelling intersectSet:touches];
    if([validTouchesCurrentlyCancelling count]){
        if(self.numberOfTouches == 1 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStatePossible;
        }else if([validTouches count] == 0 && self.state == UIGestureRecognizerStateChanged){
            self.state = UIGestureRecognizerStateCancelled;
        }
        [validTouches minusOrderedSet:validTouchesCurrentlyCancelling];
        [ignoredTouches removeObjectsInSet:touches];
    }
}
-(void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    [ignoredTouches addObject:touch];
    [super ignoreTouch:touch forEvent:event];
}
- (void)reset{
    [super reset];
    initialDistance = 0;
    scale = 1;
    [validTouches removeAllObjects];
    [ignoredTouches removeAllObjects];
}

-(void) cancel{
    if(self.enabled){
        self.enabled = NO;
        self.enabled = YES;
    }
}


#pragma mark - Public Interface

/**
 * return the two locations of the ruler in
 * the input view
 */
-(CGPoint) point1InView:(UIView*)view{
    return [[validTouches firstObject] locationInView:view];
}

-(CGPoint) point2InView:(UIView*)view{
    return [[validTouches lastObject] locationInView:view];
}


#pragma mark - Private Helpers


-(CGFloat) distanceBetweenTouches:(NSOrderedSet*) touches{
    if([touches count] >= 2){
        UITouch* touch1 = [touches objectAtIndex:0];
        UITouch* touch2 = [touches objectAtIndex:1];
        CGPoint initialPoint1 = [touch1 locationInView:self.view.superview];
        CGPoint initialPoint2 = [touch2 locationInView:self.view.superview];
        return DistanceBetweenTwoPoints(initialPoint1, initialPoint2);
    }
    return 0;
}

@end
