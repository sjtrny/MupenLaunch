//
//  ROMViewController.m
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

#import "ROMViewController.h"

@interface ROMViewController ()

@end

@implementation ROMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
	[nameField setStringValue:[rom name]];
	[codeField setStringValue:[rom gameCode]];
	[crcField setStringValue:[NSString stringWithFormat:@"%X %X", [[rom CRC1] unsignedIntValue], [[rom CRC2] unsignedIntValue]]];
	[md5Field setStringValue:[rom MD5]];
}

- (void)setROM:(ROM *)r
{
	rom = r;
	
	if (rom != NULL)
	{
		[nameField setStringValue:[rom name]];
		[codeField setStringValue:[rom gameCode]];
		[crcField setStringValue:[NSString stringWithFormat:@"%X %X", [[rom CRC1] unsignedIntValue], [[rom CRC2] unsignedIntValue]]];
		[md5Field setStringValue:[rom MD5]];
	}
}

@end