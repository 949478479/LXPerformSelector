//
//  ViewController.m
//  LXPerformSelector
//
//  Created by 从今以后 on 16/1/16.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    printf("%s\n", @encode(const int * const));
    printf("%s\n", @encode(const int *));
    printf("%s\n", @encode(int *const));
    printf("%s\n", @encode(const int * const *));
    printf("%s\n", @encode(const int **));

//    NSMethodSignature *s = [self methodSignatureForSelector:@selector(test:)];
//    NSInvocation *i = [NSInvocation invocationWithMethodSignature:s];
//
//
//    [i invokeWithTarget:self];
}

- (void)test:(id)o
{
    NSLog(@"%@", o);
}

@end
