//
//  WindowController.m
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

#import "WindowController.h"
#import "ROM.h"
#import "AppDelegate.h"
#import "ErrorWinController.h"


@implementation WindowController

@synthesize rom;

- (void)initControllers
{
	if ([currentController view] != nil)
		[[currentController view] removeFromSuperview];
	
	[playButton setEnabled:NO];
	[clearButton setEnabled:NO];
	
	emptyVC = [[EmptyViewController alloc] initWithNibName:@"EmptyView" bundle:nil];
	romVC = [[ROMViewController alloc] initWithNibName:@"ROMView" bundle:nil];
	
	currentController = emptyVC;
	
	[targetView addSubview:[currentController view]];
	[[currentController view] setFrame:[targetView frame]];
	
	dragWindow = (DragWindow*)self.window;
	[dragWindow  setDropDelegate:self];
	
}

- (void)readEmulatorConfig
{	
	NSString *file = [[NSBundle mainBundle] 
					  pathForResource:@"EmulatorOptions" ofType:@"plist"];
	
	emulatorOptions = [NSDictionary dictionaryWithContentsOfFile:file];
	
	mupenPath = [NSString stringWithFormat:@"%@%@", bundlePath, [emulatorOptions valueForKey:@"UIConsole"]];
	
	coreArg = [NSString stringWithFormat:@"--corelib %@%@", bundlePath, [emulatorOptions valueForKey:@"CoreLibrary"]];
	pluginArg = [NSString stringWithFormat:@"--plugindir %@%@", bundlePath, [emulatorOptions valueForKey:@"PluginDirectory"]];
}

- (void)awakeFromNib
{
	[self initControllers];
	
	bundlePath = [[NSBundle mainBundle] resourcePath];
	[self readEmulatorConfig];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkATaskStatus:)
												 name:NSTaskDidTerminateNotification
											   object:nil];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

 - (void) orderOutMyWindow: (id) sender {
	NSString* title = self.window.title;
	[self.window orderOut: sender];
	[NSApp addWindowsItem: self.window title: title filename: NO];
 }

 - (BOOL) windowShouldClose: (id) sender {
	[self performSelector: @selector (orderOutMyWindow:) withObject: sender afterDelay: 0.0];
	return NO;
 }


-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    if ([[toolbarItem label] isEqualToString:@"Play"]
		&& currentController == romVC
		&& !taskRunning) {
        return YES;
		
    } else if ([[toolbarItem label] isEqualToString:@"Eject"]
			   && currentController == romVC
			   && ![task isRunning]) {
        return YES;
	} else if ([[toolbarItem label] isEqualToString:@"Pause"]
			   && taskRunning
			   && [task isRunning]) {
		return YES;
	} else if ([[toolbarItem label] isEqualToString:@"Stop"]
			   && [task isRunning]) {
		return YES;
	}
	
    return NO;
}

- (BOOL)acceptsURL:(NSURL*) URL
{
	if ([URL isFileURL]) {
		if ([[URL pathExtension] isEqualToString: @"v64"]
			|| [[URL pathExtension] isEqualToString: @"z64"]
            || [[URL pathExtension] isEqualToString: @"n64"]){
			return TRUE;
		}
	}
	return FALSE;
}

- (BOOL)handleURL:(NSURL*) URL
{	
	// Set spinner going
	[emptyVC startSpinning];
	
	// Process ROM file
	rom = [ROM romFromURL:URL];
	
//	if ([rom isValid])
	{
		// Set up romVC
		[romVC setROM:rom];
		
		// Add file to Open recent
		NSDocumentController *sharedDocumentController = [NSDocumentController sharedDocumentController];
		[sharedDocumentController noteNewRecentDocumentURL:URL];
		
		// Swap views
		[[emptyVC view] removeFromSuperview];
		currentController = romVC;
		
		[targetView addSubview:[currentController view]];
		[[currentController view] setFrame:[targetView frame]];
        
		[emptyVC stopSpinning];
		return YES;
	}

    
//    Assume that there has been a failure and present error to user
//    [emptyVC stopSpinning];
//    ErrorWinController *pAbtCtrl = [[ErrorWinController alloc] initWithWindowNibName:@"ErrorWindow"];
//        
//    NSWindow *pAbtWindow = [pAbtCtrl window];
//        
//    [NSApp runModalForWindow: pAbtWindow];
    
//    [NSApp endSheet: pAbtWindow];
//        
//    [pAbtWindow orderOut: self];
//	
	
	return NO;
}

- (void)dropURL:(NSURL*) URL;
{
	[self handleURL:URL];
}

