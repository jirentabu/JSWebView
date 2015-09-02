//
//  NSDictionary+QueryString.h
//  LROAuth2Client
//
//  Created by Luke Redpath on 14/05/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "NSDictionary+QueryString.h"

@implementation NSDictionary (QueryString)

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSArray* pairs = [encodedString componentsSeparatedByString:@"&"];

    for (NSString* kvp in pairs)
    {
        if ([kvp length] == 0)
          continue;

        NSRange pos = [kvp rangeOfString:@"="];
        NSString *key;
        NSString *val;

        if (pos.location == NSNotFound) 
        {
            key = [[kvp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            val = @"";
        }
        else
        {
            key = [[[kvp substringToIndex:pos.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            val = [[[kvp substringFromIndex:pos.location + pos.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        }

        if (!key || !val)
            continue; // I'm sure this will bite my arse one day

        [result setObject:val forKey:key];
    }
    return result;
}

@end
