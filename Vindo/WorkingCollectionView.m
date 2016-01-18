//
//  WorkingCollectionView.m
//  Vindo
//
//  Created by Theodore Dubois on 1/14/16.
//  Copyright © 2016 Theodore Dubois. All rights reserved.
//

#import "WorkingCollectionView.h"

@implementation WorkingCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
    NSCollectionViewItem *item = [super newItemForRepresentedObject:object];
    NSButton *button = item.view.subviews[0];
    NSAssert([button isKindOfClass:[NSButton class]], @"should be a button");
    [button.cell setRepresentedObject:object];
    return item;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
