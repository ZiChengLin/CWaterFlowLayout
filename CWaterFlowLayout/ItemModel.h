//
//  ItemModel.h
//  CWaterFlowLayout
//
//  Created by 林梓成 on 15/6/10.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemModel : NSObject

@property (nonatomic, strong) NSString *thumbURLstring;   // 图片地址
@property (nonatomic, assign) float imageWidth;   // 图片宽度
@property (nonatomic, assign) float imageHeight;  // 图片高度

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)itemWithDictionary:(NSDictionary *)dict;

@end
