//
//  ClickActionTextField.m
//  MupenLaunch
//
//  Created by Steve on 25/02/13.
//  Copyright (c) 2013 Stephen Tierney. All rights reserved.
//

#import "ClickActionTextField.h"

@implementation ClickActionTextField

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    if ([self isEnabled] && [self.delegate respondsToSelector:@selector(textFieldSelected:)])
    {
        [self.delegate performSelector:@selector(textFieldSelected:) withObject:self];
    }
}

@end
