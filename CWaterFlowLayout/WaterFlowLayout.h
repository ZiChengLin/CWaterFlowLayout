//
//  WaterFlowLayout.h
//  CWaterFlowLayout
//
//  Created by 林梓成 on 15/6/10.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import <UIKit/UIKit.h>

// 协议 （获取每个item的高度）
@class WaterFlowLayout;
@protocol UICollectionViewDelegateWaterFlowLayout <UICollectionViewDelegate>

// 返回item的高度 （参数1表示返回的item高度在哪一个集合视图中使用 参数2是按照什么样的布局来返回高度 参数3表示返回的是第几个item的高度）
- (CGFloat)collectionView:(UICollectionView *)collectionView waterFlowLayout:(WaterFlowLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface WaterFlowLayout : UICollectionViewLayout

@property (nonatomic, assign)NSUInteger numberOfColumns;    // 瀑布流的列数
@property (nonatomic, assign)CGSize itemSize;               // 每个item的大小
@property (nonatomic, assign)UIEdgeInsets sectionInsets;    // 四个间距

@property (nonatomic, assign)id<UICollectionViewDelegateWaterFlowLayout>delegate;

@end
