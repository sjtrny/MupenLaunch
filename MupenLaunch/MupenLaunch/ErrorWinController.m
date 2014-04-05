//
//  ErrorWinController.m
//  MupenLaunch
//
//  Created by Steve on 5/01/13.
//  Copyright (c) 2013 Stephen Tierney. All rights reserved.
//

#import "ErrorWinController.h"

@implementation ErrorWinController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
	[[self window] center];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-  (IBAction)okPressed:(id)sender
{
    [NSApp stopModal];
}

@end
