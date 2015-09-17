//
//  KXSlideView.m
//  jiuhaohealth4.0
//
//  Created by wangmin on 15/9/15.
//  Copyright © 2015年 wangmin. All rights reserved.
//

#import "KXSlideView.h"


#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight ([UIScreen mainScreen].bounds.size.height-64)


#define TextClolor @"ff5232"
#define Color_fafafa @"fafafa"

@interface KXSlideView ()<UIScrollViewDelegate>

@property (nonatomic,retain) UIScrollView *titleScrollView;
@property (nonatomic,retain) UIScrollView *viewScrollView;
@property (nonatomic,retain) NSArray *titlesArray;//标题元素
@property (nonatomic,retain) NSArray *viewsArray;//子View

@property (nonatomic,retain) UIColor *titleNorColor;//字体默认颜色
@property (nonatomic,retain) UIColor *titleSelColor;//字体选中颜色

@property (nonatomic,retain) UIColor *btnNorColor;//按钮默认颜色
@property (nonatomic,retain) UIColor *btnSelColor;//按钮默认颜色

@property (nonatomic,retain) UIButton *lastSelectedBtn;//选中的按钮

@property (nonatomic,retain) UIImageView *titleBackImageView;//红色线条

@end

@implementation KXSlideView

@synthesize titleScrollView,viewScrollView;


+ (UIColor*)colorWithHexString:(NSString*)stringToConvert
{
    NSString* cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6)
        return [UIColor blackColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6)
        return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString* rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString* gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString* bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:1.0f];
}

+ (UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage* theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (id)initWithFrame:(CGRect)frame  titleScrollViewFrame:(CGRect)titleFrame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [KXSlideView colorWithHexString:@"fafafa"];
        self.titleScrollView = [[UIScrollView alloc] initWithFrame:titleFrame];
        self.titleScrollView.showsHorizontalScrollIndicator = NO;
        self.titleScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:titleScrollView];
        
        self.viewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleFrame.size.height, CGRectGetWidth(frame), CGRectGetHeight(frame)- CGRectGetHeight(titleFrame))];
        self.viewScrollView.showsHorizontalScrollIndicator = NO;
        viewScrollView.pagingEnabled = YES;
        viewScrollView.bounces = NO;
        viewScrollView.delegate = self;
        [self addSubview:viewScrollView];
        
    }
    return self;
}

- (void)setTheSlideType:(slideTitleType)theSlideType
{
    _theSlideType = theSlideType;
    if(_theSlideType == SegmentType){
        self.titleNorColor = [KXSlideView colorWithHexString:TextClolor];
        self.titleSelColor = [UIColor whiteColor];
        self.btnNorColor = [KXSlideView colorWithHexString:Color_fafafa];
        self.btnSelColor = [KXSlideView colorWithHexString:TextClolor];
    }else{
        self.titleNorColor = [KXSlideView colorWithHexString:@"333333"];
        self.titleSelColor = [KXSlideView colorWithHexString:TextClolor];
        self.btnNorColor = [KXSlideView colorWithHexString:Color_fafafa];
        self.btnSelColor = [KXSlideView colorWithHexString:Color_fafafa];
        
    }
    
}

- (void)setItemWidth:(CGFloat)itemWidth
{
    _itemWidth = itemWidth;

}

//更新标题尺寸
- (void)resizeTitleScrollViewFrame
{
    //修改titleScrollView的宽度,设置圆角
    _itemWidth = _itemWidth == 0? 90 : _itemWidth;
    titleScrollView.layer.cornerRadius = 4;
    titleScrollView.layer.borderColor = [[KXSlideView colorWithHexString:TextClolor] CGColor];
    titleScrollView.layer.borderWidth = 0.5;
    _itemHeight = _itemHeight == 0 ? 30 : _itemHeight;
    CGRect rect = titleScrollView.frame;
    rect.origin.y = (rect.size.height - _itemHeight)/2.0;
    rect.size.width = _itemWidth*_titlesArray.count;
    rect.size.height = _itemHeight;
    rect.origin.x = (kDeviceWidth-rect.size.width)/2.0;
    titleScrollView.frame = rect;
}


