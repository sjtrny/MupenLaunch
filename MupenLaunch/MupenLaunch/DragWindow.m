//
//  DragWindow.m
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

#import "DragWindow.h"

@implementation DragWindow

- (void)awakeFromNib
{
	[[self standardWindowButton:NSWindowZoomButton] setEnabled:NO];
	[self registerForDraggedTypes:[NSArray arrayWithObjects: NSURLPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
			if ([dropDelegate respondsToSelector:@selector(acceptsURL:)]) {
				if ([dropDelegate acceptsURL:[NSURL URLFromPasteboard:pboard]])
					return NSDragOperationCopy;
			}
		}
    }
	
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
		if ( [dropDelegate respondsToSelector:@selector(dropURL:)] ) {
			[dropDelegate dropURL:[NSURL URLFromPasteboard:pboard]];
		}
		return YES;
    }
    return NO;
}

- (id)dropDelegate {
    return dropDelegate;
}

- (void)setDropDelegate:(id)newDelegate {
    dropDelegate = newDelegate;
}

@end
