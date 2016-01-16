//
//  NSObject+LXPerformSelector.h
//  LXPerformSelector
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LXPerformSelector)

- (id)lx_performSelector:(SEL)aSelector, ...;

@end
