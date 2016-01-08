//
//  ABCTController.m
//  Vindo
//
//  Created by Theodore Dubois on 1/6/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "ABCTController.h"
#import "../AppBundleCommunicationThing.h"
#import "AppBundleConnectionThingImpl.h"

@interface ABCTController ()

@property AppBundleConnectionThingImpl *server;
@property NSConnection *connection;

@end

@implementation ABCTController

- (void)awakeFromNib {
    self.server = [AppBundleConnectionThingImpl new];
    self.connection = [NSConnection connectionWithReceivePort:[NSPort port] sendPort:nil];
    self.connection.rootObject = self.server;
    [self.connection registerName:CONNECTION_NAME];
}

@end
