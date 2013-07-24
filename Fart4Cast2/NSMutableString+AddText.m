//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by George Uno on 1/12/12.
//  Copyright (c) 2012 Kuawa Road Productions. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

-(void)addText:(NSString *)text withSeparator:(NSString *)separator {
    if (text != nil) {
        if([self length] > 1) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}

@end
