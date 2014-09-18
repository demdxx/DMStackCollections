//
//  DMStackExtControllerAnimatedTransitioning.m
//  DMStackNotifications
//
//  Created by Dmitry Ponomarev on 12/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import "DMStackExtControllerAnimatedTransitioning.h"

////////////////////////////////////////////////////////////////////////////////

@implementation DMStackExtControllerAnimatedTransitioning

// Presentation animation block
//
// @param transitionContext
- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
  UICollectionViewController *fromVC = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  self.transitionContext = transitionContext;
  {
    id<DMStackExtHelperTransitioningDelegate> delegate = nil;
    
    if ([toVC conformsToProtocol:@protocol(DMStackExtHelperTransitioningDelegate)]) {
      delegate = (id<DMStackExtHelperTransitioningDelegate>)toVC;
    } else if ([fromVC conformsToProtocol:@protocol(DMStackExtHelperTransitioningDelegate)]) {
      delegate = (id<DMStackExtHelperTransitioningDelegate>)fromVC;
    }
  
    if (nil != delegate && [delegate respondsToSelector:@selector(stackNotificationDisplayAnimation:)]) {
      [delegate stackNotificationDisplayAnimation:self];
      return;
    }
  }

  [super animatePresentation:transitionContext];
}

// Dismiss animation block
//
// @param transitionContext
- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
  UICollectionViewController *fromVC = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  self.transitionContext = transitionContext;
  {
    id<DMStackExtHelperTransitioningDelegate> delegate = nil;
    
    if ([toVC conformsToProtocol:@protocol(DMStackExtHelperTransitioningDelegate)]) {
      delegate = (id<DMStackExtHelperTransitioningDelegate>)toVC;
    } else if ([fromVC conformsToProtocol:@protocol(DMStackExtHelperTransitioningDelegate)]) {
      delegate = (id<DMStackExtHelperTransitioningDelegate>)fromVC;
    }
    
    if (nil != delegate && [delegate respondsToSelector:@selector(stackNotificationDismissAnimation:)]) {
      [delegate stackNotificationDismissAnimation:self];
      return;
    }
  }
  
  [super animateDismissal:transitionContext];
}

@end

