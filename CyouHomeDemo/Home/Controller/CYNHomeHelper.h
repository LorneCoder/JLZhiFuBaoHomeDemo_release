//
//  CYNHomeHelper.h
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/14.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^SuccessCallback)(NSMutableArray *data, NSMutableArray *sectionTitles);

@interface CYNHomeHelper : NSObject

/**设置状态栏背景颜色*/
+ (void)setStatusBarBackgroundColor:(UIColor *)color;
/**导航栏相关配置*/
+ (void)configNavigationBarWithController:(UIViewController *)vc;

/**加载数据的回调*/
+ (void)loadDataWithSuccess:(SuccessCallback)success;

@end
