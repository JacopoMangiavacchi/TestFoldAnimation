//
//  FoldView.h
//  TestTendina
//
//  Created by Jacopo Mangiavacchi on 08/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#define FOLD_VIEW_TAG   1718374
#define DEFAULT_NUM_FOLD 10
#define DEFAULT_ANIMATION_DURATION 0.5


@interface FoldView : UIView {
    
    BOOL isAnimating;
}

@property (nonatomic, readonly) BOOL isOpen;
@property (nonatomic) int numFold;
@property (nonatomic) float animationDuration;
@property (strong, nonatomic) NSString *mediaTimingFunction;

- (void)open:(BOOL)animated;
- (void)close:(BOOL)animated;

@end
