//
//  AppDelegate.h
//  MupenLaunch
//
//  Created by Stephen Tierney on 10/04/12.
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
#import "PrefrenceWindowController.h"

@class WindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	WindowController *myWindowController;
	PrefrenceWindowController *preferenceController;
	
	NSString *launchFile;
}

@property (weak) IBOutlet NSMenuItem *fullscreenItem;
- (IBAction)openFile:(id)sender;
- (IBAction)showMainWindow:(id)sender;
- (IBAction)fullscreenPressed:(id)sender;
- (IBAction)showPrefs:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)quitApplication:(id)sender;

@end