- (void)setTitleArray:(NSArray *)tArray SourcesArray:(NSArray*)sArray SetDefault:(int)index
{
    
    self.titlesArray = tArray;
    self.viewsArray = sArray;
    if(_theSlideType == SegmentType){
        [self getSegmentView:index];
    }else{
        [self getNormalView:index];
    }

}

//得到Segment风格的View
- (void)getSegmentView:(int)index
{
    [self resizeTitleScrollViewFrame];
    
    self.itemHeight = _itemHeight == 0? 30 : _itemHeight;
    CGFloat originY = (titleScrollView.frame.size.height - _itemHeight)/2.0f;
    for(int i = 0; i < _titlesArray.count; i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 10000 + i;
        button.frame = CGRectMake(i*_itemWidth, originY, _itemWidth, _itemHeight);
        [button setTitle:_titlesArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:self.titleNorColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(butSelScrollEvent:) forControlEvents:UIControlEventTouchUpInside];
        [titleScrollView addSubview:button];
        //分隔线
        if (i != _titlesArray.count-1) {
            UIView *viewXian = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x+button.frame.size.width-0.5, 0, 0.5, _itemHeight)];
            viewXian.backgroundColor = [KXSlideView colorWithHexString:TextClolor];
            [titleScrollView addSubview:viewXian];
        }
        
        if(i == index){
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             button.backgroundColor = [KXSlideView colorWithHexString:TextClolor];
            self.lastSelectedBtn = button;
        }
        //内容页
        id item = [self.viewsArray objectAtIndex:i];
        UIView *view = item;
        if ([item isKindOfClass:[UIViewController class]]) {
            view = ((UIViewController*)item).view;
        }
        CGRect rect = view.frame;
        rect.origin.x = i*CGRectGetWidth(self.frame);
        view.frame = rect;
        [self.viewScrollView addSubview:view];
    }
    
    
    viewScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame)*_titlesArray.count, CGRectGetHeight(viewScrollView.frame));
    viewScrollView.contentOffset = CGPointMake(index*CGRectGetWidth(viewScrollView.frame), 0);
 
    if ([_delegate respondsToSelector:@selector(selPageScrollView:)]) {
        [_delegate selPageScrollView:index];
    }
}


//得到正常风格的View
- (void)getNormalView:(int)index
{
    
    self.itemHeight = _itemHeight == 0? 30 : _itemHeight;
    
    if( _titlesArray.count > 5 && _itemWidth == 0){
        
        _itemWidth  = titleScrollView.frame.size.width / 5.0f;
    }
    
    self.width_titleBackImageView = _width_titleBackImageView == 0? 50: _width_titleBackImageView;
    self.titleBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, titleScrollView.frame.size.height - 2, _width_titleBackImageView, 2)];//12偏移
    UIImage *image = [KXSlideView createImageWithColor:[KXSlideView colorWithHexString:TextClolor]];
    self.titleBackImageView.image = image;
    [titleScrollView addSubview:_titleBackImageView];
    
    CGFloat originY = (titleScrollView.frame.size.height - _itemHeight)/2.0f;
    for(int i = 0; i < _titlesArray.count; i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 10000 + i;
        button.frame = CGRectMake(i*_itemWidth, originY, _itemWidth, _itemHeight);
        [button setTitle:_titlesArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:self.titleNorColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(butSelScrollEvent:) forControlEvents:UIControlEventTouchUpInside];
        [titleScrollView addSubview:button];
        
        if(i == index){
            [button setTitleColor:self.titleSelColor forState:UIControlStateNormal];
            button.backgroundColor = self.btnSelColor;
            self.lastSelectedBtn = button;
          
        }
        //内容页
        id item = [self.viewsArray objectAtIndex:i];
        UIView *view = item;
        if ([item isKindOfClass:[UIViewController class]]) {
            view = ((UIViewController*)item).view;
        }
        CGRect rect = view.frame;
        rect.origin.x = i*CGRectGetWidth(self.frame);
        view.frame = rect;
        [self.viewScrollView addSubview:view];
    }
    
    titleScrollView.contentSize = CGSizeMake(_itemWidth*_titlesArray.count, titleScrollView.frame.size.height);

    viewScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame)*_titlesArray.count, CGRectGetHeight(viewScrollView.frame));
    viewScrollView.contentOffset = CGPointMake(index*CGRectGetWidth(viewScrollView.frame), 0);
    
    [self adjusetImageTitleButBackViewXWithButton:_lastSelectedBtn];
    [self adjusetTitleScrollViewButBackViewXWithButtonIndex:index];
    if ([_delegate respondsToSelector:@selector(selPageScrollView:)]) {
        [_delegate selPageScrollView:index];
    }
    
}

