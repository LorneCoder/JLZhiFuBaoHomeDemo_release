//
//  CYNHomeController.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/12.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeController.h"
#import "CYNHomeCell.h"
#import "CYNHomeCellHeader.h"
#import "CYNHomeCategoryHeader.h"
#import "CYNHomeCellModel.h"
#import "CYNHomeSectionModel.h"
#import "CYNHomeCollectionView.h"
#import "JXCategoryView.h"
#import "CYNHomeHelper.h"
#import "CYNHomeHeaderView.h"
#import "CYNHomeNavigaitonView.h"
#import "CYNHomeMyAppsView.h"

static const CGFloat VerticalListCategoryViewHeight = 50;   //悬浮categoryView的高度
static const NSUInteger VerticalListPinSectionIndex = 0;    //悬浮固定section的index

@interface CYNHomeController () <UICollectionViewDelegate, UICollectionViewDataSource, JXCategoryViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) CYNHomeCollectionView *collectionView;
@property (nonatomic, strong) JXCategoryTitleView *pinCategoryView;//分类导航视图
@property (nonatomic, assign) BOOL edit;//列表是否在编辑状态

@property (nonatomic, strong) NSArray <NSString *> *headerTitles;//分类导航视图标题数组
@property (nonatomic, strong) NSArray <CYNHomeSectionModel *> *dataSource;//首页所有应用总数据源
@property (nonatomic, strong) NSMutableArray <CYNHomeCellModel *> *editArray;//头部可编辑的应用数组
@property (nonatomic, strong) NSMutableSet <NSString *> *editIds;//可编辑的应用ID数组

@property (nonatomic, strong) CYNHomeCategoryHeader *sectionCategoryHeaderView;
@property (nonatomic, strong) NSArray <UICollectionViewLayoutAttributes *> *sectionHeaderAttributes;

@property (nonatomic, strong) CYNHomeHeaderView *headerView;//快捷操作区
@property (nonatomic, strong) CYNHomeNavigaitonView *navigationView;//navigation视图
@property (nonatomic, assign) CGFloat myAppsHeight;
@property (nonatomic, strong) CYNHomeMyAppsView *myAppsView;//我的应用视图
@property (nonatomic, assign) CGFloat diffY;//我的应用视图每次高度变化的差值

@end

@implementation CYNHomeController
{
    //被拖拽的item
    CYNHomeCell *_dragingItem;
    //正在拖拽的indexpath
    NSIndexPath *_dragingIndexPath;
    //目标位置
    NSIndexPath *_targetIndexPath;
    
    //顶部底视图
    UIView *_header;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self initSubviews];
    [self loadData];
}

- (void)initSubviews
{
    WeakSelf(self);
    [self.view addSubview:self.collectionView];
    self.collectionView.layoutSubviewsCallback = ^{
        [weakself updateSectionHeaderAttributes];
    };

    //创建pinCategoryView，但是不要被addSubview
    _pinCategoryView = [[JXCategoryTitleView alloc] init];
    self.pinCategoryView.backgroundColor = [UIColor whiteColor];
    self.pinCategoryView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), VerticalListCategoryViewHeight);
    self.pinCategoryView.delegate = self;
    
    //设置状态栏颜色
    [CYNHomeHelper setStatusBarBackgroundColor:[UIColor blackColor]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//状态栏字体颜色设置为白色（需在info.plist中设置“View controller-based status bar appearance”为NO）
    //设置导航栏
    [CYNHomeHelper configNavigationBarWithController:self];
    
    //添加导航视图
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.navigationView];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)loadData
{
    WeakSelf(self);
    [CYNHomeHelper loadDataWithSuccess:^(NSMutableArray *data, NSMutableArray *sectionTitles) {
        
        [sectionTitles removeObjectAtIndex:0];
        weakself.headerTitles = [NSArray arrayWithArray:sectionTitles];
        weakself.pinCategoryView.titles = [NSArray arrayWithArray:sectionTitles];
        
        CYNHomeSectionModel *headerModel = data.firstObject;
        weakself.editArray = [NSMutableArray arrayWithArray:headerModel.apps];
        weakself.editIds = [NSMutableSet set];
        
        for (CYNHomeCellModel *cellModel in self.editArray) {
            [weakself.editIds addObject:cellModel.appId];
        }
        
        self->_myAppsView.appsArray = [NSMutableArray arrayWithArray:headerModel.apps];
        
        //把【我的应用】数据剔除
        [data removeObjectAtIndex:0];
        weakself.dataSource = data;
        
        [weakself.collectionView reloadData];
    }];
}

