//
//  DMStackNotificationControllerInteractiveTransitioning.m
//  DMStackCollections
//
//  Created by Dmitry Ponomarev on 12/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import "DMStackControllerAnimatedTransitioning.h"

#import <CPAnimationSequence/CPAnimationSequence.h>

#define SNAP_SPEED 0.33f

#define TAG_ITEM 1001
#define TAG_BLUR TAG_ITEM + 1
#define TAG_BG TAG_ITEM + 2

////////////////////////////////////////////////////////////////////////////////

@interface DMStackControllerAnimatedTransitioning ()

@property (nonatomic, readonly) UIImage *preparedViewController;
@property (nonatomic, readonly) UIImage *preparedView;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation DMStackControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
  return 0.07f + SNAP_SPEED + 0.5f + 0.4f;
}

// Presentation animation block
//
// @param transitionContext
- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
  //////////////////////////////////////////////////////////////////////////////
  // 0. Get active params
  //
  UICollectionViewController *fromVC = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  UIView *container = [transitionContext containerView];
  container.backgroundColor = fromVC.view.backgroundColor;
  
  if (nil != self.animator) {
    [self.animator removeAllBehaviors];
  }
  
  self.transitionContext = transitionContext;
  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
  
  //////////////////////////////////////////////////////////////////////////////
  // 1. Set background
  //
  if (nil != self.bgImageView) {
    [container addSubview:self.bgImageView];
    [container addSubview:self.bgBlurImageView];
  }
  
  //////////////////////////////////////////////////////////////////////////////
  // 2. Init data
  //
  
  // Content
  CGPoint center = toVC.view.center;
  UIView *content = toVC.view;
  [container addSubview:content];
  
  // Set item
  [container addSubview:self.itemView];
  
  // Prepare content
  CGRect targetFrame = toVC.view.frame;
  toVC.view.frame = container.bounds;
  content.frame = CGRectInset(_itemView.frame, -5.f, -5.f);
  content.center = center;
  content.alpha = 0.f;
  content.clipsToBounds = YES;
  
  [fromVC.view removeFromSuperview];
  
  //////////////////////////////////////////////////////////////////////////////
  // 3. Animation
  //
  
  // Snap item
  UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:_itemView snapToPoint:center];
  snapBehaviour.damping = SNAP_SPEED * self.animationFactor;
  
  // Animation sequence
  NSArray *seq =
  @[
    [CPAnimationStep for:0.07f animate:^{
      _itemView.frame = CGRectInset(_itemView.frame, -5.f, -5.f);
      _itemView.frame = CGRectOffset(_itemView.frame, -_itemView.frame.size.height/20, -_itemView.frame.size.height/10);
    }],
    [CPAnimationStep for:SNAP_SPEED animate:^{
      _bgBlurImageView.alpha = 1.f;
      [self.animator addBehavior:snapBehaviour];
    }],
    [CPAnimationStep for:0.2 animate:^{
      content.alpha = 1.f;
      //content.backgroundColor = [UIColor redColor];
    }],
    [CPAnimationStep for:0.5f animate:^{
      _itemView.alpha = 0.f;
    }],
    // Finish animation block
    [CPAnimationStep for:0.4f animate:^{
      content.transform = CGAffineTransformIdentity;
      content.frame = targetFrame;
    }],
    // Finish block
    [CPAnimationStep after:0.f animate:^{
      if (nil != _animator) {
        [_animator removeAllBehaviors];
      }
      
      [_bgImageView removeFromSuperview];
      [transitionContext completeTransition:YES];
      
      _bgImageView = nil;
    }]
  ];
  
  // Run animation
  [[CPAnimationSequence sequenceWithStepsByArray:seq factor:self.animationFactor] run];
}

