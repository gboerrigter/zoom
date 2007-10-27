//
//  ZoomLFlipView.m
//  ZoomCocoa
//
//  Created by Andrew Hunter on 27/10/2007.
//  Copyright 2007 Andrew Hunter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ZoomLFlipView.h"

#define NORECURSION									// Define to specify that no recursive animation should be allowed

@implementation ZoomFlipView(ZoomLeopardFlipView)

+ (void) initialize {
	[self exposeBinding: @"percentDone"];
}

+ (id) flipViewClass {
	static id classId = nil;
	if (!classId) {
		classId = [objc_lookUpClass("ZoomFlipView") retain];
	}
	return classId;
}

- (void) setupLayersForView: (NSView*) view {
	// Build the root layer
	if ([[self propertyDictionary] objectForKey: @"RootLayer"] == nil) {
		CALayer* rootLayer;
		[[self propertyDictionary] setObject: rootLayer = [CALayer layer]
									  forKey: @"RootLayer"];
		rootLayer.layoutManager = self;
		rootLayer.backgroundColor = [NSColor whiteColor];
		[rootLayer removeAllAnimations];
	}

	// Set up the layers for this view
	CALayer* viewLayer = [CALayer layer];
	viewLayer.backgroundColor = [NSColor whiteColor];
	[viewLayer removeAllAnimations];
	
	[view setLayer: viewLayer];
	[viewLayer setFrame: [[self layer] bounds]];
	
	if (![view wantsLayer]) {
		[view setWantsLayer: YES];
	}
	if (![self wantsLayer]) {
		[self setLayer: [[self propertyDictionary] objectForKey: @"RootLayer"]];
		[self setWantsLayer: YES];
	}
}

- (void) leopardPrepareViewForAnimation: (NSView*) view {
	if (view == nil) return;
	
	if ([[view superview] isKindOfClass: [self class]] && [[view layer] superlayer] != nil) {
		return;
	}
	
	[[self propertyDictionary] setObject: view
								  forKey: @"StartView"];
	
	// Setup the layers
	[self setupLayersForView: view];

	// Gather some information
	[originalView autorelease];
	[originalSuperview release];
	originalView = [view retain];
	originalSuperview = [[view superview] retain];
	originalFrame = [view frame];
	
	// Move the view into this view
	[[view retain] autorelease];
	[self setFrame: originalFrame];	

	[view removeFromSuperviewWithoutNeedingDisplay];
	[view setFrame: [self bounds]];
	
	[self addSubview: view];
	//[[self layer] addSublayer: [view layer]];
	[[self propertyDictionary] setObject: [view layer]
								  forKey: @"InitialLayer"];
	
	// Move this view to where the original view was
	[self setAutoresizingMask: [view autoresizingMask]];		
	[self removeFromSuperview];
	[self setFrame: originalFrame];
	[originalSuperview addSubview: self];
}