#pragma mark -
#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CYNHomeSectionModel *sectionModel = self.dataSource[section];
    return sectionModel.apps.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == VerticalListPinSectionIndex) {
            CYNHomeCategoryHeader *categoryHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCategoryHeader" forIndexPath:indexPath];
            self.sectionCategoryHeaderView = categoryHeader;
            
            if (self.pinCategoryView.superview == nil) {
                //首次使用VerticalSectionCategoryHeaderView的时候，把pinCategoryView添加到它上面。
                [categoryHeader addSubview:self.pinCategoryView];
            }
            
            categoryHeader.sectionName = self.headerTitles.firstObject;
            return categoryHeader;
            
        } else {
            CYNHomeCellHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCellHeader" forIndexPath:indexPath];
            CYNHomeSectionModel *sectionModel = self.dataSource[indexPath.section];
            
            [header setHeaderTitle:sectionModel.sectionTitle subTitle:@""];
            return header;
        }
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYNHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CYNHomeCell" forIndexPath:indexPath];
    CYNHomeSectionModel *sectionModel = self.dataSource[indexPath.section];
    CYNHomeCellModel *model = sectionModel.apps[indexPath.row];
    cell.title = model.name;
    
    if (self.edit) {
        cell.isEdit = YES;
        if ([self.editIds containsObject:model.appId]) {
            //设置编辑符合为减号
            cell.isAdd = NO;
        } else {
            cell.isAdd = YES;
        }
    } else {
        cell.isEdit = NO;
    }
    
    [cell setEditCallback:^(BOOL isAdd) {
        [self setEditResultWithAdd:isAdd model:model];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYNHomeSectionModel *sectionModel = self.dataSource[indexPath.section];
    CYNHomeCellModel *model = sectionModel.apps[indexPath.row];
    NSLog(@"点击了：%@", model.name);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == VerticalListPinSectionIndex) {
        //categoryView所在的headerView要高一些
        return CGSizeMake(self.view.bounds.size.width, VerticalListCategoryViewHeight + 40);
    }
    return CGSizeMake(self.view.bounds.size.width, 40);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    //NSLog(@"%f", contentOffsetY);
    
    //设置快捷键和导航视图渐变
    [self setNavigationViewAlpha:contentOffsetY scrollView:scrollView];
    //设置【我的应用】悬浮固定
    [self setMyAppsFixed:contentOffsetY scrollView:scrollView];
    //设置分类导航条悬浮固定
    [self setCategoryMenuFixed:contentOffsetY scrollView:scrollView];
}

/**设置快捷键和导航视图渐变*/
- (void)setNavigationViewAlpha:(CGFloat)contentOffsetY scrollView:(UIScrollView *)scrollView
{
    //scrollView的初始顶点值
    CGFloat top = scrollView.contentInset.top;
    //渐变的临界值
    CGFloat scale = kHomeKuaiJieJian_Height / 2.0;
    
    [self.headerView setHeaderViewAlpha:top contentOffsetY:contentOffsetY];
    self.navigationView.hidden = contentOffsetY < (scale - top);
    if (contentOffsetY > (kHomeKuaiJieJian_Height - top)) {
        //向上滚动距离超过了快捷区域的高度，显示导航栏缩略图
        self.navigationView.alpha = 1;
        self.title = @"";
    } else if (contentOffsetY > (scale - top)) {
        //向上滚动距离，大于快捷区高度的一半，开始设置渐变
        self.navigationView.alpha = 1 - (kHomeKuaiJieJian_Height - top - contentOffsetY) / scale;
    } else if (contentOffsetY < 10 - top) {
        self.title = @"首页";
    }
}

/**设置【我的应用】悬浮固定*/
- (void)setMyAppsFixed:(CGFloat)contentOffsetY scrollView:(UIScrollView *)scrollView
{
    //scrollView的初始顶点值
    CGFloat top = scrollView.contentInset.top;

    if (contentOffsetY >= (kHomeKuaiJieJian_Height - top)) {
        if (_myAppsView.superview != self.view) {
            _myAppsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), _myAppsHeight);
            [self.view addSubview:_myAppsView];
        }
    } else if (_myAppsView.superview != _header) {
        _myAppsView.frame = CGRectMake(0, kHomeKuaiJieJian_Height, CGRectGetWidth(self.view.frame), _myAppsHeight);
        [_header addSubview:_myAppsView];
    }
}

