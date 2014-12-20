//
//  ATFCompanyName.m
//  mac
//
//  Created by Andrew on 7/6/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "ATFCompanyName.h"

@implementation ATFCompanyName

+ (NSString *) companyNameForSymbol:(NSString *)symbol {
    
    NSData * symbolData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=%@&callback=YAHOO.Finance.SymbolSuggest.ssCallback",symbol]]];
    NSString * symbolDataString = [[[NSString alloc] initWithData:symbolData encoding:NSUTF8StringEncoding] substringFromIndex:76];
    
    NSArray * allDownloadedResults = [symbolDataString componentsSeparatedByString:@"},{"];
    
    NSString * resultString = [(NSArray*)allDownloadedResults mutableCopy][0];
    
    NSArray * objects = [resultString componentsSeparatedByString:@","];
    if (objects.count < 2) {
        return @"Symbol Invalid";
    }
    NSString * companyFullText = [objects[1] description];
    companyFullText = [companyFullText stringByReplacingOccurrencesOfString:@"name" withString:@""];
    companyFullText = [companyFullText stringByReplacingOccurrencesOfString:@":" withString:@""];
    companyFullText = [companyFullText stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    companyFullText = [companyFullText stringByReplacingOccurrencesOfString:@"{" withString:@""];
    
    if ([companyFullText hasPrefix:@" "]) {
        companyFullText = [companyFullText substringFromIndex:1];
    }
    
    return companyFullText;
}

@end
