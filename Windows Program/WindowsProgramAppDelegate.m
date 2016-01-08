//
//  AppDelegate.m
//  Windows Program
//
//  Created by Dubois, Theodore Alexander on 12/18/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "WindowsProgramAppDelegate.h"
#import "WindowsProgramApplication.h"
#import "../AppBundleCommunicationThing.h"

#include <dlfcn.h>

static WindowsProgramApplication *app;

@interface WindowsProgramAppDelegate ()

@property NSDistantObject <AppBundleCommunicationThing> *communicationThing;

@property (retain) NSURL *usr;

@end

@implementation WindowsProgramAppDelegate
@synthesize communicationThing;
@synthesize usr;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    // Make a DO connection to Vindo.
    if (![[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.tbodt.Vindo"
                                                              options:NSWorkspaceLaunchWithoutActivation
                                       additionalEventParamDescriptor:nil
                                                     launchIdentifier:NULL]) {
        [self failBecause:@"Vindo isn't installed. This app bundle requires Vindo. Therefore, this app bundle won't work."];
    }
    
    // We have to wait until it starts.
    while (!self.communicationThing) {
        self.communicationThing = (id)[NSConnection rootProxyForConnectionWithRegisteredName:CONNECTION_NAME host:nil];
        if (!self.communicationThing) {
            sleep(1);
            continue;
        }
        [self.communicationThing setProtocolForProxy:@protocol(AppBundleCommunicationThing)];
    }
    
    self.usr = [self.communicationThing usrURL];
    NSLog(@"connection established");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self formatMenuItems];
    //[NSApp terminate:self];
    [self becomeWineTask];
}

- (void)formatMenuItems {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    NSMenu *appMenu = app.mainMenu.itemArray[0].submenu;
    for (NSMenuItem *item in appMenu.itemArray) {
        item.title = [NSString stringWithFormat:item.title, appName];
    }
}

- (void)failBecause:(NSString *)reason {
    NSRunAlertPanel(@"Something's Wrong!", @"%@", @"Quit", nil, nil, reason);
    [NSApp terminate:self];
}

#pragma mark Becoming Wine

__asm__(".zerofill WINE_DOS, WINE_DOS");
__asm__(".zerofill WINE_SHAREDHEAP, WINE_SHAREDHEAP");
static char __wine_dos[0x40000000] __attribute__((section("WINE_DOS, WINE_DOS")));
static char __wine_shared_heap[0x03000000] __attribute__((section("WINE_SHAREDHEAP, WINE_SHAREDHEAP")));

- (void)becomeWineTask {
    // wait for the world to become available
    NSString *world = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"World"];
    while (YES) {
        WorldStatus status = [self.communicationThing statusOfWorldNamed:world];
        if (status == WorldStatusNonexistent) {
            [self failBecause:@"This app bundle appears to be corrupted or something. It won't work."];
        } else if (status == WorldStatusStarting) {
            sleep(1);
        } else {
            break;
        }
    }
    
    NSString *nativeIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NativeIdentifier"];
    
    // set necessary environment keys
    NSDictionary *environment = [self.communicationThing environmentForWorld:world];
    [environment enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        setenv([key UTF8String], [value UTF8String], 1);
    }];
    
    
    const char *libwine = [self.usr URLByAppendingPathComponent:@"lib/libwine.dylib"].path.UTF8String;
    void *libwine_handle = dlopen(libwine, RTLD_LAZY | RTLD_LOCAL);
    if (libwine_handle == NULL) {
        [self failBecause:[NSString stringWithUTF8String:dlerror()]];
    }
    
    void (*wine_anon_mmap)(void *, size_t, int, int) = dlsym(libwine_handle, "wine_anon_mmap");
    void (*wine_mmap_add_reserved_area)(void *, size_t) = dlsym(libwine_handle, "wine_mmap_add_reserved_area");
    void (*wine_init)(int argc, const char *argv[], char *error, int error_size) = dlsym(libwine_handle, "wine_init");
    
    wine_anon_mmap(__wine_dos, sizeof(__wine_dos), PROT_NONE, MAP_FIXED | MAP_NORESERVE);
    wine_mmap_add_reserved_area(__wine_dos, sizeof(__wine_dos));
    wine_anon_mmap(__wine_shared_heap, sizeof(__wine_shared_heap), PROT_NONE, MAP_FIXED | MAP_NORESERVE);
    wine_mmap_add_reserved_area(__wine_shared_heap, sizeof(__wine_shared_heap));
    
    char error[1024];
    int argc = 2;
    const char *argv0 = [self.usr URLByAppendingPathComponent:@"bin/wine"].path.UTF8String;
    const char *argv1 = [self.communicationThing commandLineForStartMenuItem:nativeIdentifier inWorld:world].UTF8String;
    const char *argv[] = {argv0, argv1};
    wine_init(argc, argv, error, sizeof(error));
    
    //[self failBecause:[NSString stringWithUTF8String:error]];
}

#pragma mark Delegate methods that need to be passed to Wine

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [app.wineController applicationDidBecomeActive:notification];
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification {
    [app.wineController applicationDidChangeScreenParameters:notification];
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    [app.wineController applicationDidResignActive:notification];
}

- (void)applicationDidUnhide:(NSNotification *)notification {
    [app.wineController applicationDidUnhide:notification];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (app.wineController)
        return [app.wineController applicationShouldHandleReopen:sender hasVisibleWindows:flag];
    else
        return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (app.wineController)
        return [app.wineController applicationShouldTerminate:sender];
    else
        return NSTerminateNow;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [app.wineController applicationWillResignActive:notification];
}


+ (void)initialize {
    app = NSApp;
}

@end
