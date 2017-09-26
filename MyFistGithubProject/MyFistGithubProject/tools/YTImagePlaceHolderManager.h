//
//  YTImagePlaceHolderManager.h
//  Investor
//
//  Created by 张彦芳 on 2017/9/11.
//  Copyright © 2017年 winjay Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YTImagePlaceHolderManager : NSObject
+ (YTImagePlaceHolderManager *)shareInstance;
    
- (UIImage *)placeholderImageWithSize:(CGSize)outerSize withInnerSize:(CGSize)innerSize withInnerImage:(UIImage *)image withBackgroudColor:(UIColor *)backgroudColor;
- (UIImage *)placeholderImageWithScale:(CGFloat)imageScale withInnerSize:(CGSize)innerSize withInnerImage:(UIImage *)image withBackgroudColor:(UIColor *)backgroudColor;
- (void)clearCache;
@end
