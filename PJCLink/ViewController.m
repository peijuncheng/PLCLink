//
//  ViewController.m
//  PJCLink
//
//  Created by pei juncheng on 2019/6/10.
//  Copyright © 2019 pei juncheng. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Ext.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    BOOL isFirst;//初次进入页面
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL isScrollDown;
@property (nonatomic, assign) float lastContentOffset;
@end

static NSString *const collectionCellID = @"collectionCell";
static NSString *const tableCellID = @"tableCell";
static NSString * const reuseIdentifierHeader = @"headerCell";

@implementation ViewController

- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width/4, self.view.frame.size.height - 20) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((self.view.width/4*3-40)/3, (self.view.width/4*3-40)/3);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(self.tableView.right, 20, self.view.width/4*3, self.view.height-20) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifierHeader];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self scrollToTopOfSection:indexPath.row animated:YES];
    
}

#pragma mark - 解决带header的collectView滑动不能显示header
- (void)scrollToTopOfSection:(NSInteger)section animated:(BOOL)animated {
    UICollectionViewLayoutAttributes * attr=[self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    UIEdgeInsets insets = self.collectionView.scrollIndicatorInsets;
    CGRect rect = attr.frame;
    rect.size = self.collectionView.frame.size;
    rect.size.height -= insets.top + insets.bottom;
    CGFloat offset = (rect.origin.y + rect.size.height) - self.collectionView.contentSize.height;
    if ( offset > 0.0 ) rect = CGRectOffset(rect, 0, -offset);
    [self.collectionView scrollRectToVisible:rect animated:animated];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 5;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    //当collectionView向上拉拽滚动时（非点击tableView）
    if (!_isScrollDown && collectionView.dragging) {
        [self selectRowAtIndexPath:indexPath.section];
    }
    if (!isFirst) {
        //初次进入默认第一个为选中
        [self selectRowAtIndexPath:0];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    //当collectionView向下拉拽滚动时（非点击tableView）
    if (_isScrollDown && collectionView.dragging) {
        [self selectRowAtIndexPath:indexPath.section + 1];
    }
}

- (void)selectRowAtIndexPath:(NSInteger)index{
    if (!isFirst) {
        isFirst = YES;
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.width/4*3, 45);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
         UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifierHeader forIndexPath:indexPath];
        for (UIView * subview in header.subviews) {
            [subview removeFromSuperview];
        }
        header.backgroundColor = [UIColor greenColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width/4*3, 45)];
        label.text = [NSString stringWithFormat:@"%@%ld",@"   head",indexPath.section];
        [header addSubview:label];
        return header;
    }else{
        return nil;
    }
}

#pragma mark - 判断collectionView的拖拽方向
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        _lastContentOffset = scrollView.contentOffset.y;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.collectionView) {
        if (scrollView.contentOffset.y < _lastContentOffset){
            //向上
            _isScrollDown = NO;
        } else if (scrollView.contentOffset.y > _lastContentOffset){
            //向下
            _isScrollDown = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
