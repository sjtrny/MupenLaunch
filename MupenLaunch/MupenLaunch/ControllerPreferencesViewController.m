//
//  ControllerPreferencesViewController.m
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

#import "ControllerPreferencesViewController.h"
#import "SDL.h"

@interface ControllerPreferencesViewController ()

@end

@implementation ControllerPreferencesViewController
@synthesize popupButton;
@synthesize tableView;
@synthesize nintendoColumn;
@synthesize yourColumn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setCurrentMapping
{
	currentController = [NSMutableDictionary dictionaryWithDictionary:[controllers valueForKey:[popupButton titleOfSelectedItem]]];
	
	currentMapping = [NSMutableArray arrayWithArray:[currentController valueForKey:@"Mapping"]];
	
	[tableView reloadData];
}

- (void)awakeFromNib
{
	defaults = [NSUserDefaults standardUserDefaults];
	
	mappingList = [defaults arrayForKey:@"Mapping"];
	
	controllers = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"Controllers"]];
	
	[popupButton addItemsWithTitles:[controllers allKeys]];
	
	lock = [[NSLock alloc] init];
	
	[self setCurrentMapping];
	
	[tableView setDataSource:self];
	
		SDL_Init( SDL_INIT_EVERYTHING );
	SDL_JoystickEventState (SDL_ENABLE);
	joy1 = SDL_JoystickOpen ( 0 );
	
}

- (id)     tableView:(NSTableView *) aTableView
objectValueForTableColumn:(NSTableColumn *) aTableColumn
				 row:(NSInteger) rowIndex
{  
	id returnValue = NULL;
	
	if (aTableColumn == nintendoColumn)
		returnValue = [mappingList objectAtIndex:rowIndex];
	else if (aTableColumn == yourColumn)
		returnValue = [currentMapping objectAtIndex:rowIndex];
	
	return returnValue; 
}

- (void)setMappingValue:(NSString*)value
{
	NSInteger rowIndex = [tableView selectedRow];

	NSString *old = (NSString*)[currentMapping objectAtIndex:rowIndex];
	
	if ([value isNotEqualTo:@""] && [value isNotEqualTo:old])
	{
		[currentMapping replaceObjectAtIndex:rowIndex withObject:value];
		
		[currentController setObject:currentMapping forKey:@"Mapping"];
		
		[controllers setObject:currentController forKey:[popupButton titleOfSelectedItem]];
		
		[defaults setValue:controllers forKey:@"Controllers"];
		
		[defaults setValue:[NSDate date] forKey:@"ControllersLastModifedDate"];
		
		[tableView reloadData];
	}
	
	long nextIndex = (rowIndex+1);
	if (nextIndex >= [tableView numberOfRows])
		nextIndex = 0;
	
	[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:nextIndex] byExtendingSelection:NO];
	
	[tableView scrollRowToVisible:nextIndex];
}

// just returns the number of items we have.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [currentMapping count];  
}

- (IBAction)popupItemSelected:(id)sender {
	[self setCurrentMapping];
	[self tableViewSelectionDidChange:nil];
}

- (void)keyPress:(int) key
{
	NSString *newButton = [NSString stringWithFormat:@"key(%i)",key];
	
	[self setMappingValue:newButton];
}

- (void)joystickButtonPressed:(int)button
{	
	NSString *newButton = [NSString stringWithFormat:@"button(%i)",button];
	
	[self setMappingValue:newButton];
	
}

- (void)pollJoystickEvents
{	
	@synchronized(lock)
	{
		printf("Joystick name: %s\n", SDL_JoystickName(0));
		
		SDL_Event event;
		
		bool running = true;
		bool firstTime = true;
		
		while (running) {
			
			if ([[NSThread currentThread] isCancelled])
				[NSThread exit];
			
			[NSThread sleepForTimeInterval:0.05];
			
			if ([[NSThread currentThread] isCancelled])
				[NSThread exit];
			
			//While there's events to handle
			while(SDL_PollEvent(&event))
			{  
				if (!running)
					break;
				
				switch(event.type)
				{  
					case SDL_JOYBUTTONDOWN:
						if (event.jbutton.which == SDL_JoystickIndex(joy1))
						{
							printf("Button %i\n", event.jbutton.button);
							NSString *newButton = [NSString stringWithFormat:@"button(%i)",event.jbutton.button];
							[self setMappingValue:newButton];
							running = NO;
							
						}
						
						break;
						
					case SDL_JOYAXISMOTION:
						if (!firstTime
							&& event.jaxis.which == SDL_JoystickIndex(joy1))
						{
							NSString *sign;
							if (event.jaxis.value > 31000
								&& event.jaxis.value <= 32768)
							{
								sign = @"+";
							}
							else if (event.jaxis.value < -31000
									 && event.jaxis.value >= -32768)
							{
								sign = @"-";
							}
							else
								break;
							
							printf("Axis %i\n", event.jaxis.axis);
							NSString *newButton = [NSString stringWithFormat:@"axis(%i%@)",event.jaxis.axis,sign];
							[self setMappingValue:newButton];
							running = false;
							[NSThread sleepForTimeInterval:0.5];
						}
						break;
				}
			}
			firstTime = NO;
		}
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger clickedRow = [tableView selectedRow];
	
	// If a row is selected
	if (clickedRow != -1)
	{
		if ([inputThread isExecuting])
		{
			[inputThread cancel];
		}
			
		if (![[popupButton titleOfSelectedItem] isEqualToString:@"Keyboard"])
		{
			[tableView listenForKeys:NO];
			inputThread = [[NSThread alloc] initWithTarget:self selector:@selector(pollJoystickEvents) object:nil];
			[inputThread start];
		}
		else {
			[tableView listenForKeys:YES];
		}
	}
}

- (IBAction)resetToDefaults:(id)sender {

	NSString *file = [[ NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	
	NSDictionary *defaultsDict = [ NSDictionary dictionaryWithContentsOfFile:file];
	
	NSDictionary *csDict = [defaultsDict objectForKey:@"Controllers"];
	
	NSDictionary *cDict = [csDict objectForKey:[popupButton titleOfSelectedItem]];
	
	currentMapping = [NSMutableArray arrayWithArray:[cDict objectForKey:@"Mapping"]];
	
	[currentController setObject:currentMapping forKey:@"Mapping"];
	
	[controllers setObject:currentController forKey:[popupButton titleOfSelectedItem]];
	
	NSString *temp = [popupButton titleOfSelectedItem];
	
	[defaults setValue:controllers forKey:@"Controllers"];
	
	[popupButton selectItemWithTitle:temp];
	
	[defaults setValue:[NSDate date] forKey:@"ControllersLastModifedDate"];
	
	[tableView reloadData];
}



@end
