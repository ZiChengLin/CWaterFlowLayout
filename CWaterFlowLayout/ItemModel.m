//
//  ItemModel.m
//  CWaterFlowLayout
//
//  Created by 林梓成 on 15/6/10.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "ItemModel.h"

@implementation ItemModel

-(id)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        
        self.thumbURLstring = dict[@"thumbURL"];
        self.imageWidth = [dict[@"width"] floatValue];
        self.imageHeight = [dict[@"height"] floatValue];
    }
    return self;
}

+(id)itemWithDictionary:(NSDictionary *)dict {
    
    return [[[self class] alloc]initWithDictionary:dict];
}


@end
