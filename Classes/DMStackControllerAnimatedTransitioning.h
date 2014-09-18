//
//  DMStackExtControllerAnimatedTransitioning.h
//  DMStackCollections
//
//  Created by Dmitry Ponomarev on 16/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMStackControllerAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, weak) UIView *expandView;
@property (nonatomic, assign) BOOL isPresentation;
@property (nonatomic, retain) UIView *itemView;
@property (nonatomic, retain) UIView *bgImageView;
@property (nonatomic, retain) UIView *bgBlurImageView;
@property (nonatomic, readonly) CGRect preparedViewRect;
@property (nonatomic, readonly) CGPoint preparedViewPosition;
@property (nonatomic, assign) CGFloat animationFactor;

- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext;

- (CGRect)itemViewTargetRect:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
