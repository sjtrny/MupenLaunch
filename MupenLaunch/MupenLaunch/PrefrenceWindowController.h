//
//  PrefrenceWindowController.h
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

#import <Cocoa/Cocoa.h>
#import "VideoPreferencesViewController.h"
#import "ControllerPreferencesViewController.h"
#import "EmulatorPreferencesViewController.h"

@interface PrefrenceWindowController : NSWindowController
{
	IBOutlet NSView *targetView;
	
	VideoPreferencesViewController *videoVC;
	ControllerPreferencesViewController *controllerVC;
    EmulatorPreferencesViewController *emulatorVC;
	NSViewController *currentController;
}

@property (weak) IBOutlet NSToolbar *prefsToolbar;
@property (weak) IBOutlet NSToolbarItem *videoToolbarButton;
@property (weak) IBOutlet NSToolbarItem *controllerToolbarButton;
@property (weak) IBOutlet NSToolbarItem *emulatorToolbarButton;

- (IBAction)videoPressed:(id)sender;
- (IBAction)controllerPressed:(id)sender;
- (IBAction)emulatorPressed:(id)sender;

@end
