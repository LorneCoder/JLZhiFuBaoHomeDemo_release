//
//  CYNHomeNavigaitonView.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/15.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeNavigaitonView.h"

@implementation CYNHomeNavigaitonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    CGFloat x = 0;
    CGFloat width = 40.f;
    for (NSInteger index = 0; index < 3; index ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (index == 0) {
            [button setImage:[UIImage imageNamed:@"icon_daka"] forState:UIControlStateNormal];
        } else if (index == 1) {
            [button setImage:[UIImage imageNamed:@"icon_sao"] forState:UIControlStateNormal];
        } else if (index == 2) {
            [button setImage:[UIImage imageNamed:@"icon_xiugaimima"] forState:UIControlStateNormal];
        }
        
        button.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
        button.frame = CGRectMake(x, 0, width, width);
        [self addSubview:button];
        
        x = x + width;
    }
}


@end
