//
//  PrefrenceWindowController.m
//  MupenLaunch
//
//  Created by Stephen Tierney on 15/04/12.
//  Copyright (c) 2012 Stephen Tierney. All rights reserved.
//
//	This program is free software; you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation; either version 2 of the License, or
//	(at your option) any later version.
//	                                                                      
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//	
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the
//	Free Software Foundation, Inc.,
//	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//

#import "PrefrenceWindowController.h"

@interface PrefrenceWindowController ()

@end

@implementation PrefrenceWindowController
@synthesize prefsToolbar;
@synthesize videoToolbarButton;
@synthesize controllerToolbarButton;
@synthesize emulatorToolbarButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setCurrentVC:(NSViewController *)viewController
{	
	[[currentController view] removeFromSuperview];

	NSRect oldFrame = [[self window] frame];
	NSPoint topLeft = NSMakePoint(oldFrame.origin.x, oldFrame.origin.y + oldFrame.size.height);
	
	NSRect newFrame = [[self window] frameRectForContentRect:[[viewController view] frame]];
	NSPoint newOrigin = NSMakePoint(topLeft.x, topLeft.y - newFrame.size.height);
	newFrame.origin = newOrigin;
	[[self window] setFrame:newFrame display:YES animate:YES];
	
	[targetView addSubview:[viewController view]];
	[[viewController view] setFrame:[targetView frame]];
	
	currentController = viewController;
}

- (void)awakeFromNib
{
	videoVC = [[VideoPreferencesViewController alloc] initWithNibName:@"VideoPrefsView" bundle:nil];
	controllerVC = [[ControllerPreferencesViewController alloc] initWithNibName:@"ControllerPrefsView" bundle:nil];
	emulatorVC = [[EmulatorPreferencesViewController alloc] initWithNibName:@"EmulatorPrefsView" bundle:nil];
    
	[self setCurrentVC:videoVC];
	[[self window] center];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	
	[prefsToolbar setSelectedItemIdentifier:@"Video"];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    if ([[toolbarItem label] isEqualToString:@"Video"])
		return YES;
	if ([[toolbarItem label] isEqualToString:@"Controllers"])
		return YES;
    if ([[toolbarItem label] isEqualToString:@"Emulator"])
		return YES;
	
    return NO;
}

- (IBAction)videoPressed:(id)sender {
	if (currentController != videoVC)
		[self setCurrentVC:videoVC];
}

- (IBAction)controllerPressed:(id)sender {
	if (currentController != controllerVC)
		[self setCurrentVC:controllerVC];
}

- (IBAction)emulatorPressed:(id)sender {
    if (currentController != emulatorVC)
		[self setCurrentVC:emulatorVC];
}

@end
