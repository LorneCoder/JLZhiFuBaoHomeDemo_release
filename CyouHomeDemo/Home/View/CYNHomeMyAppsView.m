//
//  CYNHomeMyAppsView.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/15.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeMyAppsView.h"
#import "CYNHomeCell.h"
#import "CYNHomeCellHeader.h"

#define kHeader_Height          40
#define kFooter_Height          10

@interface CYNHomeMyAppsView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) CGFloat cellHeight;
/**是否为编辑状态*/
@property (nonatomic, assign) BOOL edit;

@end

@implementation CYNHomeMyAppsView
{
    //被拖拽的item
    CYNHomeCell *_dragingItem;
    //正在拖拽的indexpath
    NSIndexPath *_dragingIndexPath;
    //目标位置
    NSIndexPath *_targetIndexPath;
}

- (instancetype)cyn_initWithFrame:(CGRect)frame
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat superWidth = CGRectGetWidth(frame);
    
    CGFloat cellWidth = (superWidth - (HomeColumnNumber - 1) * HomeCellMarginX) / HomeColumnNumber;
    flowLayout.itemSize = CGSizeMake(cellWidth , cellWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(1, 0, 0, 0);
    flowLayout.minimumLineSpacing = HomeCellMarginY;
    flowLayout.minimumInteritemSpacing = HomeCellMarginX;
    flowLayout.headerReferenceSize = CGSizeMake(frame.size.width, kHeader_Height);
    
    self.cellHeight = cellWidth;
    
    return [self initWithFrame:frame collectionViewLayout:flowLayout];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        
        self.showsHorizontalScrollIndicator = false;
        self.backgroundColor = [UIColor colorWithHexString:@"#E7E7E7"];
        [self registerClass:[CYNHomeCell class] forCellWithReuseIdentifier:@"CYNHomeCell"];
        [self registerClass:[CYNHomeCellHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCellHeader"];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
        longPress.minimumPressDuration = 0.3f;
        [self addGestureRecognizer:longPress];
        
        _dragingItem = [[CYNHomeCell alloc] initWithFrame:CGRectMake(0, 0, self.cellHeight, self.cellHeight)];
        _dragingItem.hidden = YES;
        [self addSubview:_dragingItem];
    }
    return self;
}

- (void)longPressMethod:(UILongPressGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self setEditConfig];
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}

/**编辑状态下的配置*/
- (void)setEditConfig
{
    if (!self.edit) {
        self.edit = YES;
        [self reloadData];
        
        //告诉外层VC，刷新列表
        if (self.appEditBlock) {
            self.appEditBlock(_edit);
        }
    }
}

/**常规状态下的配置*/
- (void)setNormalStateConfig
{
    if (self.edit) {
        self.edit = NO;
        [self reloadData];
    }
}

//拖拽开始 找到被拖拽的item
- (void)dragBegin:(CGPoint)point
{
    _dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!_dragingIndexPath) {
        return;
    }
    [self bringSubviewToFront:_dragingItem];
    
    CYNHomeCell *item = (CYNHomeCell *)[self cellForItemAtIndexPath:_dragingIndexPath];
    item.isMoving = YES;
    //更新被拖拽的item
    _dragingItem.hidden = NO;
    _dragingItem.frame = item.frame;
    _dragingItem.title = item.title;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
}

//正在被拖拽
- (void)dragChanged:(CGPoint)point
{
    if (!_dragingIndexPath) {
        return;
    }
    _dragingItem.center = point;
    _targetIndexPath = [self getTargetIndexPathWithPoint:point];
    //交换位置 如果没有找到_targetIndexPath则不交换位置
    if (_dragingIndexPath && _targetIndexPath) {
        //更新数据源
        [self rearrangeInUseTitles];
        //更新item位置
        [self moveItemAtIndexPath:_dragingIndexPath toIndexPath:_targetIndexPath];
        _dragingIndexPath = _targetIndexPath;
    }
}

//拖拽结束
- (void)dragEnd
{
    if (!_dragingIndexPath) {
        return;
    }
    CGRect endFrame = [self cellForItemAtIndexPath:_dragingIndexPath].frame;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_dragingItem.frame = endFrame;
    }completion:^(BOOL finished) {
        self->_dragingItem.hidden = true;
        CYNHomeCell *item = (CYNHomeCell *)[self cellForItemAtIndexPath:self->_dragingIndexPath];
        item.isMoving = NO;
    }];
}

/**获取被拖动IndexPath的方法*/
- (NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath *dragIndexPath = nil;
    //最后剩一个不可以排序
    if ([self numberOfItemsInSection:0] == 1) {
        return dragIndexPath;
    }
    for (NSIndexPath *indexPath in self.indexPathsForVisibleItems) {
        //下半部分不需要排序
        if (indexPath.section > 0) {continue;}
        //在上半部分中找出相对应的Item
        if (CGRectContainsPoint([self cellForItemAtIndexPath:indexPath].frame, point)) {
            dragIndexPath = indexPath;
            break;
        }
    }
    return dragIndexPath;
}

/**获取目标IndexPath的方法*/
- (NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in self.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:_dragingIndexPath]) {continue;}
        //第二组不需要排序
        if (indexPath.section > 0) {continue;}
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([self cellForItemAtIndexPath:indexPath].frame, point)) {
            targetIndexPath = indexPath;
        }
    }
    return targetIndexPath;
}

/**拖拽排序后需要重新排序数据源*/
-(void)rearrangeInUseTitles
{
    CYNHomeCellModel *model = [self.appsArray objectAtIndex:_dragingIndexPath.row];
    [self.appsArray removeObject:model];
    [self.appsArray insertObject:model atIndex:_targetIndexPath.row];
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.appsArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        CYNHomeCellHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCellHeader" forIndexPath:indexPath];
        [header setHeaderTitle:@"我的应用" subTitle:@"(长按可拖动排序)"];
        return header;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYNHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CYNHomeCell" forIndexPath:indexPath];
    CYNHomeCellModel *model = self.appsArray[indexPath.row];
    cell.title = model.name;
    
    cell.isAdd = NO;
    if (self.edit) {
        cell.isEdit = YES;
    } else {
        cell.isEdit = NO;
    }
    
    WeakSelf(self);
    [cell setEditCallback:^(BOOL isAdd) {
        if (!isAdd) {
            [weakself deleteAppAction:model];
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYNHomeCellModel *model = self.appsArray[indexPath.row];
    NSLog(@"点击了：%@", model.name);
}

/**删除应用*/
- (void)deleteAppAction:(CYNHomeCellModel *)model
{
    NSLog(@"删除了 %@", model.name);
    if (self.deletaAppBlock) {
        self.deletaAppBlock(model);
    }
}

#pragma mark - setter

- (void)setAppsArray:(NSMutableArray *)appsArray
{
    _appsArray = appsArray;
    
    CGFloat viewH = 0.0;
    NSInteger count = appsArray.count;
    if (count > 0) {
        if (count <= 4) {
            viewH = kHeader_Height + HomeCellMarginY + self.cellHeight + kFooter_Height;
        } else if (count <= 8) {
            viewH = kHeader_Height + HomeCellMarginY * 2 + self.cellHeight * 2 + kFooter_Height;
        } else {
            //to do...
        }
    } else {
        viewH = 0;
    }
    
    if (self.viewHeightBlock) {
        self.viewHeightBlock(viewH);
        [self reloadData];
    }
}

@end
