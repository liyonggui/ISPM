//
//  PhotoBrowserTool.h
//  ISPMIOT
//
//  Created by liyonggui on 2018/12/26.
//  Copyright © 2018年 www.opjtech.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLPhotoBrowser.h"

//#import "ISPMIOT-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoBrowserTool : NSObject

+ (XLPhotoBrowser *)showPhotoBrowserWithCurrentImageIndex: (int)currentImageIndex images: (NSArray *)images delegate: (nullable id<XLPhotoBrowserDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
