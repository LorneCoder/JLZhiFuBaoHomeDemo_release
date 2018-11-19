//
//  CYNHomeMyAppsView.h
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/15.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//  我的应用区域视图

#import <UIKit/UIKit.h>
#import "CYNHomeCellModel.h"

typedef void(^ViewHeightCallback)(CGFloat viewHeight);
typedef void(^AppIsEditCallback)(BOOL appIsEdit);
typedef void(^DeleteAppCallback)(CYNHomeCellModel *model);

@interface CYNHomeMyAppsView : UICollectionView

/**我的应用个数*/
@property (nonatomic, strong) NSMutableArray <CYNHomeCellModel *> *appsArray;
/**我的应用ID数组*/
//@property (nonatomic, strong) NSMutableSet <NSString *> *appIDs;

/**根据应用个数返回页面高度的回调*/
@property (nonatomic, copy) ViewHeightCallback viewHeightBlock;
/**应用是否处于编辑状态的回调*/
@property (nonatomic, copy) AppIsEditCallback appEditBlock;
/**删除应用的回调*/
@property (nonatomic, copy) DeleteAppCallback deletaAppBlock;


- (instancetype)cyn_initWithFrame:(CGRect)frame;

/**编辑状态下的配置*/
- (void)setEditConfig;
/**常规状态下的配置*/
- (void)setNormalStateConfig;

@end
