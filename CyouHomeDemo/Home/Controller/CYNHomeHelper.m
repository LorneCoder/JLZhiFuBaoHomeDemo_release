//
//  CYNHomeHelper.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/14.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeHelper.h"
#import "CYNHomeSectionModel.h"

@implementation CYNHomeHelper

/**设置状态栏背景颜色*/
+ (void)setStatusBarBackgroundColor:(UIColor *)color
{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

/**导航栏相关配置*/
+ (void)configNavigationBarWithController:(UIViewController *)vc
{
    //设置导航栏
    vc.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#28272B"];
    vc.navigationController.navigationBar.tintColor = [UIColor whiteColor];//导航栏按钮颜色
    //设置标题字体
    [vc.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                      NSFontAttributeName:[UIFont systemFontOfSize:15],
                                                                      }];
    vc.navigationController.navigationBar.translucent = NO;
    [vc.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [vc.navigationController.navigationBar setShadowImage:[UIImage new]];
}

+ (void)loadDataWithSuccess:(SuccessCallback)success
{
    NSString *homeDataPath = [[NSBundle mainBundle] pathForResource:@"HomeData" ofType:@"plist"];
    NSArray *homeArr = [NSArray arrayWithContentsOfFile:homeDataPath];
    
    NSMutableArray *dataSource = [NSMutableArray array];
    NSMutableArray *sectionTitles = [NSMutableArray arrayWithCapacity:homeArr.count];
    
    [homeArr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        CYNHomeSectionModel *sectionModel = [[CYNHomeSectionModel alloc] init];
        sectionModel.sectionTitle = dict[@"sectionTitle"];
        [sectionTitles addObject:dict[@"sectionTitle"]];
        
        NSMutableArray *cellModels = [NSMutableArray array];
        for (NSDictionary *subDict in dict[@"apps"]) {
            CYNHomeCellModel *cellModel = [[CYNHomeCellModel alloc] init];
            cellModel.appId = subDict[@"appId"];
            cellModel.name = subDict[@"name"];
            [cellModels addObject:cellModel];
        }
        
        sectionModel.apps = cellModels;
        [dataSource addObject:sectionModel];
    }];
    
    if (success) {
        success(dataSource, sectionTitles);
    }
    
}

@end
