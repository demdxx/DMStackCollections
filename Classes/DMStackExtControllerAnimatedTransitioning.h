//
//  DMStackNotificationControllerInteractiveTransitioning.h
//  DMStackNotifications
//
//  Created by Dmitry Ponomarev on 12/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

@import UIKit;

#import "DMStackControllerAnimatedTransitioning.h"

@class DMStackExtControllerAnimatedTransitioning;

////////////////////////////////////////////////////////////////////////////////

@protocol DMStackExtHelperTransitioningDelegate <NSObject>

@optional

// Appear
- (void)stackNotificationDisplayAnimation:(DMStackExtControllerAnimatedTransitioning *)animatedTransitioning;

// Dismiss
- (void)stackNotificationDismissAnimation:(DMStackExtControllerAnimatedTransitioning *)animatedTransitioning;

@end

////////////////////////////////////////////////////////////////////////////////

@interface DMStackExtControllerAnimatedTransitioning : DMStackControllerAnimatedTransitioning

@end
