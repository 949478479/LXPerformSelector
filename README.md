# LXPerformSelector

思路来自 [Awhisper/vk_msgSend](https://github.com/Awhisper/vk_msgSend)，按自己的方式搞了一下。。。

- 支持基础类型，例如 `BOOL`、`int`、`double`、`CGFloat`、`NSInteger` 等类型。
- 支持 `id` 类型，包括各种类型的对象和闭包。
- 支持指针类型，例如 `char *`、`char **`、`id *`，以及 `Class`、`SEL`、`CGColorRef` 等结构体指针和函数指针。
- 结构体类型只支持 `NSRange`、`CGSize`、`CGPoint`、`CGVector`、`CGAffineTransform`、`UIOffset`、`UIEdgeInsets`、`CATransform3D`。

```objective-c
// 参数类型 const char *，NSUInteger
// 返回类型 id
NSString *string = [NSClassFromString(@"NSString") lx_performSelector:@selector(stringWithCString:encoding:), 
                    "这有个 C 字符串。。。", NSUTF8StringEncoding];
printf("%s\n", [string UTF8String]);
```

```objective-c
// 参数类型 NSUIntege
// 返回类型 const char *
id cStirngValue = [string lx_performSelector:@selector(cStringUsingEncoding:), NSUTF8StringEncoding];
printf("cStirngValue: %s\n", [cStirngValue pointerValue]);
```

```objective-c
// 参数类型 NSUInteger
// 返回类型 NSUInteger
id lengthValue = [string lx_performSelector:@selector(lengthOfBytesUsingEncoding:), NSUTF8StringEncoding];
NSUInteger length = [lengthValue unsignedIntegerValue] + 1;
```
```objective-c
// 参数类型 char *，NSUInteger，NSUInteger
// 返回类型 BOOL
char buffer[length];
id success = [string lx_performSelector:@selector(getCString:maxLength:encoding:), 
                buffer, length, NSUTF8StringEncoding];
printf("Success? %s. Buffer: %s\n", [success boolValue] ? "YES" : "NO", buffer);
```

```objective-c
// 参数类型 NSURL，BOOL，NSError **
// 返回类型 BOOL
NSError * __autoreleasing error; // 这里需使用 __autoreleasing
success = [string lx_performSelector:@selector(writeToFile:atomically:encoding:error:),
               nil, YES, NSUTF8StringEncoding, &error];
printf("Success? %s%s\n", [success boolValue] ? "YES." : "NO. ", error.localizedDescription.UTF8String);
```

```objective-c
// 参数类型 CGRect
// 返回类型 CGRect
[self.view lx_performSelector:@selector(setFrame:), CGRectMake(100, 200, 300, 400)];
printf("%s\n", [[[self.view lx_performSelector:@selector(frame)] description] UTF8String]);
```

```objective-c
// 返回类型 Class
id classValue = [self lx_performSelector:@selector(class)];
printf("%s\n", [[(Class)[classValue pointerValue] description] UTF8String]);
```

```objective-c
// 返回类型 CGColorRef
id cgColorValue = [self.view.layer lx_performSelector:@selector(backgroundColor)];
printf("%p %p\n", [cgColorValue pointerValue], self.view.layer.backgroundColor);
```