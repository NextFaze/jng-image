//
//  JNGImageTestCase.m
//  JNGImage
//
//  Created by Andrew Williams on 18/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//
//  Link to Google Toolbox For Mac (IPhone Unit Test): 
//					http://code.google.com/p/google-toolbox-for-mac/wiki/iPhoneUnitTesting
//  Link to OCUnit:	http://www.sente.ch/s/?p=276&lang=en
//  Link to OCMock:	http://www.mulle-kybernetik.com/software/OCMock/


#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMConstraint.h>
#import "GTMSenTestCase.h"
#import <zlib.h>

#import "JNGImage.h"
#import "TestImage.h"

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

@interface JNGImageTestCase : GTMTestCase {
	//id mock; // Mock object used in tests	
}
@end

@implementation JNGImageTestCase

#if TARGET_IPHONE_SIMULATOR     // Only run when the target is simulator

- (void) setUp {
	//mock = [OCMockObject mockForClass:[NSString class]];  // create your mock objects here
	// Create shared data structures here
}

- (void) tearDown {
    // Release data structures here.
}

- (NSString *)imagePath:(NSString *)filename {
	return [NSString stringWithFormat:@"%s/images/samples/%@", TOSTRING(SOURCE_ROOT), filename];
}
- (NSData *)imageData:(NSString *)filename {
	return [NSData dataWithContentsOfFile:[self imagePath:filename]];
}

- (void)testImageWithContentsOfFile {

	NSArray *images = [TestImage images];
	for(TestImage *testimg in images) {
		LOG(@"testing load %@", testimg.name);
		JNGImage *img = [JNGImage imageWithContentsOfFile:[self imagePath:testimg.name]];
		STAssertNotNil(img, NULL);
	}
}

#endif

@end
