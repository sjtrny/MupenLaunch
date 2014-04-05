//
//  EmulatorPreferencesViewController.h
//  MupenLaunch
//
//  Created by Steve on 10/02/13.
//  Copyright (c) 2013 Stephen Tierney. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClickActionTextField.h"

@interface EmulatorPreferencesViewController : NSViewController {
    IBOutlet NSPopUpButton *buildSelector;
    IBOutlet ClickActionTextField *buildPathField;
}

- (IBAction)selectorChanged:(id)sender;

@end
