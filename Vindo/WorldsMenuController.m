//
//  WorldsMenuController.m
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 3/19/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsMenuController.h"
#import "World.h"

@interface WorldsMenuController () {
    NSMenu *template;
}

@property IBOutlet NSMenu *worldsMenu;
@property IBOutlet NSArrayController *worldsArrayController;

@end

@implementation WorldsMenuController

- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:@{
                                     @"worlds": @[@"Default World"],
                                     @"defaultWorldIndex": @0
                                     }];
    }
    return self;
}

- (void)awakeFromNib {
    template = [self.worldsMenu copy];
    
    [self.worldsArrayController addObserver:self
                                 forKeyPath:@"selectedObjects"
                                    options:NSKeyValueObservingOptionNew
                                    context:NULL];
    [self.worldsArrayController addObserver:self
                                 forKeyPath:@"arrangedObjects"
                                    options:NSKeyValueObservingOptionNew
                                    context:NULL];
    [self redoMenu];
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

- (IBAction)worldSelected:(id)sender {
    NSLog(@"world selected");
}

@end