/**设置分类导航条悬浮固定*/
- (void)setCategoryMenuFixed:(CGFloat)contentOffsetY scrollView:(UIScrollView *)scrollView
{
    //UICollectionViewLayoutAttributes *attri = self.sectionHeaderAttributes[VerticalListPinSectionIndex];
    CGFloat topY = scrollView.contentInset.top;
    
    if (contentOffsetY >= kHomeKuaiJieJian_Height - topY) {
        //当滚动的contentOffset.y大于了指定sectionHeader的y值，且还没有被添加到self.view上的时候，就需要切换superView
        if (self.pinCategoryView.superview != self.view) {
            self.pinCategoryView.frame = CGRectMake(0, _myAppsHeight, CGRectGetWidth(self.view.frame), VerticalListCategoryViewHeight);
            [self.view addSubview:self.pinCategoryView];
        }
    } else if (self.pinCategoryView.superview != self.sectionCategoryHeaderView) {
        //当滚动的contentOffset.y小于了指定sectionHeader的y值，且还没有被添加到sectionCategoryHeaderView上的时候，就需要切换superView
        self.pinCategoryView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), VerticalListCategoryViewHeight);
        [self.sectionCategoryHeaderView addSubview:self.pinCategoryView];
    }
    
    if (!(scrollView.isTracking || scrollView.isDecelerating)) {
        //不是用户滚动的，比如setContentOffset等方法，引起的滚动不需要处理。
        return;
    }
    
    //用户滚动的才处理
    //获取categoryView下面一点的所有布局信息，用于知道，当前最上方是显示的哪个section
    CGRect topRect = CGRectMake(0, scrollView.contentOffset.y + VerticalListCategoryViewHeight + 1 + _myAppsHeight, self.view.bounds.size.width, 1);
    UICollectionViewLayoutAttributes *topAttributes = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:topRect].firstObject;
    NSUInteger topSection = topAttributes.indexPath.section;
    
    if (topAttributes != nil && topSection >= VerticalListPinSectionIndex) {
        if (self.pinCategoryView.selectedIndex != topSection - VerticalListPinSectionIndex) {
            //不相同才切换
            [self.pinCategoryView selectItemAtIndex:topSection - VerticalListPinSectionIndex];
        }
    }
}

#pragma mark - JXCategoryViewDelegate

- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index
{
    //这里关心点击选中的回调！！！
    UICollectionViewLayoutAttributes *targetAttri = self.sectionHeaderAttributes[index + VerticalListPinSectionIndex];
    if (index == 0) {
        //选中了第一个，特殊处理一下，滚动到sectionHeaer的最上面
        [self.collectionView setContentOffset:CGPointMake(0, targetAttri.frame.origin.y - _myAppsHeight) animated:YES];
    } else {
        //不是第一个，需要滚动到categoryView下面
        [self.collectionView setContentOffset:CGPointMake(0, targetAttri.frame.origin.y - VerticalListCategoryViewHeight - _myAppsHeight) animated:YES];
    }
}

#pragma mark -
#pragma mark - 用户交互

/**是否处于编辑状态的处理*/
- (void)setEditStatus:(BOOL)isAppEdit
{
    if (isAppEdit) {
        if (!self.edit) {
            //编辑状态
            self.edit = YES;
            [self.collectionView reloadData];
            self.navigationItem.rightBarButtonItem = self.rightBarButton;
            
            //告诉【我的应用】VC，调起编辑状态
            [self.myAppsView setEditConfig];
        }
    } else {
        if (self.edit) {
            //正常状态
            self.edit = NO;
            [self.collectionView reloadData];
            self.navigationItem.rightBarButtonItem = nil;
            
            //告诉【我的应用】VC，恢复正常状态
            [self.myAppsView setNormalStateConfig];
        }
    }
}

- (void)saveClicked
{
    [self setEditStatus:NO];
}

- (void)longPressMethod:(UILongPressGestureRecognizer*)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self setEditStatus:YES];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - private method

