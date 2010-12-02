//
//  TestImage.m
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "TestImage.h"

@implementation TestImage

@synthesize name;

#pragma mark -

// returns array of TestImage objects
+ (NSArray *)images {
	NSError *error = nil;
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:bundleRoot error:&error];
	NSArray *images = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.jng'"]];
	NSMutableArray *list = [NSMutableArray array];
	
	for(NSString *imgName in images) {
		TestImage *img = [[TestImage alloc] init];
		img.name = imgName;
		[list addObject:img];
		[img release];
	}
	return list;
}

#pragma mark -

- (id)init {
	if(self = [super init]) {
		name = nil;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}


@end
