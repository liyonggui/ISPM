//
//  PhotoBrowserTool.m
//  ISPMIOT
//
//  Created by liyonggui on 2018/12/26.
//  Copyright © 2018年 www.opjtech.com. All rights reserved.
//

#import "PhotoBrowserTool.h"

@implementation PhotoBrowserTool

+ (XLPhotoBrowser *)showPhotoBrowserWithCurrentImageIndex: (int)currentImageIndex images: (NSArray *)images delegate: (nullable id<XLPhotoBrowserDelegate>)delegate {
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:images currentImageIndex:currentImageIndex];
    
    // 设置长按手势弹出的地步ActionSheet数据,不实现此方法则没有长按手势
//    [browser setActionSheetWithTitle:@"请选择操作" delegate:delegate cancelButtonTitle:nil deleteButtonTitle:nil otherButtonTitles: @"保存图片",nil];
    
    // 自定义pageControl的一些属性
    browser.pageDotColor = [UIColor whiteColor]; ///< 此属性针对动画样式的pagecontrol无效
    browser.currentPageDotColor = [UIColor greenColor];
    browser.pageControlStyle = XLPhotoBrowserPageControlStyleClassic;///< 修改底部pagecontrol的样式为系统样式,默认是弹性动画的样式
    return browser;
}

@end
