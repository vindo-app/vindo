//
//  ItemBrowserCell.m
//  Vindo
//
//  Created by Theodore Dubois on 4/3/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "ItemBrowserCell.h"
#import "Item.h"

@implementation ItemBrowserCell

- (void)setObjectValue:(NSObject <NSCopying> *)obj {
    if ([obj isKindOfClass:[Item class]]) {
        Item *item = (Item *) obj;
        self.image = item.image;
        self.stringValue = item.name;
    } else
        [super setObjectValue:obj];
}

@end
