//
//  ImageViewController.m
//  jng-image
//
//  Created by Andrew on 18/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "ImageViewController.h"
#import "JNGImage.h"

@implementation ImageViewController

@synthesize imageView, labelFile, labelInfo;
@synthesize images;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


- (id)initWithTestImageNumber:(int)num {
	if(self = [super init]) {
		currentImage = num;
		self.images = [TestImage images];
	}
	return self;
}

- (NSString *)imageInfo:(JNGImage *)jng {
	NSString *alphaType = ([jng alphaSampleDepth] == 0 ? @"none" :
						   [jng alphaCompressionMethod] == 0 ? @"PNG IDAT" : @"JDAA");
	UIImage *img = [jng image];
	return [NSString stringWithFormat:@"size:(%.0f,%.0f) interlace:%@ alpha:%@ depth:%d",
			img.size.width, img.size.height,
			[jng imageInterlaceMethod] == 0 ? @"sequential" : @"progressive",
			alphaType, [jng alphaSampleDepth]];
}

- (void)setImage {
	TestImage *testImage = [images objectAtIndex:currentImage];
	JNGImage *jng = [JNGImage imageNamed:testImage.name];
	UIImage *img = [jng image];
	CGSize vsize = self.view.frame.size;
	int width = vsize.width - 40;
	int height = img.size.height * width / img.size.width;
	
	imageView.frame = CGRectMake(20, 20, width, height);
	imageView.center = CGPointMake(vsize.width / 2, vsize.height / 2);
	imageView.image = img;
	labelFile.text = testImage.name;
	labelInfo.text = [self imageInfo:jng];
}

- (IBAction)reloadImage:(id)sender {
	[self setImage];
}

- (IBAction)nextImage:(id)sender {
	currentImage = (currentImage + 1) % [images count];
	[self setImage];
}

- (IBAction)prevImage:(id)sender {
	currentImage = (currentImage - 1 + [images count]) % [images count];
	[self setImage];	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Image";
	
	[self setImage];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.labelFile = nil;
	self.labelInfo = nil;
	self.imageView = nil;
	self.images = nil;
}


- (void)dealloc {
	[self viewDidUnload];
    [super dealloc];
}


@end
