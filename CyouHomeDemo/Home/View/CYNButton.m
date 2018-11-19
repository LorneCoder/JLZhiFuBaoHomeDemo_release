//
//  CYNButton.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/15.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNButton.h"

#define kButtonWidth        80
#define kButtonHeight       65
#define kImageWidth         40

@implementation CYNButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageOffsetX = (kButtonWidth - kImageWidth) / 2.0;
    CGFloat imageOffsetY = kButtonHeight - kImageWidth;
    
    //image center
    CGPoint center;
    center.x = self.frame.size.width/2;
    center.y = self.imageView.frame.size.height/2;
    self.imageView.center = center;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, imageOffsetX, imageOffsetY, imageOffsetX);
    
    //text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height + 10;
    newFrame.size.width = self.frame.size.width;
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end

