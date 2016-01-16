//
//  NSObject+LXPerformSelector.m
//  LXPerformSelector
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

@import ObjectiveC.runtime;
#import "NSObject+LXPerformSelector.h"

@implementation NSObject (LXPerformSelector)

- (id)lx_performSelector:(SEL)aSelector, ...
{
    va_list arguments;
    va_start(arguments, aSelector);

    NSMethodSignature *methodSignature = [self methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

    NSUInteger argumentsCount = [methodSignature numberOfArguments];
    for (NSUInteger index = 2; index < argumentsCount; ++index) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:index];;

        // r 开头表示 const 类型，例如 const int 表示为 ri，const int * 表示为 r^i，const int * const * 表示为 r^^i
        if (argumentType[0] == 'r') {
            argumentType += 1;
        }
        
#define setArgument(type) { \
    type arg = va_arg(arguments, type); \
    [invocation setArgument:&arg atIndex:index]; \
} break;

        switch (argumentType[0]) {
            case '@': setArgument(id);
            case 'f': {
                float arg = va_arg(arguments, double); // 这里用 float 无法正常取出值
                [invocation setArgument:&arg atIndex:index];
            } break;
            case 'd': setArgument(double);
            case 'B': setArgument(bool);
            case 'c': setArgument(char);
            case 's': setArgument(short);
            case 'i': setArgument(int);
            case 'l': setArgument(long);
            case 'q': setArgument(long long);
            case 'C': setArgument(unsigned char);
            case 'S': setArgument(unsigned short);
            case 'I': setArgument(unsigned int);
            case 'L': setArgument(unsigned long);
            case 'Q': setArgument(unsigned long long);
//            case '*': setArgument(char *);
//            case '#': setArgument(Class);
//            case ':': setArgument(SEL);
        }
    }

    va_end(arguments);

    [invocation setSelector:aSelector];
    [invocation invokeWithTarget:self];

    const char *returnType = [methodSignature methodReturnType];

#define returnNumericValue(type) { \
    type numericValue; \
    [invocation getReturnValue:&numericValue]; \
    return @(numericValue); \
}
    
    switch (returnType[0]) {
        case 'v': return nil;
        case '@': {
            id object;
            [invocation getReturnValue:&object];
            return object;
        }
        case 'B': returnNumericValue(bool);
        case 'f': returnNumericValue(float);
        case 'd': returnNumericValue(double);
        case 'c': returnNumericValue(char);
        case 's': returnNumericValue(short);
        case 'i': returnNumericValue(int);
        case 'l': returnNumericValue(long);
        case 'q': returnNumericValue(long long);
        case 'C': returnNumericValue(unsigned char);
        case 'S': returnNumericValue(unsigned short);
        case 'I': returnNumericValue(unsigned int);
        case 'L': returnNumericValue(unsigned long);
        case 'Q': returnNumericValue(unsigned long long);
    }

    return nil;
}

@end