- (void) leopardAnimateTo: (NSView*) view
					style: (ZoomViewAnimationStyle) style {
	if (view == nil || view == originalView) {
		return;
	}
	
	if ([[view superview] isKindOfClass: [self class]] && [[view layer] superlayer] != nil) {
		[(ZoomFlipView*)[view superview] leopardAnimateTo: view
													style: style];
		return;
	}	
	
	[[self propertyDictionary] setObject: view
								  forKey: @"FinalView"];

	// Setup the layers for the specified view
	[self setupLayersForView: view];

	// Move the view into this view
	[[view retain] autorelease];
	
	[view removeFromSuperview];
	[view setFrame: [self bounds]];
	
	[self addSubview: view];
	//[[self layer] addSublayer: [view layer]];
	[[self propertyDictionary] setObject: [view layer]
								  forKey: @"FinalLayer"];
	
	// Set the delegate and layout manager for this object
	[self layer].delegate = self;
	[self layer].layoutManager = nil;
	
	// Run the animation
	[self setAnimationStyle: style];

	// Prepare to run the animation
	CABasicAnimation* initialAnim	= [CABasicAnimation animation];
	CABasicAnimation* finalAnim		= [CABasicAnimation animation];
	NSRect bounds = [self bounds];

	// Set up the animations depending on the requested style
	initialAnim.keyPath		= @"bounds";
	initialAnim.fromValue	= [NSValue valueWithRect: bounds];
	initialAnim.toValue		= [NSValue valueWithRect: NSMakeRect(bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.size.width, bounds.size.height)];

	finalAnim.keyPath		= @"bounds";
	finalAnim.fromValue		= [NSValue valueWithRect: NSMakeRect(bounds.origin.x - bounds.size.width, bounds.origin.y, bounds.size.width, bounds.size.height)];
	finalAnim.toValue		= [NSValue valueWithRect: bounds];
	
	// Set the common values
	initialAnim.timingFunction  = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	initialAnim.duration		= [self animationTime] * 8;
	initialAnim.repeatCount		= 1;
	initialAnim.delegate		= self;

	finalAnim.timingFunction	= [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	finalAnim.duration			= [self animationTime] * 8;
	finalAnim.repeatCount		= 1;
	//finalAnim.delegate			= self;
	
	// Animate the two views
	[[originalView layer] addAnimation: initialAnim
								forKey: nil];
	[[view layer] addAnimation: finalAnim
						forKey: nil];
}

- (void) leopardFinishAnimation {
	if (originalView) {
		NSView* finalView =[[self propertyDictionary] objectForKey: @"FinalView"];
		if (finalView == nil) return;
		
		// Ensure nothing gets freed prematurely
		[[self retain] autorelease];
		[[originalView retain] autorelease];
		[[finalView retain] autorelease];
		
		// Move to the final view		
		[[originalView layer] removeFromSuperlayer];

		// Self destruct
		[originalView removeFromSuperview];
		
		[originalView autorelease];
		originalView = [finalView retain];
		
		// Set the properties for the new view
		[[self propertyDictionary] setObject: originalView
									  forKey: @"StartView"];
		[[self propertyDictionary] setObject: [originalView layer]
									  forKey: @"InitialLayer"];
		[[self propertyDictionary] removeObjectForKey: @"FinalLayer"];
		[[self propertyDictionary] removeObjectForKey: @"FinalView"];
	}
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	if (flag) [self finishAnimation];
}

// = Animation properties =

- (void) setAnimationStyle: (ZoomViewAnimationStyle) style {
	[[self propertyDictionary] setObject: [NSNumber numberWithInt: style]
								  forKey: @"AnimationStyle"];
}

- (ZoomViewAnimationStyle) animationStyle {
	return [(NSNumber*)[[self propertyDictionary] objectForKey: @"AnimationStyle"] intValue];
}

- (void) setPercentDone: (double) percentage {
	NSLog(@"Percent Done: %g", percentage);
	[[self propertyDictionary] setObject: [NSNumber numberWithDouble: percentage]
								  forKey: @"PercentDone"];
	[[self layer] setNeedsLayout];
}

- (double) percentDone {
	NSNumber* result = [[self propertyDictionary] objectForKey: @"PercentDone"];
	if (result) {
		return [result doubleValue];
	} else {
		return 0;
	}
}
	 
// = Performing layout =

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	NSLog(@"Layout: %@", layer);
	if (layer != [self layer]) return;
	
	// Get the layers and percentages
	double percent		= [self percentDone];
	CALayer* initial	= [[layer sublayers] objectAtIndex: 0];
	CALayer* final		= [[layer sublayers] objectAtIndex: 1];
	
	// Set the size of the layers
	CGRect initialFrame		= layer.bounds;
	CGRect finalFrame		= layer.bounds;
	
	// Perform the animation
	initialFrame.origin.x	= self.bounds.size.width * percent;
	finalFrame.origin.x		= -self.bounds.size.width * (1-percent);
	
	// Set the layer positions
	initial.frame	= initialFrame;
	final.frame		= finalFrame;
}

@end
