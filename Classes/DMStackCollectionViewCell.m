//
//  DMStackCollectionViewCell.m
//  DMStackCollections
//
//  Created by Dmitry Ponomarev on 12/09/14.
//  Copyright (c) 2014 Demdxx. All rights reserved.
//

#import "DMStackCollectionViewCell.h"

@implementation DMStackCollectionViewCell

- (instancetype)init
{
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
  
  [UIView animateWithDuration:0.2f animations:^{
    self.transform = CGAffineTransformScale(self.transform, 0.95, 0.95);
  }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  
  [UIView animateWithDuration:0.07f animations:^{
    self.transform = CGAffineTransformMakeTranslation(0, 0);
  }];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
  
  [UIView animateWithDuration:0.07f animations:^{
    self.transform = CGAffineTransformMakeTranslation(0, 0);
  }];
}

@end
