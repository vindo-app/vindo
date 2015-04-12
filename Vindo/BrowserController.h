//
//  BrowserController.h
//  Vindo
//
//  Created by Theodore Dubois on 3/29/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Item.h"

@interface BrowserController : NSWindowController <NSWindowDelegate>

@property Item *rootItem;

@end
/*
 - (void)setDelegate:(id <NSBrowserDelegate>)delegate {
    if (delegate == _delegate)
        return;
 
 // Optimizer avoids jumps here by shifting conditional result as indicated and then or-ing it.
    if ([delegate respondsToSelector:@selector(browser:titleOfColumn:)])
        _brflags |= 1 << 24;
    if ([delegate respondsToSelector:@selector(browser:selectCellWithString:inColumn:)])
        _brflags |= 1 << 23;
    if ([delegate respondsToSelector:@selector(browser:selectRow:inColumn:)])
        _brflags |= 1 << 13;
    if ([delegate respondsToSelector:@selector(browser:isColumnValid:)])
        _brflags |= 1 << 21;
    if ([delegate respondsToSelector:@selector(browser:willDisplayCell:atRow:column:)])
        _brflags |= 1 << 25;
    if ([delegate respondsToSelector:@selector(browser:numberOfRowsInColumn:)])
        _brflags |= 1 << 22;
 
    _NSBrowserAuxiliary *aux = _brAuxiliaryStorage;
    if ([delegate respondsToSelector:@selector(browser:shouldSizeColumn:forUserResize:toWidth:)])
        aux->_brflags2 |= 1 << 0;
    if ([delegate respondsToSelector:@selector(browser:sizeToFitWidthOfColumn:)]))
        aux->_brflags2 |= 1 << 1;
    if (!numberOfChildrenOfItem && !child:ofItem && !isLeafItem && !objectValueForItem)
        aux->_brflags2 |= 1 << 19;
    if ([delegate respondsToSelector:@selector(browser:didChangeLastColumn:toColumn:)])
        aux->_brflags2 |= 1 << 23;
    if ([delegate respondsToSelector:@selector(rootItemForBrowser:)])
        aux->_brflags2 |= 1 << 24;
 if (!numberOfRowsInColumn) goto l1068; // numOfRowsInCol
 if (!willDisplayCell || createRowsForColumn:inMatrix) goto l1110; // willDisplayCell
 l1068:
 if (_brflags & (1 << 22) || createRowsForColumn:inMatrix) goto l1318; // numOfRowsInCol
 l1110:
 if (aux->_brflags2 & (1 << 19)) goto l1318; // if no item based stuff
 NSLog("*** Illegal NSBrowser Delegate ladida");
 return;
 l1318:
 _delegate = delegate;
 */