//
//  KXSlideView.h
//  jiuhaohealth4.0
//
//  Created by wangmin on 15/9/15.
//  Copyright © 2015年 wangmin. All rights reserved.
//

#import <UIKit/UIKit.h>

//标题类型枚举
typedef enum _slideTitleType {
    SegmentType = 0,
    NormalType = 1
} slideTitleType;

@protocol SlideViewDelegate <NSObject>

- (void)selPageScrollView:(int)page;

@end

@interface KXSlideView : UIView

@property (nonatomic, assign) id <SlideViewDelegate> delegate;//代理

@property (nonatomic,assign) slideTitleType  theSlideType;//类型

@property (nonatomic,assign) CGFloat   itemWidth;//单个元素的宽度

@property (nonatomic,assign) CGFloat   itemHeight;//单个元素的高度

@property (nonatomic,assign) CGFloat   width_titleBackImageView;//标题下方的线条

@property (nonatomic, assign) BOOL  notResponseToselect;//是否响应点击事件


- (id)initWithFrame:(CGRect)frame  titleScrollViewFrame:(CGRect)titleFrame;

- (void)setTitleArray:(NSArray *)tArray SourcesArray:(NSArray*)sArray SetDefault:(int)index;

//跳转到指定页面
- (void)jumpToPage:(int)page;

//禁止滑动
- (void)forbiddenScorllContentView;
@end
