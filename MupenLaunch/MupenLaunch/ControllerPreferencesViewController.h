//
//  ControllerPreferencesViewController.h
//  MupenLaunch
//
//  Created by Stephen Tierney on 29/06/12.
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
#import "InputTableView.h"
#import "SDL_keysym.h"
#import "SDL.h"

@interface ControllerPreferencesViewController : NSViewController <NSTableViewDataSource>
{
	NSUserDefaults *defaults;
	NSMutableDictionary *controllers;
	NSMutableDictionary *currentController;
	NSMutableArray *currentMapping;
	NSArray *mappingList;
	
	NSThread *inputThread;
	NSLock *lock;
	SDL_Joystick* joy1;
}
@property (weak) IBOutlet NSPopUpButton *popupButton;
@property (weak) IBOutlet InputTableView *tableView;
@property (weak) IBOutlet NSTableColumn *nintendoColumn;
@property (weak) IBOutlet NSTableColumn *yourColumn;

- (IBAction)popupItemSelected:(id)sender;
- (IBAction)resetToDefaults:(id)sender;

- (void)keyPress:(int) key;

@end
