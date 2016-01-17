//
//  LXPerformSelectorTests.m
//  LXPerformSelectorTests
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <XCTest/XCTest.h>
@import ObjectiveC.runtime;
#import "NSObject+LXPerformSelector.h"

@interface LXPerformSelectorTester : NSObject
@end
@implementation LXPerformSelectorTester

#define LXDefineBaseTypeTestMethod(name, type) \
- (type)test_##name##_withArg0:(type)arg0 arg1:(type)arg1 arg2:(type)arg2 { \
    return arg0 + arg1 + arg2; \
}

LXDefineBaseTypeTestMethod(bool, bool)                           // 1
LXDefineBaseTypeTestMethod(BOOL, BOOL)                           // 2
LXDefineBaseTypeTestMethod(float, float)                         // 3
LXDefineBaseTypeTestMethod(double, double)                       // 4
LXDefineBaseTypeTestMethod(char, char)                           // 5
LXDefineBaseTypeTestMethod(unsignedChar, unsigned char)          // 6
LXDefineBaseTypeTestMethod(short, short)                         // 7
LXDefineBaseTypeTestMethod(unsignedShort, unsigned short)        // 8
LXDefineBaseTypeTestMethod(int, int)                             // 9
LXDefineBaseTypeTestMethod(unsignedInt, unsigned int)            // 10
LXDefineBaseTypeTestMethod(long, long)                           // 11
LXDefineBaseTypeTestMethod(unsignedLong, unsigned long)          // 12
LXDefineBaseTypeTestMethod(longLong, long long)                  // 13
LXDefineBaseTypeTestMethod(unsignedLongLong, unsigned long long) // 14

- (CATransform3D)test_struct_rect:(CGRect)rect
                             size:(CGSize)size
                            point:(CGPoint)point
                            range:(NSRange)range
                           vector:(CGVector)vector
                           offset:(UIOffset)offset
                       edgeInsets:(UIEdgeInsets)edgeInsets
                      transform3D:(CATransform3D)transform3D
                  affineTransform:(CGAffineTransform)affineTransform
{
    printf("CGRect %s\n", NSStringFromCGRect(rect).UTF8String);
    printf("CGSize %s\n", NSStringFromCGSize(size).UTF8String);
    printf("CGPoint %s\n", NSStringFromCGPoint(point).UTF8String);
    printf("Range %s\n", NSStringFromRange(range).UTF8String);
    printf("CGVector %s\n", NSStringFromCGVector(vector).UTF8String);
    printf("UIOffset %s\n", NSStringFromUIOffset(offset).UTF8String);
    printf("UIEdgeInsets %s\n", NSStringFromUIEdgeInsets(edgeInsets).UTF8String);
    printf("CGAffineTransform %s\n", NSStringFromCGAffineTransform(affineTransform).UTF8String);

    return transform3D;
}

typedef BOOL (*LXFuncPointer)(NSError **error);

- (CFStringRef)test_pointer_cString:(const char *)cString
                         cStringPtr:(const char **)cStringPtr
                                sel:(SEL)sel
                             selPtr:(SEL *)selPtr
                              class:(Class)class
                           classPtr:(Class *)classPtr
                           cfString:(CFStringRef)cfString
                            boolPtr:(BOOL *)boolPtr
                          doublePtr:(double *)doublePtr
                        uintegerPtr:(NSUInteger *)uintegerPtr
                              error:(NSError **)error
                            funcPtr:(LXFuncPointer)funcPtr
{
    printf("cString %s\n", cString);
    *cStringPtr = "试一试 char ** 类型好不好用~~~";

    printf("SEL %s\n", sel_getName(sel));
    *selPtr = _cmd;

    printf("Class %s\n", class_getName(class));
    *classPtr = object_getClass(self);

    CFShow(cfString);

    *boolPtr = YES;
    *doublePtr = DBL_MAX;
    *uintegerPtr = NSUIntegerMax;

    funcPtr(error);

    return CFSTR("I'm a CFStringRef too !!!");
}

static BOOL LXFuncPointerTestFunction(NSError **error) {
    *error = [NSError errorWithDomain:@"MyDomain" code:233 userInfo:nil];
    return YES;
}

- (const char *)test_cString_withArg0:(const char *)arg0 arg1:(const char **)arg1 {
    *arg1 = arg0;
    return arg0;
}

- (Class)test_Class_withArg0:(Class)arg0 arg1:(Class *)arg1 {
    *arg1 = arg0;
    return arg0;
}

- (SEL)test_SEL_withArg0:(SEL)arg0 arg1:(SEL *)arg1 {
    *arg1 = arg0;
    return arg0;
}

- (int)test_secondRankPointer_withArg0:(const int **)arg0 {
    return **arg0;
}

