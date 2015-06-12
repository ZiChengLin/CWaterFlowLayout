//
//  MyCollectionViewCell.m
//  CWaterFlowLayout
//
//  Created by 林梓成 on 15/6/10.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

-(UIImageView *)imageView {
    
    if (!_imageView) {
        
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

#pragma -mark 一定要重写该方法 不然会图片出现重影
-(void)layoutSubviews {
    
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
