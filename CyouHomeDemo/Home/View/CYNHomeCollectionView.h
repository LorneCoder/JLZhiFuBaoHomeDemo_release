//
//  CYNHomeCollectionView.h
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/13.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYNHomeCollectionView : UICollectionView

/**实时更新布局的回调*/
@property (nonatomic, copy) void(^layoutSubviewsCallback)(void);

@end
