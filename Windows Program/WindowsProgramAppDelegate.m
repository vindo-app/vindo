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

@property NSString *world;

@property NSDistantObject <AppBundleCommunicationThing> *communicationThing;

@property NSURL *usr;

@property NSString *file;

@end

@implementation WindowsProgramAppDelegate
@synthesize communicationThing;
@synthesize usr;
@synthesize world;
@synthesize file;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    self.world = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"World"];
    
    // Make a DO connection to Vindo.
    NSArray *vindos = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"co.vindo.Vindo"];
    if ([vindos count] == 0) {
        if (![[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"co.vindo.Vindo"
                                                                  options:NSWorkspaceLaunchWithoutActivation
                                           additionalEventParamDescriptor:nil
                                                         launchIdentifier:NULL]) {
            [self failBecause:@"Vindo isn't installed. This app bundle requires Vindo. Therefore, this app bundle won't work."];
        }
    }
    
    // We have to wait until it starts.
    while (!communicationThing) {
        self.communicationThing = (id)[NSConnection rootProxyForConnectionWithRegisteredName:CONNECTION_NAME host:nil];
        if (!communicationThing) {
            sleep(1);
            continue;
        }
        [communicationThing setProtocolForProxy:@protocol(AppBundleCommunicationThing)];
    }
    
    self.usr = [[communicationThing usrURL] retain];
    
    // wait for the world to become available
    while (YES) {
        if ([communicationThing activateWorldNamed:world]) {
            break;
        } else {
            [self failBecause:@"This app bundle appears to be corrupted or something. It won't work."];
        }
    }
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    if (file != nil) {
        [communicationThing openFile:filename withFiletype:typeOfFile(filename) inWorld:world];
    } else {
        self.file = [filename retain];
    }
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self formatMenuItems];
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
    NSString *program;
    NSArray *arguments;
    if (self.file != nil) {
        NSString *filetype = typeOfFile(self.file);
        program = [communicationThing programForFile:self.file withFiletype:filetype inWorld:self.world];
        arguments = [communicationThing argumentsForFile:self.file withFiletype:filetype inWorld:self.world];
    } else {
        NSString *itemPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ItemPath"];
        program = [communicationThing programForStartMenuItem:itemPath inWorld:self.world];
        arguments = [communicationThing argumentsForStartMenuItem:itemPath inWorld:self.world];
    }
    
    // set necessary environment keys
    NSDictionary *environment = [communicationThing environmentForWorld:world];
    [environment enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        setenv([key UTF8String], [value UTF8String], 1);
    }];
    
    const char *libwine = [usr URLByAppendingPathComponent:@"lib/libwine.dylib"].path.UTF8String;
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
    NSString *argv0 = [usr URLByAppendingPathComponent:@"bin/wine"].path;
    NSArray *args = [@[argv0, program] arrayByAddingObjectsFromArray:arguments];
    const char **argv = [self buildArgv:args];
    wine_init(args.count, argv, error, sizeof(error));
    
    //[self failBecause:[NSString stringWithUTF8String:error]];
}

- (const char **)buildArgv:(NSArray *)args {
    NSUInteger argc = args.count;
    char **argv = malloc((argc + 1) * sizeof(char *));
    for (int i = 0; i < argc; i++) {
        argv[i] = strdup([args[i] UTF8String]);
    }
    argv[argc] = NULL;
    return (const char **)argv;
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

NSString *typeOfFile(NSString *file) {
    // I know it's deprecated, but it's the only thing that does exactly what I need.
    return [[NSDocumentController sharedDocumentController] typeFromFileExtension:file.pathExtension];
}

@end
