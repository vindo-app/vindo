//
//  AnalyticsController.m
//  
//
//  Created by Dubois, Theodore Alexander on 11/18/15.
//
//

#import "AnalyticsController.h"
#import "NSUserDefaults+KeyPaths.h"

@interface AnalyticsController ()

@property NSURLConnection *conn;
@property NSString *uuid;

@property NSDate *lastPing;
@property NSTimer *timer;

@end

@implementation AnalyticsController

- (void)awakeFromNib {
    [self doPing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:NSApp];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(timerPing:) userInfo:nil repeats:YES];
}

- (void)appWillTerminate:(NSNotification *)n {
    [self doPing];
}

- (void)timerPing:(NSTimer *)timer {
    if ([self.lastPing timeIntervalSinceNow] >= 60*24)
        [self doPing];
}

- (void)injected {
    [self doPing];
}

- (void)doPing {
    DLog(@"pinging");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = self.uuid;
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    NSMutableSet *programs = [NSMutableSet set];
    for (NSString *world in [defaults objectForKey:@"worlds"]) {
        [programs addObjectsFromArray:[defaults valueForKeyPathArray:@[@"startMenuItems", world]]];
        NSString *applicationSupport = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
        NSString *steamGamesDirectory = [[[applicationSupport stringByAppendingPathComponent:@"Vindo/Worlds"]
                                          stringByAppendingPathComponent:world]
                                         stringByAppendingPathComponent:@"drive_c/Program Files/Steam/steamapps/common"];
        NSArray *steamGames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:steamGamesDirectory error:nil];
        if (steamGames) {
            for (NSString *steamGame in steamGames) {
                if ([steamGame isEqualToString:@".DS_Store"])
                    continue;
                [programs addObject:[NSString stringWithFormat:@"Steam/%@", steamGame]];
            }
        }
    }
    
    NSString *url = @"https://vindo-analytics.herokuapp.com/ping";
    url = [url stringByAppendingFormat:@"?uuid=%@", [uuid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    url = [url stringByAppendingFormat:@"&version=%@", [version stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    for (NSString *program in programs) {
        url = [url stringByAppendingFormat:@"&programs[]=%@", [program stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    if (response.statusCode != 204) {
        NSLog(@"analytics ping failed with code %ld", response.statusCode);
    } else {
        self.lastPing = [NSDate date];
    }
}

- (NSString *)uuid {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"analytics_id"];
    if (!uuid) {
        uuid = @"";
        for (int i = 0; i < 40; i++)
            uuid = [uuid stringByAppendingFormat:@"%c", (arc4random() % 26) + 'a'];
        self.uuid = uuid;
    }
    return uuid;
}

- (void)setUuid:(NSString *)uuid {
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"analytics_id"];
}

@end