// Dismiss animation block
//
// @param transitionContext
- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
  //////////////////////////////////////////////////////////////////////////////
  // 0. Get active params
  //
  UICollectionViewController *fromVC = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  UIView *container = [transitionContext containerView];
  container.backgroundColor = [UIColor whiteColor];
  
  if (nil != self.animator) {
    [self.animator removeAllBehaviors];
  }
  
  self.transitionContext = transitionContext;
  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
  
  //////////////////////////////////////////////////////////////////////////////
  // 1. Get backgrounds
  //
  if (nil != self.bgBlurImageView) {
    [self.bgBlurImageView removeFromSuperview];
    [container addSubview:self.bgBlurImageView];
  }

  UIView *content = fromVC.view;
  [container addSubview:content];
  
  self.itemView.frame = [self itemViewTargetRect:transitionContext];
  if (nil == _itemView.superview) {
    [container addSubview:_itemView];
  }
  
  [container addSubview:toVC.view];
  [container sendSubviewToBack:toVC.view];
  
  //////////////////////////////////////////////////////////////////////////////
  // 2. Animation
  //

  // Snap item
  UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:_itemView snapToPoint:self.preparedViewPosition];
  snapBehaviour.damping = SNAP_SPEED * self.animationFactor;
  
  // Animation sequence
  NSArray *seq =
  @[
    [CPAnimationStep for:0.2f animate:^{
      content.frame = _itemView.frame;
    }],
    [CPAnimationStep for:0.3f animate:^{
      _itemView.alpha = 1.f;
      content.alpha = 0.f;
    }],
    [CPAnimationStep for:SNAP_SPEED animate:^{
      [self.animator addBehavior:snapBehaviour];
    }],
    [CPAnimationStep after:SNAP_SPEED+0.05f for:0.2f animate:^{
      _bgBlurImageView.alpha = 0.f;
    }],
    [CPAnimationStep for:0.07f animate:^{
      _itemView.frame = CGRectInset(_itemView.frame, 5.f, 5.f);
      _itemView.center = self.preparedViewPosition;
    }],
    [CPAnimationStep after:0.f animate:^{
      if (nil != _animator) {
        [_animator removeAllBehaviors];
      }
      
      [_bgBlurImageView removeFromSuperview];
      [_itemView removeFromSuperview];
      [fromVC.view removeFromSuperview];
      [transitionContext completeTransition:YES];
      
      _itemView = nil;
      _bgBlurImageView = nil;
    }]
  ];
  
  // Run animation
  [[CPAnimationSequence sequenceWithStepsByArray:seq factor:self.animationFactor] run];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
  if (self.isPresentation) {
    return [self animatePresentation:transitionContext];
  } else {
    return [self animateDismissal:transitionContext];
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – Getters/Setters
////////////////////////////////////////////////////////////////////////////////

- (UIView *)itemView
{
  if (nil == _itemView) {
    UIView *container = self.transitionContext.containerView;
    _itemView = [container viewWithTag:TAG_ITEM];
  }
  if (nil == _itemView) {
    UIImage *image = self.preparedView;
    if (nil != image) {
      _itemView = [[UIImageView alloc] initWithImage:image];
      _itemView.transform = self.expandView.transform;
      _itemView.frame = self.preparedViewRect;
    } else {
      _itemView = [[UIView alloc] initWithFrame:self.preparedViewRect];
    }
    _itemView.tag = TAG_ITEM;
  }
  return _itemView;
}

- (UIView *)bgImageView
{
  if (nil == _bgImageView) {
    UIView *container = self.transitionContext.containerView;
    _bgImageView = [container viewWithTag:TAG_BG];
  }
  if (nil == _bgImageView) {
    UIImage *bgImage = self.preparedViewController;
    
    if (nil != bgImage) {
      UICollectionViewController *fromVC = (UICollectionViewController *)[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

      _bgImageView = [[UIImageView alloc] initWithImage:bgImage];
      _bgImageView.transform = fromVC.view.transform;
      _bgImageView.frame = fromVC.view.frame;
      _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
      _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
      _bgImageView.tag = TAG_BG;
    }
  }
  return _bgImageView;
}

- (UIView *)bgBlurImageView
{
  if (nil == _bgBlurImageView) {
    UIView *container = self.transitionContext.containerView;
    _bgBlurImageView = [container viewWithTag:TAG_BLUR];
  }
  if (nil == _bgBlurImageView && nil != self.bgImageView) {
    UICollectionViewController *fromVC = (UICollectionViewController *)[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    _bgBlurImageView = [[UIImageView alloc] initWithImage:[self blur:((UIImageView *)self.bgImageView).image]];
    _bgBlurImageView.transform = fromVC.view.transform;
    _bgBlurImageView.frame = fromVC.view.frame;
    _bgBlurImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _bgBlurImageView.alpha = 0.f;
    _bgBlurImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgBlurImageView.tag = TAG_BLUR;
  }
  return _bgBlurImageView;
}

- (UIImage *)preparedView
{
  if (nil != self.expandView) {
    UIView *v = self.expandView;
    UIGraphicsBeginImageContextWithOptions(v.bounds.size, v.opaque, 0.f);
    [self.expandView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
  }
  return nil;
}

- (UIImage *)preparedViewController
{
  UICollectionViewController *vc = (UICollectionViewController *)[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  
  self.expandView.alpha = 0.f;
  
  if (nil != vc) {
    UIView *v = vc.view;
    UIGraphicsBeginImageContextWithOptions(v.bounds.size, v.opaque, 0.f);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.expandView.alpha = 1.f;
    
    return img;
  }
  return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – Getters metric
////////////////////////////////////////////////////////////////////////////////

- (CGRect)preparedViewRect
{
  CGRect frame = self.expandView.frame;
  UIView *v = self.expandView.superview;
  
  while (v) {
    if ([v isKindOfClass:[UIScrollView class]]) {
      frame.origin.y -= ((UIScrollView *)v).contentOffset.y;
    }
    v = v.superview;
  }
  return frame;
}

- (CGPoint)preparedViewPosition
{
  CGPoint p = self.expandView.center;
  UIView *v = self.expandView.superview;
  
  while (v) {
    if ([v isKindOfClass:[UIScrollView class]]) {
      p.y -= ((UIScrollView *)v).contentOffset.y;
    }
    v = v.superview;
  }
  return p;
}

- (CGRect)itemViewTargetRect:(id<UIViewControllerContextTransitioning>)transitionContext
{
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  CGRect targetRect = [transitionContext finalFrameForViewController:toVC];
  CGRect rect = CGRectInset(_expandView.frame, -5.f, -5.f);
  rect.origin.x = (targetRect.size.width-rect.size.width)/2.f;
  rect.origin.y = (targetRect.size.height-rect.size.height)/2.f;
  return rect;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – Helpers
////////////////////////////////////////////////////////////////////////////////

- (UIImage*)blur:(UIImage*)theImage
{
  // create our blurred image
  CIContext *context = [CIContext contextWithOptions:nil];
  CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
  
  // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
  CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
  [filter setValue:inputImage forKey:kCIInputImageKey];
  [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
  CIImage *result = [filter valueForKey:kCIOutputImageKey];
  
  // CIGaussianBlur has a tendency to shrink the image a little,
  // this ensures it matches up exactly to the bounds of our original image
  CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
  
  UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
  CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
  
  return returnImage;
}

@end

