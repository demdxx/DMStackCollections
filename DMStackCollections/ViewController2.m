//
//  ViewController2.m
//  DMStackNotifications
//
//  Created by Dmitry Ponomarev on 12/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import "ViewController2.h"

#import <CPAnimationSequence/CPAnimationSequence.h>

#define SNAP_SPEED 0.33f
#define TAG_LOAD_VIEW 202

@interface ViewController2 ()

@property (nonatomic, strong) UIView *bgBlurImageView;
@property (nonatomic, strong) UIDynamicAnimator *animator;

- (CGRect)centerRect:(CGRect)rect inRect:(CGRect)inRect;

@end

@implementation ViewController2

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor clearColor];
  self.contentView.alpha = 0.f;
  self.containerLoadView.alpha = 0.f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClose:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
//  [UIView animateWithDuration:0.4f animations:^{
//    self.contentView.frame = CGRectMake(100, 100, 100, 100);
//  }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – DMStackNotificationHelperTransitioningDelegate
////////////////////////////////////////////////////////////////////////////////

/// Appear

- (void)stackNotificationDisplayAnimation:(DMStackExtControllerAnimatedTransitioning *)animatedTransitioning
{
  id<UIViewControllerContextTransitioning> transitionContext = animatedTransitioning.transitionContext;
  
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
  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
  
  //////////////////////////////////////////////////////////////////////////////
  // 1. Set background
  //
  if (nil != animatedTransitioning.bgImageView) {
    [container addSubview:animatedTransitioning.bgImageView];
    [self.view addSubview:animatedTransitioning.bgBlurImageView];
    [self.view sendSubviewToBack:animatedTransitioning.bgBlurImageView];
    self.bgBlurImageView = animatedTransitioning.bgBlurImageView;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose:)];
    [self.bgBlurImageView addGestureRecognizer:gesture];
  }
  
  //////////////////////////////////////////////////////////////////////////////
  // 2. Init data
  //

  // Content
  CGPoint center = toVC.view.center;
  UIView *content = toVC.view;
  [container addSubview:content];
  
  // Set item
  [container addSubview:animatedTransitioning.itemView];
  
  // Prepare content
  CGRect targetRect = [animatedTransitioning.transitionContext finalFrameForViewController:toVC];
  self.view.frame = targetRect;
  
  CGRect r = [animatedTransitioning itemViewTargetRect:animatedTransitioning.transitionContext];
  self.contentView.frame = r;
  self.containerLoadView.frame = r;
  
  [fromVC.view removeFromSuperview];
  
  //////////////////////////////////////////////////////////////////////////////
  // 3. Animation
  //
  
  // Snap item
  UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:animatedTransitioning.itemView snapToPoint:center];
  snapBehaviour.damping = SNAP_SPEED * animatedTransitioning.animationFactor;
  
  // Animation sequence
  NSArray *seq =
  @[
    [CPAnimationStep for:0.07f animate:^{
      CGRect frame = animatedTransitioning.itemView.frame;
      frame = CGRectInset(frame, -5.f, -5.f);
      animatedTransitioning.itemView.frame = CGRectOffset(frame, -frame.size.height/20, -frame.size.height/10);
    }],
    [CPAnimationStep for:SNAP_SPEED animate:^{
      animatedTransitioning.bgImageView.alpha = 0.f;
      animatedTransitioning.bgBlurImageView.alpha = 1.f;
      [self.animator addBehavior:snapBehaviour];
    }],
    [CPAnimationStep for:0.3f animate:^{
      self.containerLoadView.alpha = 1.f;
    }],
    [CPAnimationStep for:0.2f animate:^{
      animatedTransitioning.itemView.alpha = 0.f;
    }],
    [CPAnimationStep after:0.f animate:^{
      self.view.backgroundColor = [UIColor whiteColor];
      [self.view updateConstraints];

      [self stackNotificationDisplayProcessLoading:^(BOOL success) {
        NSArray *anim = @[
          // Finish animation block
          [CPAnimationStep for:0.4f animate:^{
            [self stackNotificationDisplayProcessFinishAnimation:animatedTransitioning];
          }],
          // Finish block
          [CPAnimationStep after:0.f animate:^{
            [self.containerLoadView removeFromSuperview];
            self.containerLoadView = nil;
            
            if (nil != _animator) {
              [_animator removeAllBehaviors];
            }
            
            [animatedTransitioning.bgImageView removeFromSuperview];
            [transitionContext completeTransition:YES];
            
            animatedTransitioning.bgImageView = nil;
          }]
        ];
        [[CPAnimationSequence sequenceWithStepsByArray:anim factor:animatedTransitioning.animationFactor] run];
        
      } animatedTransitioning:animatedTransitioning];
    }]
  ];
  
  // Run animation
  [[CPAnimationSequence sequenceWithStepsByArray:seq factor:animatedTransitioning.animationFactor] run];
}

