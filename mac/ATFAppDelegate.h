//
//  ATFAppDelegate.h
//  mac
//
//  Created by Andrew on 7/5/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATFCompanyName.h"
@interface ATFAppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate,NSURLConnectionDelegate> {
    NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSPanel *panel;
@property (assign) IBOutlet NSTextField *symbolField;
@property (assign) IBOutlet NSTextField *priceLabel;
@property (assign) IBOutlet NSTextField *percentLabel;

@end
