//
//  ViewController2.h
//  DMStackNotifications
//
//  Created by Dmitry Ponomarev on 12/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMStackExtControllerAnimatedTransitioning.h"

@interface ViewController2 : UIViewController <DMStackExtHelperTransitioningDelegate>

@property (retain, nonatomic) UIView *contentView;
@property (retain, nonatomic) UIView *containerLoadView;

@end
