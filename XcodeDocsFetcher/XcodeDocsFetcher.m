//
//  XcodeDocsFetcher.m
//  XcodeDocsFetcher
//
//  Created by BlueCocoa on 16/2/5.
//  Copyright © 2016 BlueCocoa. All rights reserved.
//

#import "XcodeDocsFetcher.h"
#import <objc/runtime.h>

static IMP IDECombinedDownloadsPrefPaneController_IMP = NULL;

@interface DVTDownloadable : NSObject
@property(readonly) NSString *name;
@property(readonly) NSURL *source;
@end

@interface IDEComponentDownloadsPrefPaneItem : NSObject
@property(readonly) DVTDownloadable *downloadable;
@end

@interface XcodeDocsFetcher()
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation XcodeDocsFetcher

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationFinishLaunchingNotification:) name:NSApplicationDidFinishLaunchingNotification object:nil];
        
        NSString * enable = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.0xBBC.XcodeDocsFetcher.enable"];
        if ([enable length] == 0) {
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"com.0xBBC.XcodeDocsFetcher.enable"];
            enable = @"YES";
        }
        
        if ([enable boolValue]) {
            [self toggleMethodSwizzing];
        }
    }
    return self;
}

- (void)toggleMethodSwizzing {
    Method IDECombinedDownloadsPrefPaneController = class_getInstanceMethod(NSClassFromString(@"IDECombinedDownloadsPrefPaneController"), @selector(downloadItem:));
    method_exchangeImplementations(IDECombinedDownloadsPrefPaneController, class_getInstanceMethod(NSClassFromString(@"XcodeDocsFetcher"), @selector(downloadItem:)));
}

- (void)downloadItem:(IDEComponentDownloadsPrefPaneItem *)arg1 {
    DVTDownloadable * downloadable = [arg1 downloadable];
    if (downloadable != nil) {
        NSString * URL = [NSString stringWithFormat:@"%@", [downloadable source]];
        NSAlert * alert = [[NSAlert alloc] init];
        
        [alert addButtonWithTitle:@"Copy URL"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:[downloadable name]];
        [alert setInformativeText:URL];
        [alert setAlertStyle:NSInformationalAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSPasteboard * pasteBoard = [NSPasteboard generalPasteboard];
            [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
            [pasteBoard setString:URL forType:NSStringPboardType];
        }
    }
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSString * enable = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.0xBBC.XcodeDocsFetcher.enable"];
        if ([enable length] == 0) {
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"com.0xBBC.XcodeDocsFetcher.enable"];
        }
        
        NSString * title = @"Disable XcodeDocsFetcher";
        
        if (![enable boolValue]) {
            title = @"Enable XcodeDocsFetcher";
        }
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(toggleXcodeDocsFetcher:) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)toggleXcodeDocsFetcher:(NSMenuItem *)sender {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.0xBBC.XcodeDocsFetcher.enable"] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"com.0xBBC.XcodeDocsFetcher.enable"];
        [sender setTitle:@"Enable XcodeDocsFetcher"];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"com.0xBBC.XcodeDocsFetcher.enable"];
        [sender setTitle:@"Disable XcodeDocsFetcher"];
    }
    [self toggleMethodSwizzing];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
