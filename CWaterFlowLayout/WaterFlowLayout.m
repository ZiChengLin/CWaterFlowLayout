//
//  WaterFlowLayout.m
//  CWaterFlowLayout
//
//  Created by 林梓成 on 15/6/10.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "WaterFlowLayout.h"

@interface WaterFlowLayout ()

@property (nonatomic, assign) NSUInteger numberOfItems;    // item的数量
@property (nonatomic, assign) CGFloat interitemSpacing;    // 列间距

// 用来保存每列的总高度的数组（根据瀑布流的最终列数 数组对象的个数不同）
@property (nonatomic, strong) NSMutableArray *columnHeights;

// 用来保存最终计算出的每个item的数据的数组（数据保存在layoutAttribute对象的各个属性中）
@property (nonatomic, strong) NSMutableArray *itemAttributes;


- (NSInteger)_indexForLongestColumn;   // 返回当前列在columnHeights数组中的索引

- (NSInteger)_indexForShortestColumn;  // 最短列的索引

- (void)_calculateItemPosition;  // 计算每个item所在的列、即每个item在瀑布流中的位置

@end

@implementation WaterFlowLayout


// 懒加载
- (NSMutableArray *)columnHeights {
    
    if (!_columnHeights) {
        
        self.columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (NSMutableArray *)itemAttributes {
    
    if (!_itemAttributes) {
        
        self.itemAttributes = [NSMutableArray array];
    }
    return _itemAttributes;
}


// 获取当前最长列在columnHeights数组中的索引
- (NSInteger)_indexForLongestColumn {
    
    NSInteger index = 0;       // 索引和高度默认都是0
    CGFloat longestHeight = 0;
    
    for (NSInteger i = 0; i < self.columnHeights.count; i++) {
        
        CGFloat currentHeight = [self.columnHeights[i] floatValue];
        if (currentHeight > longestHeight) {
            
            longestHeight = currentHeight;
            index = i;
        }
    }
    return index;
}

/*
   获取当前最短列的索引、columnHeights数组的主要作用是辅助计算，在瀑布流的实现原理中，
   item在布局时应当永远出现在最短列中，以排队为例。在两列的瀑布流界面中，item就像排队一样，
   我们永远选择最短的那个队伍去排。这样可以保证所有列中的item不会出现各个列的高度差太大
 */
- (NSInteger)_indexForShortestColumn {
    
    NSUInteger index = 0;
    CGFloat shortestHeight = MAXFLOAT;
    
    for (int i = 0; i < self.columnHeights.count; i++) {
        
        CGFloat height = [self.columnHeights[i] floatValue];
        if (height < shortestHeight) {
            
            shortestHeight = height;
            index = i;
        }
    }
    return index;
}


#pragma -mark 该方法判断即将出现的item在哪一列里面
- (void)_calculateItemPosition {
    
    // 获取item的总数量（这个数量来源于collectionView的代理对象返回的数目）
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    // 计算出内容视图的有效宽度 减去两个边距
    CGFloat contentWidth = self.collectionView.frame.size.width - self.sectionInsets.left - self.sectionInsets.right;
    
    // 计算item的列边距
    self.interitemSpacing = (contentWidth - self.numberOfColumns * self.itemSize.width)/(self.numberOfColumns - 1);
    NSLog(@"列边距-----%f", self.interitemSpacing);
    
    // 对计算结果向下取整
    self.interitemSpacing = floorf(self.interitemSpacing);
    NSLog(@"-------%f", self.interitemSpacing);
    
    // 根据列数为数组columnHeights添加对象 起初为上边距
    for (NSInteger i = 0; i < self.numberOfColumns; i++) {
        
        // 给每个列高设置默认
        self.columnHeights[i] = @(self.sectionInsets.top);
    }
    
    // 根据item的数量来计算item的大小位置 以及所存在的列
    for (NSInteger i = 0; i < self.numberOfItems; i++) {
        
        // 为每一个item创建对应的indexPath
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        CGFloat itemHeigth = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:waterFlowLayout:heightForItemAtIndexPath:)]) {
            
            // 通过代理对象实现的协议方法来获取每一个item最终的高度
            itemHeigth = [self.delegate collectionView:self.collectionView waterFlowLayout:self heightForItemAtIndexPath:indexPath];
        }
        
        // 根据私有方法获取最短的列的索引
        NSInteger shortestColumnIndex = [self _indexForShortestColumn];
        
        // 计算每个item的x，y轴坐标
        CGFloat delta_x = self.sectionInsets.left + (self.itemSize.width + self.interitemSpacing) * shortestColumnIndex;
        CGFloat delta_y = [self.columnHeights[shortestColumnIndex] floatValue];
        
        // 保存在我们创建的专门用于保存布局的item的相关属性的layoutAttributes对象中
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        // 为layoutAttributes的frame属性赋值
        layoutAttributes.frame = CGRectMake(delta_x, delta_y, self.itemSize.width, itemHeigth);
        // 将得到的layoutAttributes放入对应的数组中
        [self.itemAttributes addObject:layoutAttributes];
        // 需要更新最短列的高度
        self.columnHeights[shortestColumnIndex] = @(delta_y + self.interitemSpacing + itemHeigth);
    }
}

#pragma -mark 准备布局的方法
- (void)prepareLayout{
    
    [super prepareLayout];
    [self _calculateItemPosition];
    
}

/*
   重写collectionViewContentSize方法，根据最长的列的总高度，来确定collectionView的contentSize，（UICollectionView继承自UIScrollView）
   @return 返回最终的高度
 
 */

- (CGSize)collectionViewContentSize{
    // 声明contentSize
    CGSize contentSize = self.collectionView.frame.size;
    
    // 获取最长列的下标得到最长列的高度
    NSInteger longestColumnIndex = [self _indexForLongestColumn];
    
    // 从列长数组中获取最长列高度
    CGFloat longestHeigth = [self.columnHeights[longestColumnIndex] floatValue];
    longestHeigth = longestHeigth - self.interitemSpacing + self.sectionInsets.bottom;
    contentSize.height = longestHeigth;
    return contentSize;
}

/**
 *  重写layoutAttributesForElementsInRect:方法，让集合视图知道每个item从哪里出来
 *
 *  @param rect
 *
 *  @return 返回保存的每个item的atttributes数组
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    return self.itemAttributes;
}


@end
