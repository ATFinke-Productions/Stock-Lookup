//
//  ATFAppDelegate.m
//  mac
//
//  Created by Andrew on 7/5/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "ATFAppDelegate.h"

@implementation ATFAppDelegate {
    NSMutableData * responseData;
    NSString * currentlyDisplayedSymbol;
    NSString * symbolToDownload;
    NSString * connectionError;
    
    NSString * currentChangePer;
    NSString * currentChangeDollar;
    
    BOOL isDisplayingPercentage;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateData) userInfo:Nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(switchLabel) userInfo:Nil repeats:YES];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    isDisplayingPercentage = YES;
    
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    textField.stringValue = [[textField stringValue] uppercaseString];
    symbolToDownload = [textField stringValue];
    if (symbolToDownload.length != 0) {
        self.panel.title = @"Loading...";
        [self updateData];
    }
}

- (void) updateData{
    
    NSString * symbol = symbolToDownload;
    
    if (symbol.length == 0) {
        return;
    }
    responseData = [NSMutableData data];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://download.finance.yahoo.com/d/quotes.csv?s=%@&f=l1p2c1n&e=.csv",symbol]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];

    [NSURLConnection connectionWithRequest:request delegate:self];
}


-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [responseData setLength:0];
    connectionError = @"";
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.panel.title = [error localizedDescription];
    NSLog(@"%@",[error localizedFailureReason]);
}


- (void) switchLabel {
    if (isDisplayingPercentage) {
        isDisplayingPercentage = NO;
        self.percentLabel.stringValue = currentChangeDollar;
    }
    else {
        isDisplayingPercentage = YES;
        self.percentLabel.stringValue = currentChangePer;
    }
    

}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{

    NSString * symbolDataString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSArray * symbolArray = [symbolDataString componentsSeparatedByString:@","];

    if (symbolArray.count < 3 || [symbolArray[0] isEqualToString:@"0.00"]) {
        self.panel.title = @"Symbol Invalid";
        return;
    }
    
    
    NSString * currentPrice = symbolArray[0];
    currentChangePer = symbolArray[1];

    NSString * firstSymbol = @"+";
    
    if ([[currentChangePer substringToIndex:2] isEqualToString:@"\"-"]) {
        self.percentLabel.textColor = [NSColor redColor];
        firstSymbol = @"-";
    }
    else {
        self.percentLabel.textColor = [NSColor colorWithDeviceRed:0 green:.64 blue:0 alpha:1];
    }

    currentChangePer = [currentChangePer substringToIndex:currentChangePer.length-2];
    currentChangePer = [currentChangePer substringFromIndex:2];
    currentChangePer = [NSString stringWithFormat:@"%@ %@ %%",firstSymbol,currentChangePer];
    
    currentPrice = [NSString stringWithFormat:@"$ %@", [self stringforFloat:[currentPrice floatValue] includeZeros:YES]];

    
    currentChangeDollar = [NSString stringWithFormat:@"%@ $%@",[symbolArray[2]substringToIndex:1], [self stringforFloat:[[symbolArray[2]substringFromIndex:1] floatValue] includeZeros:YES]];

    if (isDisplayingPercentage) {
        self.percentLabel.stringValue = currentChangePer;
    }
    else {
        self.percentLabel.stringValue = currentChangeDollar;
    }

    self.priceLabel.stringValue = currentPrice;
    
    
    if (![currentlyDisplayedSymbol isEqualToString:symbolToDownload]) {
        
        BOOL stringsLong = NO;
        
        NSString * companyName = [ATFCompanyName companyNameForSymbol:symbolToDownload];
        
        NSString * betterCompanyName = [companyName uppercaseString];
        NSString * betterCompanyWithThe = [companyName uppercaseString];
        
        NSString * yahooCompanyName = [[symbolArray[3] uppercaseString] substringFromIndex:1];
        NSString * yahooCompanyNameWithThe = [[symbolArray[3] uppercaseString] substringFromIndex:1];;
        
        if (companyName.length > 7) {
            betterCompanyName = [[betterCompanyName substringFromIndex:4] substringToIndex:3];
            betterCompanyWithThe = [betterCompanyWithThe substringToIndex:3];
            
            yahooCompanyName = [yahooCompanyName substringToIndex:3];
            yahooCompanyNameWithThe = [yahooCompanyNameWithThe substringFromIndex:1];
            
            stringsLong = YES;
        }
        
   
        if (!stringsLong || [yahooCompanyName isEqualToString:[[companyName uppercaseString] substringToIndex:3]]) {
            self.panel.title = companyName;
        }
        else if (![yahooCompanyName isEqualToString:betterCompanyName] && ![yahooCompanyNameWithThe isEqualToString:betterCompanyWithThe]) {
            self.panel.title = [symbolArray[2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
        else {
            self.panel.title = companyName;
        }
    }

   
    [statusItem setTitle:[NSString stringWithFormat:@"%@: %@",symbolToDownload,currentChangePer]];
    
    currentlyDisplayedSymbol = symbolToDownload;
}


- (NSString *) stringforFloat:(float)number includeZeros:(BOOL)zeros {
    NSArray * decimalDivideArray = [[NSString stringWithFormat:@"%f",number] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    NSString * setOne = decimalDivideArray[0];
    NSString * setTwo;
    if (decimalDivideArray.count > 1) {
        if (((NSString*)decimalDivideArray[1]).length > 2) {
            setTwo = [decimalDivideArray[1] substringToIndex:2];
        }
    }
    
    if ([setTwo isEqualToString:@"00"] && !zeros) {
        return setOne;
    }
    return [NSString stringWithFormat:@"%@.%@",setOne,setTwo];
}

@end
