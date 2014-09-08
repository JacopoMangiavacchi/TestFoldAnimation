//
//  FoldView.m
//  TestTendina
//
//  Created by Jacopo Mangiavacchi on 08/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoldView.h"

@implementation FoldView

@synthesize isOpen, numFold, animationDuration, mediaTimingFunction;

- (void)myInitialize {
    self.hidden = TRUE;
    isOpen = FALSE;
    numFold = DEFAULT_NUM_FOLD;
    animationDuration = DEFAULT_ANIMATION_DURATION;
    isAnimating = FALSE;
    mediaTimingFunction = kCAMediaTimingFunctionEaseInEaseOut;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self myInitialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self myInitialize];
    }
    return self;
}

//- (void) awakeFromNib
//{
//}



- (void)open:(BOOL)animated {
    if (!isOpen) {
        if (animated) {
            if (!isAnimating) {
                isAnimating = TRUE;
                
                //CREATE IMAGE COPY OF FULL (self) VIEW
                UIGraphicsBeginImageContext(self.bounds.size);
                self.layer.hidden = FALSE;
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                self.layer.hidden = TRUE;
                UIImage *imageCapture = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                //CREATE FOLD VIEW HEIGTH and WIDTH
                float foldViewX = self.frame.origin.x;
                float foldViewY = self.frame.origin.y;
                float foldViewWidth = self.frame.size.width;
                float foldViewHeight = self.frame.size.height / numFold;
                
                //PREPARE ANCHORPOINT & FOLD POSITION FOR ANIMATION
                CGPoint pointEven = CGPointMake(0.5f, 0.0f);
                CGPoint pointOdd = CGPointMake(0.5f, 1.0f);
                CGRect  rectEven = CGRectMake(foldViewX, foldViewY + (0 * foldViewHeight), foldViewWidth, foldViewHeight);
                CGRect  rectOdd = CGRectMake(foldViewX, foldViewY - (1 * foldViewHeight), foldViewWidth, foldViewHeight);
                
                BOOL isEven = TRUE;  // NB  0 is first and is Even !!!!!
                
                //CREATE FOLD VIEWS ARRAY
                NSMutableArray *arrayFoldViews = [[NSMutableArray alloc] initWithCapacity:numFold];
                
                
                //INIT FOLD VIEWS ARRAY WITH IMAGE FOLD & SET ANCHOR POINT AND START FRAME POSITION
                for (int fold=0; fold<numFold; fold++) {
                    UIImageView *foldImageView = [[UIImageView alloc] initWithFrame:CGRectMake(foldViewX, foldViewY + (fold * foldViewHeight), foldViewWidth, foldViewHeight)];
                    
                    foldImageView.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(imageCapture.CGImage, CGRectMake(0, (fold * foldViewHeight), foldViewWidth, foldViewHeight))];
                    foldImageView.tag = FOLD_VIEW_TAG;
                    [self.superview addSubview:foldImageView];
                    
                    if (isEven) {
                        foldImageView.layer.anchorPoint = pointEven;
                        foldImageView.layer.frame = rectEven;
                        isEven = FALSE;
                    }
                    else {
                        foldImageView.layer.anchorPoint = pointOdd;
                        foldImageView.layer.frame = rectOdd;
                        isEven = TRUE;
                    }
                    
                    [arrayFoldViews addObject:foldImageView];
                }
                
                //INITIALIZE ANIMATION
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.hidden = FALSE;
                    for (UIView *view in [self.superview subviews]) {
                        if (view.tag == FOLD_VIEW_TAG) {
                            [view removeFromSuperview];
                        }
                    }
                    isAnimating = FALSE;
                    isOpen = TRUE;
                }];
                [CATransaction setAnimationDuration:animationDuration];
                
                
                //PREPARE TRANSFORM ANIMATION
                CATransform3D endTransform;
                CABasicAnimation *transformAnimationEven = [CABasicAnimation animationWithKeyPath:@"transform"];
                transformAnimationEven.delegate = self;
                transformAnimationEven.removedOnCompletion = NO;
                transformAnimationEven.timingFunction = [CAMediaTimingFunction functionWithName:mediaTimingFunction];
                endTransform = CATransform3DMakeRotation(M_PI_2, 1.0f, 0.0f, 0.0f);
                endTransform.m34 = -0.01f;
                transformAnimationEven.fromValue = [NSValue valueWithCATransform3D:endTransform];
                transformAnimationEven.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
                transformAnimationEven.fillMode = kCAFillModeBoth;    
                
                CABasicAnimation *transformAnimationOdd = [CABasicAnimation animationWithKeyPath:@"transform"];
                transformAnimationOdd.delegate = self;
                transformAnimationOdd.removedOnCompletion = NO;
                transformAnimationOdd.timingFunction = [CAMediaTimingFunction functionWithName:mediaTimingFunction];
                endTransform = CATransform3DMakeRotation(-M_PI_2, 1.0f, 0.0f, 0.0f);
                endTransform.m34 = -0.01f;
                transformAnimationOdd.fromValue = [NSValue valueWithCATransform3D:endTransform];
                transformAnimationOdd.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
                transformAnimationOdd.fillMode = kCAFillModeBoth;    
                
                
                //APPLY TRANSFORM ANIMATION
                isEven = TRUE;
                for (int fold=0; fold<numFold; fold++) {
                    UIImageView *foldImageView = [arrayFoldViews objectAtIndex:fold];
                    
                    if (isEven) {
                        [foldImageView.layer addAnimation:transformAnimationEven forKey:@"fold1"];
                        isEven = FALSE;
                    }
                    else {
                        [foldImageView.layer addAnimation:transformAnimationOdd forKey:@"fold2"];
                        isEven = TRUE;
                    }
                }
                
                
                //PREPARE POSITION ANIMATION (not for Fold1) AND APPLY POSITION ANIMATION (not for Fold1)
                isEven = TRUE;
                int heightMultiplier = 0;
                for (int fold=0; fold<numFold; fold++) {
                    UIImageView *foldImageView = [arrayFoldViews objectAtIndex:fold];
                    
                    if (!isEven) {
                        heightMultiplier += 2;
                    }
                    
                    CGPoint point = CGPointMake(foldViewX + (foldViewWidth / 2), foldViewY + (heightMultiplier * foldViewHeight));
                    
                    if (fold>0) {
                        //PREPARE POSITION ANIMATION (not for Fold1)
                        CABasicAnimation *positioAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                        positioAnimation.timingFunction = [CAMediaTimingFunction functionWithName:mediaTimingFunction];
                        positioAnimation.fromValue = [foldImageView.layer valueForKey:@"position"];
                        positioAnimation.toValue = [NSValue valueWithCGPoint:point];
                        
                        
                        //APPLY POSITION ANIMATION (not for Fold1)
                        foldImageView.layer.position = point;
                        [foldImageView.layer addAnimation:positioAnimation forKey:[NSString stringWithFormat:@"pos%d", fold]];
                    }
                    
                    
                    if (isEven) {
                        isEven = FALSE;
                    }
                    else {
                        isEven = TRUE;
                    }
                }
                
                
                [CATransaction commit];
            }
        }
        else {
            self.hidden = FALSE;
            isOpen = TRUE;
        }
    }
}