- (void)stackNotificationDisplayProcessLoading:(void(^)(BOOL success))callback animatedTransitioning:(DMStackExtControllerAnimatedTransitioning *)animatedTransitioning
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    sleep(1);
    dispatch_async(dispatch_get_main_queue(), ^{
      callback(YES);
    });
  });
}

- (void)stackNotificationDisplayProcessFinishAnimation:(DMStackExtControllerAnimatedTransitioning *)animatedTransitioning
{
  UIViewController *toVC = [animatedTransitioning.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

  CGRect targetRect = [animatedTransitioning.transitionContext finalFrameForViewController:toVC];
  CGRect nRect = [self centerRect:CGRectMake(0, 0, _containerLoadView.frame.size.width, self.view.frame.size.height * 0.7) inRect:targetRect];
  
  _contentView.alpha = 1.f;
  _contentView.frame = nRect;

  _containerLoadView.frame = nRect;
  _containerLoadView.alpha = 0.f;
}

////////////////////////////////////////////////////////////////////////////////
/// Dismiss

- (void)stackNotificationDismissAnimation:(DMStackExtControllerAnimatedTransitioning *)animatedTransitioning
{
  id<UIViewControllerContextTransitioning> transitionContext = animatedTransitioning.transitionContext;

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
  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
  
  //////////////////////////////////////////////////////////////////////////////
  // 1. Get backgrounds
  //
  self.view.backgroundColor = [UIColor clearColor];
  UIView *content = fromVC.view;
  
  [container addSubview:toVC.view];
  [container sendSubviewToBack:toVC.view];
  
  animatedTransitioning.itemView.frame = [animatedTransitioning itemViewTargetRect:transitionContext];
  if (nil == animatedTransitioning.itemView.superview) {
    [container addSubview:animatedTransitioning.itemView];
  } else {
    [container bringSubviewToFront:animatedTransitioning.itemView];
  }
  
  [container sendSubviewToBack:toVC.view];
  
  //////////////////////////////////////////////////////////////////////////////
  // 2. Animation
  //
  
  // Snap item
  UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:animatedTransitioning.itemView snapToPoint:animatedTransitioning.preparedViewPosition];
  snapBehaviour.damping = SNAP_SPEED * animatedTransitioning.animationFactor;
  
  // Animation sequence
  NSArray *seq =
  @[
    [CPAnimationStep for:0.4f animate:^{
      self.contentView.frame = animatedTransitioning.itemView.frame;
    }],
    [CPAnimationStep for:0.5f animate:^{
      animatedTransitioning.itemView.alpha = 1.f;
    }],
    [CPAnimationStep for:0.f animate:^{
      _contentView.alpha = 0.f;
    }],
    [CPAnimationStep for:SNAP_SPEED animate:^{
      [self.animator addBehavior:snapBehaviour];
    }],
    [CPAnimationStep after:SNAP_SPEED+0.05f for:0.2f animate:^{
      content.alpha = 0.f;
    }],
    [CPAnimationStep for:0.07f animate:^{
      animatedTransitioning.itemView.frame = CGRectInset(animatedTransitioning.itemView.frame, 5.f, 5.f);
      animatedTransitioning.itemView.center = animatedTransitioning.preparedViewPosition;
    }],
    [CPAnimationStep after:0.f animate:^{
      if (nil != _animator) {
        [_animator removeAllBehaviors];
      }
      
      [animatedTransitioning.bgBlurImageView removeFromSuperview];
      [animatedTransitioning.itemView removeFromSuperview];
      [fromVC.view removeFromSuperview];
      [transitionContext completeTransition:YES];
      
      animatedTransitioning.itemView = nil;
      animatedTransitioning.bgBlurImageView = nil;
    }]
  ];
  
  // Run animation
  [[CPAnimationSequence sequenceWithStepsByArray:seq factor:animatedTransitioning.animationFactor] run];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – Getters/Setters
////////////////////////////////////////////////////////////////////////////////

- (UIView *)contentView
{
  if (nil == _contentView) {
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.85, self.view.frame.size.height * 0.7)];
    _contentView.clipsToBounds = NO;
    _contentView.alpha = 0.f;
    _contentView.backgroundColor = [UIColor whiteColor];

    _contentView.layer.cornerRadius = 3.f;
    _contentView.layer.shadowOffset = CGSizeMake(3, 3);
    _contentView.layer.shadowRadius = 3.f;
    _contentView.layer.shadowOpacity = .5f;
    
    // Set navigation bar
    UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, 44)];
    nav.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    nav.topItem.title = @"Title!";

    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Navigation Bar title here";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    navItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    navItem.rightBarButtonItem = rightButton;
    
    nav.items = @[navItem];
    
    [_contentView addSubview:nav];
    
    // Set navigation content
    UITextView *tf = [[UITextView alloc] initWithFrame:CGRectMake(0.f, 44.f, _contentView.frame.size.width, _contentView.frame.size.height - 44.f)];
    //tf.lineBreakMode = NSLineBreakByWordWrapping;
    //tf.numberOfLines = 0;
    tf.selectable = NO;
    tf.editable = NO;
    tf.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tf.text = @"App widgets (sometimes just \"widgets\") are a feature introduced in Android 1.5 and vastly improved in Android 3.0 and 3.1. A widget can display an application's most timely or otherwise relevant information at a glance, on a user's Home screen. The standard Android system image includes several widgets, including a widget for the Analog Clock, Music, and other applications.";
    
    [_contentView addSubview:tf];
    
    // Add to main view
    [self.view addSubview:_contentView];
  }
  return _contentView;
}

