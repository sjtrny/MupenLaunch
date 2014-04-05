//
//  EmulatorPreferencesViewController.m
//  MupenLaunch
//
//  Created by Steve on 10/02/13.
//  Copyright (c) 2013 Stephen Tierney. All rights reserved.
//

#import "EmulatorPreferencesViewController.h"

@implementation EmulatorPreferencesViewController

//IBOutlet NSPopUpButton *buildSelector;
//IBOutlet NSTextField *buildPathField;

-(void)loadView
{
    [super loadView];
    
    // If plist value = Custom set selector, and pathfield
    [buildPathField setEnabled:NO];
    
    [buildPathField setTarget:self];
    [buildPathField setAction:@selector(textSelected:)];
}

- (IBAction)selectorChanged:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[[buildSelector selectedItem] title] isEqualToString:@"Default"])
    {
        [buildPathField setEnabled:NO];
        [buildPathField setStringValue:@""];
        
        // Set plist value to use default
        [defaults setValue:@"Default" forKey:@"Build"];
        
    }
    else if ([[[buildSelector selectedItem] title] isEqualToString:@"Custom"])
    {
        [buildPathField setEnabled:YES];
        
        // Get current custom value
        [buildPathField setStringValue:[defaults valueForKey:@"CustomBuildPath"]];
        
        // Set plist value to use custom
        [defaults setValue:@"Custom" forKey:@"Build"];
    }
}

- (IBAction)textFieldSelected:(id)sender
{
	// Create the File Open Dialog class.
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    NSURL *fileURL = [NSURL fileURLWithPath:[[buildPathField stringValue] stringByDeletingLastPathComponent] isDirectory:YES];
    [openDlg setDirectoryURL: fileURL];
    
	openDlg.showsHiddenFiles = YES;
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];

	[openDlg beginWithCompletionHandler:^(NSInteger result)
	 {
		 if (result==NSFileHandlingPanelOKButton)
		 {
			 [buildPathField setStringValue:[[openDlg URL] path]];
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [defaults setValue:[buildPathField stringValue] forKey:@"CustomBuildPath"];
		 }
	 }];
}

@end