- (id)test_id_withArg0:(id (^)(NSString *, int))arg0 arg1:(NSString *)arg1 arg2:(int)arg2 {
    return arg0(arg1, arg2);
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

- (void)testExample
{
#define LXTest(typeName) \
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

    id floatValue = [_tester lx_performSelector:@selector(test_float_withArg0:arg1:arg2:), 1.0, 2.0, 3.0];
    XCTAssertTrue([floatValue floatValue] == 6.0);

    id doubleValue = [_tester lx_performSelector:@selector(test_double_withArg0:arg1:arg2:), 1.0, 2.0, 3.0];
    XCTAssertTrue([doubleValue doubleValue] == 6.0);

    id BOOLValue = [_tester lx_performSelector:@selector(test_BOOL_withArg0:arg1:arg2:), YES, YES, YES];
    XCTAssertTrue([BOOLValue boolValue]);

    id boolValue = [_tester lx_performSelector:@selector(test_BOOL_withArg0:arg1:arg2:), true, true, true];
    XCTAssertTrue([boolValue boolValue]);

    id (^block)(NSString *, int) = ^(NSString *str, int num) {
        XCTAssertTrue([str isEqualToString:@"233"]);
        return @(num);
    };
    id returnValue = [_tester lx_performSelector:@selector(test_id_withArg0:arg1:arg2:), block, @"233", 233];
    XCTAssertEqual([returnValue intValue], 233);

    const char *cString = "啦啦啦啦啦啦啦啦~~~";
    const char *inoutCString;
    id stringValue = [_tester lx_performSelector:@selector(test_cString_withArg0:arg1:),
                      cString, &inoutCString];
    XCTAssertTrue([stringValue pointerValue] == cString && cString == inoutCString);

    Class inoutClass;
    Class selfClass = [self class];
    id classValue = [_tester lx_performSelector:@selector(test_Class_withArg0:arg1:), selfClass, &inoutClass];
    XCTAssertTrue([classValue pointerValue] == (__bridge void *)selfClass && selfClass == inoutClass);

    SEL inoutSEL;
    id selValue = [_tester lx_performSelector:@selector(test_SEL_withArg0:arg1:), _cmd, &inoutSEL];
    XCTAssertTrue([selValue pointerValue] == _cmd && inoutSEL == _cmd);

    int a = 233;
    int *p = &a;
    int **pp = &p;
    id r = [_tester lx_performSelector:@selector(test_secondRankPointer_withArg0:), pp];
    XCTAssertTrue([r intValue] == 233);

    id transform3DValue = [_tester lx_performSelector:
            @selector(test_struct_rect:size:point:range:vector:offset:edgeInsets:transform3D:affineTransform:),
            CGRectMake(1, 2, 3, 4),
            CGSizeMake(5, 6),
            CGPointMake(7, 8),
            NSMakeRange(9, 10),
            CGVectorMake(11, 12),
            UIOffsetMake(13, 14),
            UIEdgeInsetsMake(15, 16, 17, 18),
            CATransform3DIdentity,
            CGAffineTransformIdentity];
    XCTAssertTrue(CATransform3DIsIdentity([transform3DValue CATransform3DValue]));

    CFStringRef cfString = CFSTR("I'm a CFStringRef!!!");
    BOOL inoutBool = NO;
    double inoutDouble = 0.0;
    NSUInteger inoutUInteger = 0;
    NSError *__autoreleasing error;

    printf("\n\n");

    id cfStringValue = [_tester lx_performSelector:@selector(test_pointer_cString:cStringPtr:sel:selPtr:class:classPtr:cfString:boolPtr:doublePtr:uintegerPtr:error:funcPtr:),
     "我是传入的 char * 啦啦啦啦啦啦啦啦~~~",
     &inoutCString,
     _cmd,
     &inoutSEL,
     object_getClass(self),
     &inoutClass,
     cfString,
     &inoutBool,
     &inoutDouble,
     &inoutUInteger,
     &error,
     LXFuncPointerTestFunction];

    printf("inoutCString %s\n", inoutCString);
    printf("inoutSEL %s\n", sel_getName(inoutSEL));
    printf("inoutClass %s\n", class_getName(inoutClass));
    printf("inoutDouble %g\n", inoutDouble);
    printf("inoutBool %s\n", inoutBool ? "YES" : "NO");
    printf("inoutUInteger %lu\n", (unsigned long)inoutUInteger);
    printf("%s\n", [[error localizedDescription] UTF8String]);

    CFRelease(cfString);
    cfString = [cfStringValue pointerValue];
    CFShow(cfString);
    CFRelease(cfString);

    printf("\n\n");
}

@end
