//
//  LXPerformSelectorTests.m
//  LXPerformSelectorTests
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+LXPerformSelector.h"

@interface LXPerformSelectorTester : NSObject
@end
@implementation LXPerformSelectorTester

#define LXDefineBaseTypeTestMethod(name, type) \
\
- (void)test_##name { \
    printf("=================================================================== %s\n", __func__); \
} \
\
- (type)test_##name##_withArg0:(type)arg0 arg1:(type)arg1 arg2:(type)arg2 { \
    return arg0 + arg1 + arg2; \
}

- (void)test_BOOL {
    printf("=================================================================== %s\n", __func__);
}
- (BOOL)test_BOOL_withArg0:(BOOL)arg0 arg1:(BOOL)arg1 arg2:(BOOL)arg2 {
    return arg0 && arg1 && arg2;
}

- (void)test_float {
    printf("=================================================================== %s\n", __func__);
}
- (float)test_float_withArg0:(float)arg0 arg1:(float)arg1 arg2:(float)arg2 {
    return arg0 + arg1 + arg2;
}

- (void)test_double {
    printf("=================================================================== %s\n", __func__);
}
- (double)test_double_withArg0:(double)arg0 arg1:(double)arg1 arg2:(double)arg2 {
    return arg0 + arg1 + arg2;
}

LXDefineBaseTypeTestMethod(char, char)
LXDefineBaseTypeTestMethod(unsignedChar, unsigned char)
LXDefineBaseTypeTestMethod(short, short)
LXDefineBaseTypeTestMethod(unsignedShort, unsigned short)
LXDefineBaseTypeTestMethod(int, int)
LXDefineBaseTypeTestMethod(unsignedInt, unsigned int)
LXDefineBaseTypeTestMethod(long, long)
LXDefineBaseTypeTestMethod(unsignedLong, unsigned long)
LXDefineBaseTypeTestMethod(longLong, long long)
LXDefineBaseTypeTestMethod(unsignedLongLong, unsigned long long)

- (void)test_id {
    printf("=================================================================== %s\n", __func__);
}

- (id)test_id_withArg0:(NSString * (^)(int))arg0 arg1:(int)arg1 arg2:(NSUInteger)arg2 {
    printf("%d, %lu\n", arg1, (unsigned long)arg2);
    return arg0(233);
}

@end

@interface LXPerformSelectorTests : XCTestCase {
    id _tester;
}
@end
@implementation LXPerformSelectorTests

- (void)setUp {
    [super setUp];
    _tester = [LXPerformSelectorTester new];
}

- (void)testBaseType
{
    XCTAssertNil([_tester lx_performSelector:@selector(test_id)]);
    NSString *(^block)(int) = ^(int num) {
        printf("=================================================================== %d\n", num);
        return @"啦啦啦~~~";
    };
    id idValue = [_tester lx_performSelector:@selector(test_id_withArg0:arg1:arg2:), block, 233, 666];
    XCTAssertTrue([idValue isEqualToString:@"啦啦啦~~~"]);

#define LXTest(typeName) \
    XCTAssertNil([_tester lx_performSelector:@selector(test_##typeName)]); \
    id typeName##Value = [_tester lx_performSelector:@selector(test_##typeName##_withArg0:arg1:arg2:), 1, 2, 3]; \
    XCTAssertTrue([typeName##Value typeName##Value] == 6); \

    LXTest(char);
    LXTest(unsignedChar);
    LXTest(short);
    LXTest(unsignedShort);
    LXTest(int);
    LXTest(unsignedInt);
    LXTest(long);
    LXTest(unsignedLong);
    LXTest(longLong);
    LXTest(unsignedLongLong);

    XCTAssertNil([_tester lx_performSelector:@selector(test_BOOL)]);
    id boolValue = [_tester lx_performSelector:@selector(test_BOOL_withArg0:arg1:arg2:), YES, YES, YES];
    XCTAssertTrue([boolValue boolValue]);

    XCTAssertNil([_tester lx_performSelector:@selector(test_float)]);
    id floatValue = [_tester lx_performSelector:@selector(test_float_withArg0:arg1:arg2:), 1.0, 2.0, 3.0];
    XCTAssertTrue([floatValue floatValue] == 6.0);

    XCTAssertNil([_tester lx_performSelector:@selector(test_double)]);
    id doubleValue = [_tester lx_performSelector:@selector(test_double_withArg0:arg1:arg2:), 1.0, 2.0, 3.0];
    XCTAssertTrue([doubleValue doubleValue] == 6.0);
}

@end
