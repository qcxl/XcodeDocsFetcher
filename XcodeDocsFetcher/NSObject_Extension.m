//
//  NSObject_Extension.m
//  XcodeDocsFetcher
//
//  Created by BlueCocoa on 16/2/5.
//  Copyright © 2016 BlueCocoa. All rights reserved.
//


#import "NSObject_Extension.h"
#import "XcodeDocsFetcher.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[XcodeDocsFetcher alloc] initWithBundle:plugin];
        });
    }
}
@end
