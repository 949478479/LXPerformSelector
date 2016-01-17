//
//  NSObject+LXPerformSelector.m
//  LXPerformSelector
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

@import UIKit;
@import ObjectiveC.runtime;
#import "NSObject+LXPerformSelector.h"

#pragma clang diagnostic ignored "-Wvarargs"

@implementation NSObject (LXPerformSelector)

- (id)lx_performSelector:(SEL)aSelector, ...
{
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:aSelector];

    if (!methodSignature) {
        __LXFatal(@"-[%s %s]: unrecognized selector sent to instance %p",
                  object_getClassName(self), sel_getName(aSelector), self);
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

    va_list arguments;
    va_start(arguments, aSelector);

    NSUInteger argumentsCount = [methodSignature numberOfArguments];
    for (NSUInteger index = 2; index < argumentsCount; ++index) {

        const char *argumentType = __LXDeleteTypePrefix([methodSignature getArgumentTypeAtIndex:index]);

        switch (argumentType[0]) {
            case ':': // SEL
            case '#': // Class
            case '*': // char *
            case '^': // 其他指针类型
                __LXSetPointerTypeArgument(invocation, index, argumentType, arguments); break;
            case '{': // 结构体类型
                __LXSetStructTypeArgument(invocation, index, argumentType, arguments); break;
            default:  // 基本类型
                __LXSetBaseTypeArgument(invocation, index, argumentType, arguments); break;
        }
    }

    va_end(arguments);

    [invocation setSelector:aSelector];
    [invocation invokeWithTarget:self];

    const char *returnType = __LXDeleteTypePrefix([methodSignature methodReturnType]);

    switch (returnType[0]) {
        case 'v': return nil;
        case ':': // SEL
        case '#': // Class
        case '*': // char *
        case '^': // 其他指针类型
            return __LXGetPointerTypeReturnValue(invocation);
        case '{': // 结构体类型
            return __LXGetStructTypeReturnValue(invocation, returnType);
        default:  // 基本类型
            return __LXGetBaseTypeReturnValue(invocation, returnType);
    }
}

static inline const char *__LXDeleteTypePrefix(const char *typeEncode)
{
    /*
     r const
     n in
     N inout
     o out
     O bycopy
     R byref
     V oneway
     */
    return typeEncode + strspn(typeEncode, "rnNoORV");
}

static inline void __LXSetPointerTypeArgument(NSInvocation *invocation, NSInteger index, const char *argumentType, va_list arguments)
{
    if (strlen(argumentType) > 1 && argumentType[1] == '@') { // ^@ 表示 id *
        id __unsafe_unretained *arg = va_arg(arguments, id __unsafe_unretained *);
        [invocation setArgument:&arg atIndex:index];
    } else { // 各种类型的指针
        void *arg = va_arg(arguments, void *);
        [invocation setArgument:&arg atIndex:index];
    }
}

static inline void __LXSetStructTypeArgument(NSInvocation *invocation, NSInteger index, const char *argumentType, va_list arguments)
{
#define LXSetStructTypeArgument(type) \
    if (!strcmp(argumentType, @encode(type))) { \
    type arg = va_arg(arguments, type); \
    [invocation setArgument:&arg atIndex:index]; \
    return; \
}
    LXSetStructTypeArgument(NSRange);

    LXSetStructTypeArgument(CGSize);
    LXSetStructTypeArgument(CGRect);
    LXSetStructTypeArgument(CGPoint);
    LXSetStructTypeArgument(CGVector);
    LXSetStructTypeArgument(CGAffineTransform);

    LXSetStructTypeArgument(UIOffset);
    LXSetStructTypeArgument(UIEdgeInsets);

    LXSetStructTypeArgument(CATransform3D);

    __LXFatal(@"不支持该结构体类型参数 => %s", argumentType);
}

