//
//  CYNHomeCategoryHeader.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/13.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//  分类导航区头

#import "CYNHomeCategoryHeader.h"

@interface CYNHomeCategoryHeader()

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *lineImg;
@property (nonatomic, strong) UILabel *headerLabel;

@end

@implementation CYNHomeCategoryHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#E7E7E7"];

        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.lineImg];
    [self.bottomView addSubview:self.headerLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bottomView.frame = CGRectMake(0, 60, CGRectGetWidth(self.bounds), 30);
    self.lineImg.frame = CGRectMake(0, 7, 3, 16);
    
    CGFloat headerLabelX = CGRectGetMaxX(self.lineImg.frame) + 10;
    CGFloat headerLabelW = CGRectGetWidth(self.bottomView.frame) - headerLabelX;
    CGFloat headerLabelH = CGRectGetHeight(self.bottomView.frame);
    self.headerLabel.frame = CGRectMake(headerLabelX, 0,  headerLabelW, headerLabelH);
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIImageView *)lineImg
{
    if (!_lineImg) {
        _lineImg = [[UIImageView alloc] init];
        _lineImg.backgroundColor = [UIColor colorWithHexString:@"#2389ED"];
    }
    return _lineImg;
}

- (UILabel *)headerLabel
{
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.textColor = [UIColor blackColor];
        _headerLabel.font = [UIFont systemFontOfSize:14];
    }
    return _headerLabel;
}

- (void)setSectionName:(NSString *)sectionName
{
    _sectionName = sectionName;
    self.headerLabel.text = _sectionName;
}


@end
