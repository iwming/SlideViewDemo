//
//  ViewController.m
//  SlideViewDemo
//
//  Created by wangmin on 15/9/17.
//  Copyright © 2015年 wangmin. All rights reserved.
//

#import "ViewController.h"
#import "KXSlideView.h"
#import "TestViewController.h"

@interface ViewController ()
<SlideViewDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *titleArray = @[@"VC1",@"VC2",@"VC3"];
    
    TestViewController *vc1 = [[TestViewController alloc] init];
    vc1.view.backgroundColor = [UIColor redColor];
    vc1.textLabel.text = @"vc1";
    
    TestViewController *vc2 = [[TestViewController alloc] init];
    vc2.view.backgroundColor = [UIColor yellowColor];
    vc2.textLabel.text = @"vc2";
    
    TestViewController *vc3 = [[TestViewController alloc] init];
    vc3.view.backgroundColor = [UIColor blueColor];
    vc3.textLabel.text = @"vc3";
    
    NSArray *viewArray = @[vc1,vc2,vc3];
    
    KXSlideView *kxSlideView = [[KXSlideView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, CGRectGetHeight(self.view.bounds)) titleScrollViewFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    kxSlideView.theSlideType = NormalType;//SegmentType 两种模式
    kxSlideView.delegate = self;
    kxSlideView.itemWidth = self.view.frame.size.width/3.0f;
    [kxSlideView setTitleArray:titleArray SourcesArray:viewArray SetDefault:0];
    [self.view addSubview:kxSlideView];
    
    

}


- (void)selPageScrollView:(int)page
{
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
