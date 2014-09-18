//
//  ViewController.h
//  DMStackNotifications
//
//  Created by Dmitry Ponomarev on 10/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMStackExtControllerAnimatedTransitioning.h"

@interface ViewController : UICollectionViewController

@property (nonatomic, strong) DMStackExtControllerAnimatedTransitioning *transitionController;
@property (nonatomic, weak) NSIndexPath *selectedIndexPath;

@end

