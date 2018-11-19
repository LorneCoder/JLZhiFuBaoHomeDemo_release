//
//  UIColor+Extension.m
//  JLB
//
//  Created by andehang on 15/3/31.
//  Copyright (c) 2015年 zhongkefuchuang. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)
/**
 *  @brief  没有alph的色值转换
 *
 *  @param rgb rgb颜色值
 *
 *  @return 根据rgb生成的UIColor对象
 */
+ (UIColor *)colorWithRGB:(NSInteger)rgb
{
    CGFloat r = ((rgb >> 16) & 0xff) /255.0f;
    CGFloat g = ((rgb >> 8) & 0xff) /255.0f;
    CGFloat b = ((rgb >> 0) & 0xff) /255.0f;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
    
    return color;
}

/**
 *  @brief  带有alph的色值转换
 *
 *  @param rgba rgba颜色值
 *
 *  @return 根据rgba生成的UIColor对象
 */
+ (UIColor *)colorWithRGBA:(NSInteger)rgba
{
    CGFloat r = ((rgba >> 24) & 0xff) /255.0f;
    CGFloat g = ((rgba >> 16) & 0xff) /255.0f;
    CGFloat b = ((rgba >> 8) & 0xff) /255.0f;
    CGFloat a = ((rgba >> 0) & 0xff) /255.0f;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    return color;
}

/**
 *  @brief  rgba的随机色
 *
 *  @return 生成rgba的随机色UIColor对象
 */
+ (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(255) /255.0f;
    CGFloat g = arc4random_uniform(255) /255.0f;
    CGFloat b = arc4random_uniform(255) /255.0f;
    CGFloat a = arc4random_uniform(255) /255.0f;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    return color;
}

/**
 *  @brief  十六进制的表示颜色字的符串转换为UIColor
 *
 *  @param hexString 十六进制的颜色字符串
 *
 *  @return 转换好的UIColor对象
 */
+ (UIColor *) colorWithHexString: (NSString *)hexString
{
    
    NSString *cString = hexString;
    
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    if ([cString hasPrefix:@"0X"] || [cString hasPrefix:@"0x"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}




@end
