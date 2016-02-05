//
//  XcodeDocsFetcher.h
//  XcodeDocsFetcher
//
//  Created by BlueCocoa on 16/2/5.
//  Copyright © 2016 BlueCocoa. All rights reserved.
//

#import <AppKit/AppKit.h>

@class XcodeDocsFetcher;

static XcodeDocsFetcher *sharedPlugin;

@interface XcodeDocsFetcher : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end