/**设置编辑结果*/
- (void)setEditResultWithAdd:(BOOL)isAdd model:(CYNHomeCellModel *)model
{
    NSLog(@"isAdd : %d, name : %@", isAdd, model.name);
    
    if (isAdd) {
        //添加
        if ([self.editIds containsObject:model.appId]) {
            return;
        }
        
        //最多可以添加8个
        if (self.myAppsView.appsArray.count >= 8) {
            NSLog(@"最多可以添加8个应用");
            return;
        }
        
        [self.editIds addObject:model.appId];
        [self.editArray addObject:model];
        //【我的应用】appsArray 需要与self.editArray保持一致
        self.myAppsView.appsArray = self.editArray;
        
        [self.collectionView reloadData];
        
    } else {
        //删除
        if (![self.editIds containsObject:model.appId]) {
            return;
        }
        
        //最少要留一个应用
        if (self.myAppsView.appsArray.count <= 1) {
            NSLog(@"最少要留一个应用");
            return;
        }
        
        [self.editIds removeObject:model.appId];
        [self.editArray enumerateObjectsUsingBlock:^(CYNHomeCellModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.appId isEqualToString:model.appId]) {
                [self.editArray removeObject:obj];
                
                self.myAppsView.appsArray = self.editArray;
                [self.collectionView reloadData];
                *stop = YES;
            }
        }];
    }
    
    //每次添加或删除应用，会影响sectionHeaderAttributes，这时将sectionHeaderAttributes置空，重新获取；
    self.sectionHeaderAttributes = nil;
}

#pragma mark - 垂直列表滚动相关

- (void)updateSectionHeaderAttributes
{
    if (self.sectionHeaderAttributes == nil) {
        NSLog(@"编辑完，重新获取最新的sectionHeaderAtrributes");
        
        //获取到所有的sectionHeaderAtrributes，用于后续的点击，滚动到指定contentOffset.y使用
        NSMutableArray *attributes = [NSMutableArray array];
        UICollectionViewLayoutAttributes *lastHeaderAttri = nil;
     
        for (int i = 0; i < self.headerTitles.count; i++) {
            UICollectionViewLayoutAttributes *attri = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
            if (attri) {
                [attributes addObject:attri];
            }
            if (i == self.headerTitles.count - 1) {
                lastHeaderAttri = attri;
            }
        }
        
        if (attributes.count == 0) {
            return;
        }
        self.sectionHeaderAttributes = attributes;
        
        //如果最后一个section条目太少了，会导致滚动最底部，但是却不能触发categoryView选中最后一个item。而且点击最后一个滚动的contentOffset.y也不要弄。所以添加contentInset，让最后一个section滚到最下面能显示完整个屏幕。
        UICollectionViewLayoutAttributes *lastCellAttri = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource[self.headerTitles.count - 1].apps.count - 1 inSection:self.headerTitles.count - 1]];
        CGFloat lastSectionHeight = CGRectGetMaxY(lastCellAttri.frame) - CGRectGetMinY(lastHeaderAttri.frame);
        
        CGFloat value = (self.view.bounds.size.height - VerticalListCategoryViewHeight) - lastSectionHeight;
        if (value > 0) {
            //因为初始化时设置了collectionView的contentInset，所以这里要设置对应的值
            self.collectionView.contentInset = UIEdgeInsetsMake(_myAppsHeight + kHomeKuaiJieJian_Height, 0, 65 + value - _myAppsHeight, 0);
        }
    }
}

#pragma mark -
#pragma mark - setting && getting

- (CYNHomeCollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat superWidth = CGRectGetWidth(self.view.bounds);
        
        CGFloat cellWidth = (superWidth - (HomeColumnNumber - 1) * HomeCellMarginX) / HomeColumnNumber;
        flowLayout.itemSize = CGSizeMake(cellWidth , cellWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(1, 0, 0, 0);
        flowLayout.minimumLineSpacing = HomeCellMarginY;
        flowLayout.minimumInteritemSpacing = HomeCellMarginX;
        
        _collectionView = [[CYNHomeCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
        longPress.minimumPressDuration = 0.3f;
        [_collectionView addGestureRecognizer:longPress];
        
        _dragingItem = [[CYNHomeCell alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth)];
        _dragingItem.hidden = YES;
        [_collectionView addSubview:_dragingItem];
        
        //给collectionView添加子控件 这里是作为头部 记得设置y轴为负值
        _header = [[UIView alloc] init];
        _header.backgroundColor = [UIColor colorWithHexString:@"#28272B"];
        
        //添加【快捷操作区】
        [_header addSubview:self.headerView];
        //添加【我的应用】
        [_header addSubview:self.myAppsView];
        
        [_collectionView addSubview:_header];
    }
    return _collectionView;
}

- (UIBarButtonItem *)rightBarButton
{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveClicked)];
    }
    return _rightBarButton;
}

