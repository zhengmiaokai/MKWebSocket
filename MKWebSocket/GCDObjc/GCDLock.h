//
//  GCDLock.h
//  Basic
//
//  Created by zhengmiaokai on 2018/8/14.
//  Copyright © 2018年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDLock : NSObject

- (void)lock:(void(^)(void))block;

@end