//调整标题显示元素的位置
-(void)adjusetTitleScrollViewButBackViewXWithButtonIndex:(int)index
{
    if(_theSlideType == SegmentType){
        return;
    }
    
    UIButton * but = (UIButton*)[titleScrollView viewWithTag:index+10000];
    CGFloat left = but.frame.origin.x+_itemWidth/2.0-titleScrollView.frame.size.width/2.0;
    CGPoint reachPoint;
    CGFloat right = titleScrollView.contentSize.width - (but.frame.origin.x+_itemWidth/2.0+titleScrollView.frame.size.width/2.0);
    if(left > 0 && right > 0){
        reachPoint = CGPointMake(but.frame.origin.x+_itemWidth/2.0-titleScrollView.frame.size.width/2.0, 0);
    }
    else if(left >= 0 && right > 0)
    {
        reachPoint = CGPointMake(but.frame.origin.x+_itemWidth/2.0-titleScrollView.frame.size.width/2.0, 0);
    }
    else if(left < 0){
        reachPoint = CGPointMake(0, 0);
    }else{
        reachPoint = CGPointMake(titleScrollView.contentSize.width-titleScrollView.frame.size.width, 0);
    }
    
    [UIView animateWithDuration:0.30 animations:^{
        [titleScrollView  setContentOffset:reachPoint];
    }];
}

//自定义的下滑横线的位置移动
-(void)adjusetImageTitleButBackViewXWithButton:(UIButton *)btn
{
    if(_theSlideType == SegmentType){
        return;
    }
    self.titleBackImageView.center = CGPointMake(btn.center.x, _titleBackImageView.center.y);
}


//点击响应
- (void)butSelScrollEvent:(UIButton*)but
{
    
    if(self.notResponseToselect == YES){
        return;
    }
    
    if(but.tag == self.lastSelectedBtn.tag){
        
        return;
    }
    
    self.lastSelectedBtn.backgroundColor = self.btnNorColor;
    [self.lastSelectedBtn setTitleColor:self.titleNorColor forState:UIControlStateNormal];
    
    but.backgroundColor = self.btnSelColor;
    [but setTitleColor:self.titleSelColor forState:UIControlStateNormal];

    self.lastSelectedBtn = but;
    int page = (int)but.tag - 10000;
    
    [self adjusetImageTitleButBackViewXWithButton:but];//调整
    [self adjusetTitleScrollViewButBackViewXWithButtonIndex:page];
    
    int scrollPage = viewScrollView.contentOffset.x/CGRectGetWidth(self.frame);
    if (page != scrollPage) {
        [UIView animateWithDuration:0.30 animations:^{
            CGPoint point = viewScrollView.contentOffset;
            point.x = page*CGRectGetWidth(self.frame);
            viewScrollView.contentOffset = point;
        } completion:^(BOOL fi){
            if ([_delegate respondsToSelector:@selector(selPageScrollView:)]) {
                [_delegate selPageScrollView:page];
            }
        }];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = viewScrollView.contentOffset.x/CGRectGetWidth(self.frame);
    self.lastSelectedBtn.backgroundColor = self.btnNorColor;;
    [self.lastSelectedBtn setTitleColor:self.titleNorColor forState:UIControlStateNormal];
    
    UIButton *but = (UIButton*)[titleScrollView viewWithTag:10000+page];
    but.backgroundColor =  self.btnSelColor;
    [but setTitleColor:self.titleSelColor forState:UIControlStateNormal];
    
    [self adjusetImageTitleButBackViewXWithButton:but];//调整

    if ([_delegate respondsToSelector:@selector(selPageScrollView:)]) {
        [_delegate selPageScrollView:page];
    }
    self.lastSelectedBtn = but;
}

//跳转到指定页面
- (void)jumpToPage:(int)page
{
     UIButton *but = (UIButton*)[titleScrollView viewWithTag:10000+page];
    [self butSelScrollEvent:but];
}


//禁止滑动
- (void)forbiddenScorllContentView
{
    viewScrollView.scrollEnabled =  NO;
}


@end
