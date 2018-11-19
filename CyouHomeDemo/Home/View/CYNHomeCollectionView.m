//
//  CYNHomeCollectionView.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/13.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeCollectionView.h"
#import "CYNHomeCell.h"
#import "CYNHomeCellHeader.h"
#import "CYNHomeCategoryHeader.h"

@interface CYNHomeCollectionView()

@end

@implementation CYNHomeCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.showsHorizontalScrollIndicator = false;
        self.backgroundColor = [UIColor colorWithHexString:@"#E7E7E7"];
        [self registerClass:[CYNHomeCell class] forCellWithReuseIdentifier:@"CYNHomeCell"];
        [self registerClass:[CYNHomeCellHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCellHeader"];
        [self registerClass:[CYNHomeCategoryHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCategoryHeader"];
                
        //设置滚动范围偏移100
        //self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        //设置内容范围偏移100
        //self.contentInset = UIEdgeInsetsMake(kHomeHeader_Height, 0, kHomeHeader_Height, 0);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.layoutSubviewsCallback) {
        self.layoutSubviewsCallback();
    }
}


@end
