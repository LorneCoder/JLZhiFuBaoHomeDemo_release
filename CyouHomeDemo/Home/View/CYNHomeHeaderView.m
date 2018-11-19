//
//  CYNHomeHeaderView.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/15.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeHeaderView.h"

#define kMargin             35
#define kButtonWidth        80
#define kButtonHeight       65


@interface CYNHomeHeaderView()

@end

@implementation CYNHomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#28272B"];
        
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    CGFloat x = kMargin;
    CGFloat y = 10;
    CGFloat space = (CGRectGetWidth(self.frame) - 3 * kButtonWidth - 2 * kMargin) / 2.0;
    
    NSArray *icons = @[@"icon_daka", @"icon_sao", @"icon_xiugaimima"];
    NSArray *titles = @[@"我", @"扫一扫", @"修改密码"];
    for (int i = 0; i < 3; i ++) {
        CYNButton *btn = [CYNButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, kButtonWidth, kButtonHeight);
        [btn setImage:[UIImage imageNamed:icons[i]] forState:UIControlStateNormal];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
                
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        x = CGRectGetMaxX(btn.frame) + space;
    }
    
}

- (void)btnClicked:(UIButton *)sender
{
    NSString *title = sender.currentTitle;
    NSLog(@"%@", title);
}

#pragma mark - Set方法

- (void)setHeaderViewAlpha:(CGFloat)topY contentOffsetY:(CGFloat)contentOffsetY
{
    CGFloat scale = kHomeKuaiJieJian_Height / 2.0;
    
    CGFloat alpha = 0;
    if (contentOffsetY > -(topY - scale)) {
        alpha = 0;
    } else if (contentOffsetY > -(topY - scale / 2.0)) {
        alpha = 1 - (contentOffsetY + (topY - scale / 2.0)) / (scale / 2.0);
    } else {
        alpha = 1;
    }
    
    for (UIView *subview in self.subviews) {
        subview.alpha = alpha;
    }
}


@end
