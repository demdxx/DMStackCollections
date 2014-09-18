//
//  ViewController.m
//  DMStackNotifications
//
//  Created by Dmitry Ponomarev on 10/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation ViewController
            
- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
  return self.transitionController;
}

#pragma mark – UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  self.selectedIndexPath = indexPath;
  UIViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:indexPath.row % 2 == 0 ? @"controller" : @"controller2"];
  c.transitioningDelegate = self;
  
//  c.modalPresentationStyle = UIModalPresentationCurrentContext;
//  [self presentModalViewController:c animated:YES];
  
  [self presentViewController:c animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 50;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  
  CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
  CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
  CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
  UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
  cell.backgroundColor = color;
  
  return cell;
}

#pragma mark – Transition`s

- (DMStackExtControllerAnimatedTransitioning *)transitionController
{
  @synchronized (self) {
    if (!_transitionController) {
      _transitionController = [DMStackExtControllerAnimatedTransitioning new];
      _transitionController.animationFactor = 1.f;
    }
    return _transitionController;
  }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
  self.transitionController.isPresentation = YES;
  self.transitionController.expandView = [[self collectionView] cellForItemAtIndexPath:self.selectedIndexPath];
  return self.transitionController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
  self.transitionController.isPresentation = NO;
  return self.transitionController;
}

@end
