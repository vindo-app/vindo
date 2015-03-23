//
//  WorldsPreferencesDataSource.m
//  Vindo
//
//  Created by Theodore Dubois on 3/23/15.
//  Copyright (c) 2015 Theodore Dubois. All rights reserved.
//

#import "WorldsPreferencesDataSource.h"

@implementation WorldsPreferencesDataSource

-           (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
                      row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"world"]) {
        return [self.arrayController.arrangedObjects[row] name];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row {
    // not implemented yet
}

@end
