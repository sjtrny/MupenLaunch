//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "WindowController.h"

@implementation AppDelegate
@synthesize fullscreenItem;

-(IBAction)newDocument:(id)sender
{	
	if (myWindowController == NULL)
		myWindowController = [[WindowController alloc] initWithWindowNibName:@"MainWindow"];
	
	[myWindowController showWindow:self];
}

- (void)loadDefaults
{
	NSString *file = [[NSBundle mainBundle] 
					  pathForResource:@"Defaults" ofType:@"plist"];
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
	
	NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	[preferences registerDefaults:dict];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

	[[NSHelpManager sharedHelpManager] registerBooksInBundle:[NSBundle mainBundle]];
	
	// Insert code here to initialize your application
	[self loadDefaults];
	
	[self newDocument:self];
	
	if (launchFile)
		[self application:[NSApplication sharedApplication] openFile:launchFile];
}

- (IBAction)openFile:(id)sender {
	[myWindowController openFile:sender];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
	
	if (myWindowController)
	{
		NSURL *fileURL = [NSURL fileURLWithPath:filename];
		if ([myWindowController handleURL:fileURL])
			return YES;
	}

	launchFile = filename;
	
	return NO;
}

- (IBAction)showMainWindow:(id)sender {
	[myWindowController showWindow:[myWindowController window]];
}

- (IBAction)fullscreenPressed:(id)sender {
	// Deprecated
}

- (IBAction)showPrefs:(id)sender {
	if (preferenceController == NULL)
	{
		preferenceController = [[PrefrenceWindowController alloc] initWithWindowNibName:@"PreferenceWindow"];
	}
	[[preferenceController window] makeKeyAndOrderFront:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[myWindowController applicationWillTerminate:notification];
}

- (IBAction)closeWindow:(id)sender {
	[[NSApp keyWindow] performClose:self];
}

- (IBAction)quitApplication:(id)sender {
	[NSApp terminate:self];
}

@end