- (void)close:(BOOL)animated {
    if (isOpen) {
        if (animated) {
            if (!isAnimating) {
                isAnimating = TRUE;

                //CREATE IMAGE COPY OF FULL (self) VIEW
                UIGraphicsBeginImageContext(self.bounds.size);
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *imageCapture = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                //CREATE FOLD VIEW HEIGTH and WIDTH
                float foldViewX = self.frame.origin.x;
                float foldViewY = self.frame.origin.y;
                float foldViewWidth = self.frame.size.width;
                float foldViewHeight = self.frame.size.height / numFold;
                
                //PREPARE ANCHORPOINT & FOLD POSITION FOR ANIMATION
                CGPoint pointEven = CGPointMake(0.5f, 0.0f);
                CGPoint pointOdd = CGPointMake(0.5f, 1.0f);
                
                BOOL isEven = TRUE;  // NB  0 is first and is Even !!!!!
                
                //CREATE FOLD VIEWS ARRAY
                NSMutableArray *arrayFoldViews = [[NSMutableArray alloc] initWithCapacity:numFold];
                
                
                //INIT FOLD VIEWS ARRAY WITH IMAGE FOLD & SET ANCHOR POINT AND START FRAME POSITION
                int heightMultiplier = 0;
                for (int fold=0; fold<numFold; fold++) {
                    UIImageView *foldImageView = [[UIImageView alloc] initWithFrame:CGRectMake(foldViewX, foldViewY + (fold * foldViewHeight), foldViewWidth, foldViewHeight)];

                    foldImageView.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(imageCapture.CGImage, CGRectMake(0, (fold * foldViewHeight), foldViewWidth, foldViewHeight))];
                    foldImageView.tag = FOLD_VIEW_TAG;
                    [self.superview addSubview:foldImageView];
                    
                    if (!isEven) {
                        heightMultiplier += 2;
                    }

                    CGPoint point = CGPointMake(foldViewX + (foldViewWidth / 2), foldViewY + (heightMultiplier * foldViewHeight));

                    //APPLY POSITION FOR ANIMATION
                    foldImageView.layer.position = point;
                    
                    if (isEven) {
                        foldImageView.layer.anchorPoint = pointEven;
                        isEven = FALSE;
                    }
                    else {
                        foldImageView.layer.anchorPoint = pointOdd;
                        isEven = TRUE;
                    }
                    
                    [arrayFoldViews addObject:foldImageView];
                }

                
                //HIDE VIEW
                self.hidden = TRUE;

                
                //INITIALIZE ANIMATION
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    for (UIView *view in [self.superview subviews]) {
                        if (view.tag == FOLD_VIEW_TAG) {
                            [view removeFromSuperview];
                        }
                    }
                    isAnimating = FALSE;
                    isOpen = FALSE;
                }];
                [CATransaction setAnimationDuration:animationDuration];
                
                
                //PREPARE TRANSFORM ANIMATION
                CATransform3D endTransform;
                CABasicAnimation *transformAnimationEven = [CABasicAnimation animationWithKeyPath:@"transform"];
                transformAnimationEven.delegate = self;
                transformAnimationEven.removedOnCompletion = NO;
                transformAnimationEven.timingFunction = [CAMediaTimingFunction functionWithName:mediaTimingFunction];
                endTransform = CATransform3DMakeRotation(M_PI_2, 1.0f, 0.0f, 0.0f);
                endTransform.m34 = -0.01f;
                transformAnimationEven.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
                transformAnimationEven.toValue = [NSValue valueWithCATransform3D:endTransform];
                transformAnimationEven.fillMode = kCAFillModeBoth;    
                
                CABasicAnimation *transformAnimationOdd = [CABasicAnimation animationWithKeyPath:@"transform"];
                transformAnimationOdd.delegate = self;
                transformAnimationOdd.removedOnCompletion = NO;
                transformAnimationOdd.timingFunction = [CAMediaTimingFunction functionWithName:mediaTimingFunction];
                endTransform = CATransform3DMakeRotation(-M_PI_2, 1.0f, 0.0f, 0.0f);
                endTransform.m34 = -0.01f;
                transformAnimationOdd.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
                transformAnimationOdd.toValue = [NSValue valueWithCATransform3D:endTransform];
                transformAnimationOdd.fillMode = kCAFillModeBoth;                  
                
                
                //APPLY TRANSFORM ANIMATION
                isEven = TRUE;
                for (int fold=0; fold<numFold; fold++) {
                    UIImageView *foldImageView = [arrayFoldViews objectAtIndex:fold];
                    
                    if (isEven) {
                        [foldImageView.layer addAnimation:transformAnimationEven forKey:@"fold1"];
                        isEven = FALSE;
                    }
                    else {
                        [foldImageView.layer addAnimation:transformAnimationOdd forKey:@"fold2"];
                        isEven = TRUE;
                    }
                }
                
                
                //PREPARE POSITION ANIMATION (not for Fold1) AND APPLY POSITION ANIMATION (not for Fold1)
                isEven = TRUE;
                for (int fold=0; fold<numFold; fold++) {
                    UIImageView *foldImageView = [arrayFoldViews objectAtIndex:fold];
                    
                    CGPoint point = CGPointMake(foldViewX + (foldViewWidth / 2), foldViewY);
                    
                    if (fold>0) {
                        //PREPARE POSITION ANIMATION (not for Fold1)
                        CABasicAnimation *positioAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                        positioAnimation.timingFunction = [CAMediaTimingFunction functionWithName:mediaTimingFunction];
                        positioAnimation.fromValue = [foldImageView.layer valueForKey:@"position"];
                        positioAnimation.toValue = [NSValue valueWithCGPoint:point];
                        
                        
                        //APPLY POSITION ANIMATION (not for Fold1)
                        foldImageView.layer.position = point;
                        [foldImageView.layer addAnimation:positioAnimation forKey:[NSString stringWithFormat:@"pos%d", fold]];
                    }
                    
                    
                    if (isEven) {
                        isEven = FALSE;
                    }
                    else {
                        isEven = TRUE;
                    }
                }
                
                
                [CATransaction commit];
            }
        }
        else {
            self.hidden = TRUE;
            isOpen = FALSE;
        }
    }
}


@end
