//
//  FileItem.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 4/2/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface FileItem : Item <NSCopying>

- (instancetype)initWithURL:(NSURL *)url;

- (void)refresh;

@property (readonly) NSURL *url;

@end
