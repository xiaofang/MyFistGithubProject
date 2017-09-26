//
//  YTImagePlaceHolderManager.m
//  Investor
//
//  Created by 张彦芳 on 2017/9/11.
//  Copyright © 2017年 winjay Lu. All rights reserved.
//

#import "YTImagePlaceHolderManager.h"
#define __MainScreenFrame   [[UIScreen mainScreen] bounds]
#define __MainScreen_Width  ((__MainScreenFrame.size.width)<(__MainScreenFrame.size.height)?(__MainScreenFrame.size.width):(__MainScreenFrame.size.height))
#define __MainScreen_Height ((__MainScreenFrame.size.height)>(__MainScreenFrame.size.width)?(__MainScreenFrame.size.height):(__MainScreenFrame.size.width))

@interface YTImagePlaceHolderManager()
@property (nonatomic, strong) NSMutableDictionary *cachePlaceholderImages;
@end

@implementation YTImagePlaceHolderManager
+ (YTImagePlaceHolderManager *)shareInstance {
    static YTImagePlaceHolderManager *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc]init];
    });
    return staticInstance;
}
    
- (void)clearCache {
    [self.cachePlaceholderImages removeAllObjects];
}
    
- (NSMutableDictionary *)cachePlaceholderImages {
    if (!_cachePlaceholderImages) {
        _cachePlaceholderImages = [[NSMutableDictionary alloc]init];
    }
    return _cachePlaceholderImages;
}
- (UIImage *)placeholderImageWithScale:(CGFloat)imageScale withInnerSize:(CGSize)innerSize withInnerImage:(UIImage *)image withBackgroudColor:(UIColor *)backgroudColor{
    UIImage *placeHolderImage = nil;
    if(imageScale > 0){
        CGFloat imgWidth = __MainScreen_Width;
        CGFloat imgHeight = imgWidth *(1.f/imageScale);
        CGSize  outSize = CGSizeMake(imgWidth, imgHeight);
        placeHolderImage = [self placeholderImageWithSize:outSize withInnerSize:CGSizeZero withInnerImage:nil withBackgroudColor:nil];
    }
    return placeHolderImage;
}
- (UIImage *)placeholderImageWithSize:(CGSize)outerSize withInnerSize:(CGSize)innerSize withInnerImage:(UIImage *)image withBackgroudColor:(UIColor *)backgroudColor {
    
    if (CGSizeEqualToSize(outerSize,CGSizeZero)) {
        return nil;
    }
    
    if (!image) {
        image = [UIImage imageNamed:@"maillogo"];
    }
    if (!backgroudColor) {
        backgroudColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    }
    if (CGSizeEqualToSize(innerSize,CGSizeZero)) {
        innerSize = CGSizeMake(50, 50);
    }
    
    NSString *key = [self keyString:outerSize innnerSize:innerSize color:backgroudColor];
    if ([[self.cachePlaceholderImages allKeys]containsObject:key]) {
        return self.cachePlaceholderImages[key];
    }else {
        UIGraphicsBeginImageContext(outerSize);
        
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        //填充颜色
        CGContextSetFillColorWithColor(contextRef, backgroudColor.CGColor);
        CGContextFillRect(contextRef, CGRectMake(0,0,outerSize.width,outerSize.height));
        //logo放中间
        [image drawInRect:CGRectMake((outerSize.width - innerSize.width)/2.0,(outerSize.height - innerSize.height)/2.0,innerSize.width,innerSize.height)];
        //生成新图片
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        if (newImage) {
            [self.cachePlaceholderImages setObject:newImage forKey:key];
        }
        return newImage;
    }
}
- (NSString *)keyString:(CGSize)bigSize innnerSize:(CGSize)innerSize color:(UIColor *)color {
    return [NSString stringWithFormat:@"%f_%f_%f_%f_%@",bigSize.width,bigSize.height,innerSize.width,innerSize.height,color];
}
@end
