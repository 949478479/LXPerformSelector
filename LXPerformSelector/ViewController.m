//
//  ViewController.m
//  LXPerformSelector
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+LXPerformSelector.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *string = [NSClassFromString(@"NSString") lx_performSelector:@selector(stringWithCString:encoding:),
                        "这有个 C 字符串。。。", NSUTF8StringEncoding];
    printf("%s\n", string.UTF8String);

    id cStirngValue = [string lx_performSelector:@selector(cStringUsingEncoding:), NSUTF8StringEncoding];
    printf("cStirngValue: %s\n", [cStirngValue pointerValue]);

    id lengthValue = [string lx_performSelector:@selector(lengthOfBytesUsingEncoding:), NSUTF8StringEncoding];
    NSUInteger length = [lengthValue unsignedIntegerValue] + 1;

    char buffer[length];
    id success = [string lx_performSelector:@selector(getCString:maxLength:encoding:),
                  buffer, length, NSUTF8StringEncoding];
    printf("Success? %s. Buffer: %s\n", [success boolValue] ? "YES" : "NO", buffer);

    NSError * __autoreleasing error; // 这里需使用 __autoreleasing
    success = [string lx_performSelector:@selector(writeToFile:atomically:encoding:error:),
               nil, YES, NSUTF8StringEncoding, &error];
    printf("Success? %s%s\n", [success boolValue] ? "YES." : "NO. ", error.localizedDescription.UTF8String);

    [self.view lx_performSelector:@selector(setFrame:), CGRectMake(100, 200, 300, 400)];
    printf("%s\n", [[[self.view lx_performSelector:@selector(frame)] description] UTF8String]);

    id classValue = [self lx_performSelector:@selector(class)];
    printf("%s\n", [[(Class)[classValue pointerValue] description] UTF8String]);

    id cgColorValue = [self.view.layer lx_performSelector:@selector(backgroundColor)];
    printf("%p %p\n", [cgColorValue pointerValue], self.view.layer.backgroundColor);
}

@end
