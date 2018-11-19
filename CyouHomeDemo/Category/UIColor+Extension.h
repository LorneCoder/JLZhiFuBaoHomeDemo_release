//
//  UIColor+Extension.h
//  JLB
//
//  Created by andehang on 15/3/31.
//  Copyright (c) 2015年 zhongkefuchuang. All rights reserved.
//  十六进制颜色转换，将给出的十六进制颜色值传入参数即可
//  eg:色值#ffbbee 传入0xffbbee, 色值为#ffbbeeaa 传入0xffbbeeaa

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

/**
 *带有alph的色值转换
 */
+ (UIColor *)colorWithRGBA:(NSInteger)rgba;

/**
 *没有alph的色值转换
 */
+ (UIColor *)colorWithRGB:(NSInteger)rgb;

/**
 *rgba的随机色
 */
+ (UIColor *)randomColor;

/**
 *   十六进制的表示颜色字的符串转换为UIColor
 */
+ (UIColor *) colorWithHexString: (NSString *)hexString;

@end
