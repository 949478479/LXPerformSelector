//
//  NSObject+LXPerformSelector.h
//  LXPerformSelector
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

@import Foundation;

@protocol LXPerformSelector
@optional
- (_Nullable id)lx_performSelector:(_Nonnull SEL)aSelector, ...;
+ (_Nullable id)lx_performSelector:(_Nonnull SEL)aSelector, ...;
@end

@interface NSObject (LXPerformSelector) <LXPerformSelector>
@end