- (void)openFile:(id)sender {
	// Create the File Open Dialog class.
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	// Enable the selection of files in the dialog.
	[openDlg setCanChooseFiles:YES];
	
	[openDlg setAllowsMultipleSelection:NO];
	
	// Enable the selection of directories in the dialog.
	[openDlg setCanChooseDirectories:YES];
	
	[openDlg beginWithCompletionHandler:^(NSInteger result)
	 {
		 if (result==NSFileHandlingPanelOKButton)
		 {
			 [self handleURL:[openDlg URL]];
		 }
	 }];
}

- (void)writeInputAutoCfg
{
	NSMutableString *toFile = [[NSMutableString alloc] init];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSArray *mapping = [defaults arrayForKey:@"Mapping"];
	
	NSDictionary *controllerDict = [defaults dictionaryForKey:@"Controllers"];
	
	for (NSString* key in [controllerDict allKeys])
	{
		NSDictionary *controller = [controllerDict objectForKey:key];
		
		// Write controller USB Name
		[toFile appendString:[NSString stringWithFormat:@"[%@]\n", [controller objectForKey:@"USBName"]]];
		// Plugged
		[toFile appendString:[NSString stringWithFormat:@"plugged = %@\n", [controller objectForKey:@"plugged"] ? @"True" : @"False"]];
		// Plugin
		[toFile appendString:[NSString stringWithFormat:@"plugin = %@\n", [controller objectForKey:@"plugin"]]];
		// Mouse
		[toFile appendString:[NSString stringWithFormat:@"mouse = %@\n", [controller objectForKey:@"mouse"] ? @"False" : @"True"]];
		
		// Enumerate over buttons
		NSArray *mapArray = [controller objectForKey:@"Mapping"];
		
		for (int i = 0; i < [mapArray count]; ++i)
		{
			[toFile appendString:[NSString stringWithFormat:@"%@ = %@\n", [mapping objectAtIndex:i], [mapArray objectAtIndex:i]]];
		}
		
		[toFile appendString:@"\n"];
	}
	
	NSString *filePath = [NSString stringWithFormat:@"%@/mupen64plus.app/Contents/Resources/InputAutoCfg.ini", bundlePath];

	[toFile writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (IBAction)playPressed:(id)sender 
{
	if (task == NULL)
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		{
			// Delete ~/.config/mupen64plus/mupen64plus.cfg
			[[NSFileManager defaultManager] removeItemAtPath:@"/Users/steve/.config/mupen64plus/mupen64plus.cfg" error:nil];
		
			// Write InputAutoCfg.ini
			[self writeInputAutoCfg];
		}
		
		NSString *romPath = [[rom filePath] path];
		
		NSString *gfxArg = [NSString stringWithFormat:@"--gfx %@", [[emulatorOptions valueForKey:@"VideoPlugins"] valueForKey:[defaults valueForKey:@"VideoPlugin"]]];
		
		NSString *resArg = [NSString stringWithFormat:@"--resolution %@", [defaults valueForKey:@"Resolution"]];
		
		NSString *displayMode;
		if ([defaults boolForKey:@"Fullscreen"]) { displayMode = @"--fullscreen";}
		else { displayMode = @"--windowed";}
        
        NSString *pathToExectuable;
        if ([[defaults valueForKey:@"Build"] isEqualToString:@"Custom"])
            pathToExectuable = [defaults valueForKey:@"CustomBuildPath"];
        else
            pathToExectuable = mupenPath;
        
		NSString *fullPath = [NSString stringWithFormat:@"'%@' %@ %@ %@ %@ %@ '%@'", pathToExectuable, coreArg, pluginArg, gfxArg, resArg, displayMode,romPath];
		
		task = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:@"-c", fullPath, nil]];
	}
	else if (!taskRunning)
	{
		[task resume];
	}
	taskRunning = YES;
	
}

- (IBAction)pausePressed:(id)sender {
	taskRunning = NO;
	[task suspend];
}

- (IBAction)stopPressed:(id)sender {
	[task terminate];
}

- (IBAction)clearPressed:(id)sender {
	[romVC setROM:NULL];
	rom = NULL;
	
	taskRunning = NO;
	[task terminate];
	task = NULL;
	
	[[romVC view] removeFromSuperview];
	[emptyVC stopSpinning];
	currentController = emptyVC;
	[targetView addSubview:[currentController view]];
	[[currentController view] setFrame:[targetView frame]];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	if (task != NULL)
		[task terminate];
}

- (void)checkATaskStatus:(NSNotification *)aNotification {
    int status = [[aNotification object] terminationStatus];
    if (status > 0)
        NSLog(@"Task ended by app");
    else
        NSLog(@"Task ended self");
	
	taskRunning = NO;
	task = NULL;
}

@end