static inline void __LXSetBaseTypeArgument(NSInvocation *invocation, NSInteger index, const char *argumentType, va_list arguments)
{
#define LXSetBaseTypeArgument(type) { \
    type arg = va_arg(arguments, type); \
    [invocation setArgument:&arg atIndex:index]; \
} return;

    switch (argumentType[0]) {
        case 'f': {
            float arg = va_arg(arguments, double); // 这里用 float 无法取出正常值。。。
            [invocation setArgument:&arg atIndex:index];
        } return;
        case '@': LXSetBaseTypeArgument(id); // id 类型 @ 和闭包类型 @? 本质上都是 id 类型
        case 'd': LXSetBaseTypeArgument(double);
        case 'B': LXSetBaseTypeArgument(bool);
        case 'c': LXSetBaseTypeArgument(char);
        case 'C': LXSetBaseTypeArgument(unsigned char);
        case 's': LXSetBaseTypeArgument(short);
        case 'S': LXSetBaseTypeArgument(unsigned short);
        case 'i': LXSetBaseTypeArgument(int);
        case 'I': LXSetBaseTypeArgument(unsigned int);
        case 'l': LXSetBaseTypeArgument(long);
        case 'L': LXSetBaseTypeArgument(unsigned long);
        case 'q': LXSetBaseTypeArgument(long long);
        case 'Q': LXSetBaseTypeArgument(unsigned long long);
    }

    __LXFatal(@"不支持该类型参数 => %s", argumentType);
}

static inline id __LXGetPointerTypeReturnValue(NSInvocation *invocation)
{
    const void *pointer;
    [invocation getReturnValue:&pointer];
    return [NSValue valueWithPointer:pointer];
}

static inline id __LXGetStructTypeReturnValue(NSInvocation *invocation, const char *returnType)
{
    const char *objCType = NULL;

#define LXReturnStructValue(typeName) \
    objCType = @encode(typeName); \
    if (!strcmp(returnType, objCType)) { \
        typeName structValue; \
        [invocation getReturnValue:&structValue]; \
        return [NSValue valueWithBytes:&structValue objCType:objCType]; \
    }

    LXReturnStructValue(NSRange);

    LXReturnStructValue(CGSize);
    LXReturnStructValue(CGRect);
    LXReturnStructValue(CGPoint);
    LXReturnStructValue(CGVector);
    LXReturnStructValue(CGAffineTransform);

    LXReturnStructValue(UIOffset);
    LXReturnStructValue(UIEdgeInsets);

    LXReturnStructValue(CATransform3D);

    __LXFatal(@"不支持该类型返回值 => %s", returnType);
    return nil;
}

static inline id __LXGetBaseTypeReturnValue(NSInvocation *invocation, const char *returnType)
{
#define LXReturnNumericValue(type) { \
    type numericValue; \
    [invocation getReturnValue:&numericValue]; \
    return @(numericValue); \
}
    switch (returnType[0]) {
        case '@': {
            id __unsafe_unretained object; // 这里不要干扰引用计数，否则会因为过度 release 而崩溃
            [invocation getReturnValue:&object];
            return object;
        }
        case 'B': LXReturnNumericValue(bool);
        case 'f': LXReturnNumericValue(float);
        case 'd': LXReturnNumericValue(double);
        case 'c': LXReturnNumericValue(char);
        case 'C': LXReturnNumericValue(unsigned char);
        case 's': LXReturnNumericValue(short);
        case 'S': LXReturnNumericValue(unsigned short);
        case 'i': LXReturnNumericValue(int);
        case 'I': LXReturnNumericValue(unsigned int);
        case 'l': LXReturnNumericValue(long);
        case 'L': LXReturnNumericValue(unsigned long);
        case 'q': LXReturnNumericValue(long long);
        case 'Q': LXReturnNumericValue(unsigned long long);
    }

    __LXFatal(@"不支持该类型返回值 => %s", returnType);
    return nil;
}

static void __LXFatal(NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:reason
                                 userInfo:nil];
}

@end
