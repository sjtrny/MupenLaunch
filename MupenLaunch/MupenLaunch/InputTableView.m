//
//  InputTableView.m
//  MupenLaunch
//
//  Created by Stephen Tierney on 5/07/12.
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

#import "InputTableView.h"
#import "CarbonKeyEvents.h"
#import "SDL_keysym.h"
#import "ControllerPreferencesViewController.h"

@implementation InputTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (void)awakeFromNib
{
	listening = NO;
    readyForInput = YES;
}

-(BOOL)isListening
{
    return listening;
}

-(void)listenForKeys:(BOOL) value
{
	listening = value;
}

// Translates non ASCII key presses to 
-(void)handleNonASCII:(unsigned short)keyCode
{
	int charCode = -1;
	
	switch (keyCode) {
		case kVK_CapsLock:
			charCode = SDLK_CAPSLOCK;
			break;
		
		case kVK_Shift:
			charCode = SDLK_LSHIFT;
			break;
		
		case kVK_Control:
			charCode = SDLK_LCTRL;
			break;
		
		case kVK_Option:
			charCode = SDLK_LALT;
			break;
		
		case kVK_Command:
			charCode = SDLK_LSUPER;
			break;
		
		case (kVK_Command-1): // Right command 0x36
			charCode = SDLK_RSUPER;
			break;
		
		case kVK_RightOption:
			charCode = SDLK_RALT;
			break;
		
		case kVK_RightControl:
			charCode = SDLK_RCTRL;
			break;
		
		case kVK_RightShift:
			charCode = SDLK_RSHIFT;
			break;
		
		case kVK_LeftArrow:
			charCode = SDLK_LEFT;
			break;
			
		case kVK_RightArrow:
			charCode = SDLK_RIGHT;
			break;
			
		case kVK_DownArrow:
			charCode = SDLK_DOWN;
			break;
			
		case kVK_UpArrow:
			charCode = SDLK_UP;
			break;
	}
	
	if (charCode >= 0)
	{
		printf("Modifier: %i\n", charCode);
		ControllerPreferencesViewController* controller = (ControllerPreferencesViewController*)[self delegate];
		[controller keyPress:charCode];
	}
}

-(void)keyDown:(NSEvent *)theEvent
{
	if (listening & readyForInput)
	{
        readyForInput = NO;
		// Divert arrow keys
		if ([theEvent keyCode] == 0x7B
			|| [theEvent keyCode] == 0x7C
			|| [theEvent keyCode] == 0x7D
			|| [theEvent keyCode] == 0x7E)
		{
			[self handleNonASCII:[theEvent keyCode]];
		}
		else
		{
			printf("Char: %s, ASCII: %i\n", [[theEvent characters] UTF8String],*[[theEvent characters] UTF8String]);
			ControllerPreferencesViewController* controller = (ControllerPreferencesViewController*)[self delegate];
			[controller keyPress:[[theEvent characters] characterAtIndex:0]];
			
		}
	}
    
    [super keyDown:theEvent];
	
}

-(void)keyUp:(NSEvent *)theEvent
{
    readyForInput = YES;
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    if (listening)
    {
        if (readyForInput)
        {
            readyForInput = NO;
            [self handleNonASCII:[theEvent keyCode]];
        }
        else
        {
            readyForInput = YES;
        }
    }
	
	[super flagsChanged:theEvent];
}


@end
