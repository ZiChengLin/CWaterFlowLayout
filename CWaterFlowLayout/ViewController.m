//
//  ViewController.m
//  CWaterFlowLayout
//
//  Created by 林梓成 on 15/6/10.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "ViewController.h"
#import "ItemModel.h"
#import "MyCollectionViewCell.h"
#import "WaterFlowLayout.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegateWaterFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

/*
 1、一个属性的初始化在该属性的getter方法中写、这就叫做懒加载
 2、因为一个属性的使用前必定会调用它的getter方法
 3、所有把属性的初始化放到getter里面写的好处就是想使用该属性的时候才给它开辟内存空间
 4、这样就不会因为在viewDidLoad里面开辟内存空间而所导致的内存闲置
 */

-(UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        WaterFlowLayout *layout = [[WaterFlowLayout alloc] init];
        
        // 移植到工程中自需要改变下面两行即可
        layout.itemSize = CGSizeMake(170, 90);
        layout.numberOfColumns = 2;
        layout.delegate = self;
        layout.sectionInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        // 创建collectionView对象时必须为其指定layout参数,否则会出现crush
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        
        self.dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:[self collectionView]];   // self collectionView会直接返回一个集合视图
    self.collectionView.backgroundColor = [UIColor blackColor];
    
    // 注册集合视图的cell
    [self.collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    // 根据URL从网络上请求图片数据
    NSURL *url = [NSURL URLWithString:@"http://115.28.227.1/teacher/duke/getAndPostRequest.php?param=imageResource.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 发送一个异步请求 使用Block的形式
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"%@", jsonArray);
        
        for (NSDictionary *dic in jsonArray) {
            
            ItemModel *item = [[ItemModel alloc] initWithDictionary:dic];
            
            [self.dataSource addObject:item];
        }
        
        // 数据解析完成让集合视图重新加载数据
        [self.collectionView reloadData];
    }];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 创建重用队列
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    // 从数组中拿到itemModel对象让cell展示图片
    ItemModel *item = [self.dataSource objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:item.thumbURLstring];
    
    // 使用SDWebImage第三方 直接利用url请求回来的图片进行使用
    [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage new]];
    
    return cell;
}

#pragma -mark 返回每个item的高度的方法（实现协议方法）
- (CGFloat)collectionView:(UICollectionView *)collectionView waterFlowLayout:(WaterFlowLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 把宽度先取出来
    CGFloat width = layout.itemSize.width;
    
    // 根据索引把对应的图片取出来
    ItemModel *item = self.dataSource[indexPath.item];
    
    // 根据请求回来的宽高比 算出在集合视图上的高
    CGFloat height = width * item.imageHeight / item.imageWidth;
    
    return height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
