//
//  WorldsMenuController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsMenuController.h"
#import "World.h"
#import "WorldsController.h"

@interface WorldsMenuController () {
    NSMenu *template;
}

@property IBOutlet NSMenu *worldsMenu;
@property NSArrayController *worldsArrayController;

@end

@implementation WorldsMenuController

- (void)awakeFromNib {
    template = [self.worldsMenu copy];
    self.worldsArrayController = [WorldsController sharedController];
    
    [self.worldsArrayController addObserver:self
                                 forKeyPath:@"selectedObjects"
                                    options:NSKeyValueObservingOptionNew
                                    context:NULL];
    [self.worldsArrayController addObserver:self
                                 forKeyPath:@"arrangedObjects"
                                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                    context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [self redoMenu];
}

- (void)redoMenu {
    [self.worldsMenu removeAllItems];
    
    for (World *world in self.worldsArrayController.arrangedObjects) {
        NSMenuItem *item = [NSMenuItem new];
        item.title = world.name;
        item.representedObject = world;
        item.target = self;
        item.action = @selector(worldSelected:);
        if ([self.worldsArrayController.selectedObjects indexOfObject:world] != NSNotFound) // object is selected
            item.state = NSOnState;
        [self.worldsMenu addItem:item];
    }
    
    for (NSMenuItem *item in [template itemArray]) {
        [self.worldsMenu addItem:[item copy]];
    }
}

- (void)worldSelected:(NSMenuItem *)sender {
    self.worldsArrayController.selectedObjects = @[sender.representedObject];
}

@end