- (CYNHomeHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[CYNHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHomeKuaiJieJian_Height)];
    }
    return _headerView;
}

- (CYNHomeNavigaitonView *)navigationView
{
    if (!_navigationView) {
        _navigationView = [[CYNHomeNavigaitonView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        _navigationView.hidden = YES;
    }
    return _navigationView;
}

- (CYNHomeMyAppsView *)myAppsView
{
    if (!_myAppsView) {
        _myAppsView = [[CYNHomeMyAppsView alloc] cyn_initWithFrame:CGRectMake(0, kHomeKuaiJieJian_Height, CGRectGetWidth(self.view.frame), _myAppsHeight)];
        WeakSelf(self);
        [_myAppsView setViewHeightBlock:^(CGFloat viewHeight) {
            weakself.myAppsHeight = viewHeight;
        }];
        
        [_myAppsView setAppEditBlock:^(BOOL appIsEdit) {
            [weakself setEditStatus:appIsEdit];
        }];
        
        [_myAppsView setDeletaAppBlock:^(CYNHomeCellModel *model) {
            [weakself setEditResultWithAdd:NO model:model];
        }];
    }
    return _myAppsView;
}

- (void)setMyAppsHeight:(CGFloat)myAppsHeight
{
    //NSLog(@"myAppsHeight ==== %.f", myAppsHeight);
    _myAppsHeight = myAppsHeight;
    
    CGFloat myappY;
    if (_myAppsView.superview == self.view) {
        myappY = 0;
    } else {
        myappY = kHomeKuaiJieJian_Height;
    }
    
    WeakSelf(self);
    //我的应用区域frame设置，collectionView相关设置
    [UIView animateWithDuration:0.5f animations:^{
        self->_myAppsView.frame = CGRectMake(0, myappY, CGRectGetWidth(weakself.view.frame), self->_myAppsHeight);
        self->_header.frame = CGRectMake(0, -(self->_myAppsHeight + kHomeKuaiJieJian_Height), CGRectGetWidth(self.view.frame), self->_myAppsHeight + kHomeKuaiJieJian_Height);

        weakself.collectionView.contentInset = UIEdgeInsetsMake(self->_myAppsHeight + kHomeKuaiJieJian_Height, 0, self->_myAppsHeight + kHomeKuaiJieJian_Height, 0);
    }];
    
    CGFloat contentOffsetY = self.collectionView.contentOffset.y;
    CGFloat y = _myAppsHeight - _diffY; //大于0， contentOffsetY设置减小
    CGFloat topY = self.collectionView.contentInset.top;

    //横向分类导航frame设置
    if (self.pinCategoryView.superview == self.view) {
        [UIView animateWithDuration:0.5f animations:^{
            weakself.pinCategoryView.frame = CGRectMake(0, self->_myAppsHeight, CGRectGetWidth(weakself.view.frame), VerticalListCategoryViewHeight);
            weakself.collectionView.contentOffset = CGPointMake(0, contentOffsetY - y);
        }];
        
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            weakself.pinCategoryView.frame = CGRectMake(0, 0, CGRectGetWidth(weakself.view.frame), VerticalListCategoryViewHeight);
            [weakself.collectionView setContentOffset:CGPointMake(0, -topY) animated:NO];
        }];
    }
    
    _diffY = _myAppsHeight;
    //需要加判断，第一次打开页面的时候调用一次；
    if (self.edit) {
        //如果是由于添加或删除应用造成的myAppsHeight改变，就过滤掉
        return;
    }
    //为了解决第一次进入页面时，在iPhone5s小屏幕手机上，collectionView初始位置上滑的bug
    [self.collectionView setContentOffset:CGPointMake(0, -topY) animated:YES];
}


@end