- (UIView *)containerLoadView
{
  if (nil == _containerLoadView) {
    _containerLoadView = [[UIView alloc] initWithFrame:self.view.bounds];
    _containerLoadView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _containerLoadView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.0f];
    _containerLoadView.alpha = 0.f;
    _containerLoadView.tag = TAG_LOAD_VIEW;

    _containerLoadView.layer.cornerRadius = 3.f;
    _containerLoadView.layer.shadowOffset = CGSizeMake(3, 3);
    _containerLoadView.layer.shadowRadius = 3.f;
    _containerLoadView.layer.shadowOpacity = .5f;

    // Set progress control
    UIActivityIndicatorView *progress = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    progress.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [progress startAnimating];
    progress.color = [UIColor colorWithRed:0.28f green:0.62f blue:0.91f alpha:1.0f];
    [_containerLoadView addSubview:progress];
    
    // Add to main view
    [self.view addSubview:_containerLoadView];
  }
  return _containerLoadView;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – Helpers
////////////////////////////////////////////////////////////////////////////////

- (CGRect)centerRect:(CGRect)rect inRect:(CGRect)inRect;
{
  CGRect frame;
  frame.size.width = MIN(rect.size.width, inRect.size.width);
  frame.size.height = rect.size.height;
  frame.origin.x = (inRect.size.width - frame.size.width) / 2.f;
  frame.origin.y = (inRect.size.height - frame.size.height) / 2.f;
  return frame;
}

@end
