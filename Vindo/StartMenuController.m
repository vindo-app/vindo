//
//  StartMenuController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 10/5/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#import "StartMenuController.h"
#import "WorldsController.h"

static StartMenuController *sharedInstance;

@interface StartMenuController ()

@property NSMutableDictionary<NSString *, StartMenu *> *menus;
@property FiletypeDatabase *filetypes;

@property WorldsController *wc;

@end

@implementation StartMenuController

- (instancetype)init {
    if (sharedInstance)
        return sharedInstance;
    
    if (self = [super init]) {
        sharedInstance = self;
        self.menus = [NSMutableDictionary new];
        self.wc = [WorldsController sharedController];
        [self.wc addObserver:self
                  forKeyPath:@"selectionIndex"
                     options:NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:NULL];
        [self.wc addObserver:self
                  forKeyPath:@"arrangedObjects"
                     options:NSKeyValueObservingOptionInitial
                     context:NULL];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectionIndex"]) {
        [self willChangeValueForKey:@"menu"];
        [self didChangeValueForKey:@"menu"];
    } else if ([keyPath isEqualToString:@"arrangedObjects"]) {
        for (World *world in self.wc.arrangedObjects)
            if (!self.menus[world.worldId])
                self.menus[world.worldId] = [[StartMenu alloc] initWithWorld:world];
        
        // do it like this to avoid "mutating while enumerating" exception
        NSMutableArray *worldsToRemove = [NSMutableArray new];
        for (NSString *worldId in self.menus.keyEnumerator)
            if (![self.wc worldWithId:worldId])
                [worldsToRemove addObject:worldId];
        for (NSString *worldId in worldsToRemove)
            [self.menus removeObjectForKey:worldId];
    }
}

- (StartMenu *)menu {
    return self.menus[self.wc.selectedWorld.worldId];
}

+ (StartMenuController *)sharedInstance {
    return [self new];
}

@end
