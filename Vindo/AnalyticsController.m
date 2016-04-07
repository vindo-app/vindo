//
//  AnalyticsController.m
//  
//
//  Created by Dubois, Theodore Alexander on 11/18/15.
//
//

#import "AnalyticsController.h"

@interface AnalyticsController ()

@property NSURLConnection *conn;

@end

@implementation AnalyticsController

- (void)awakeFromNib {
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://vindo-analytics.herokuapp.com/ping?version=%@", version]];    
    self.conn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
}

@end
