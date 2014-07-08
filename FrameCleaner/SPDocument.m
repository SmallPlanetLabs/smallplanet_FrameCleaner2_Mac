//
//  SPDocument.m
//  FrameCleaner
//
//  Created by Quinn McHenry on 7/7/14.
//  Copyright (c) 2014 Small Planet. All rights reserved.
//

#import "SPDocument.h"
#import "FCImage.h"

@implementation SPDocument



#pragma mark -


- (void) loadFrames {
    self.allFiles = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:NULL]];
    
    self.allImages = nil;
    
    // show first image
    if (self.allFiles.count > 0) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:[self.directoryPath stringByAppendingPathComponent:self.allFiles[0]]];
        self.imageView.image = image;
    }
}

- (void) showLoadFramesSheet {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles=NO;
    panel.canCreateDirectories=YES;
    panel.canChooseDirectories=YES;
    
    __weak typeof(panel) bpanel = panel;
    [panel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result) {
        if (result == 1 && bpanel.URLs.count > 0) {
            self.directoryPath = [[bpanel.URLs objectAtIndex:0] path];
            [self loadFrames];
        }
    }];

}

- (void) processFrames {
    for (NSView *view in [self.imageView subviews]) {
        [view removeFromSuperview];
    }
    globalFrame = CGRectZero;
    
    if (!self.allImages) {
        self.allImages = [NSMutableArray array];
        for (NSString *filename in self.allFiles) {
            NSString *filePath = [self.directoryPath stringByAppendingPathComponent:filename];
            if ([filePath hasSuffix:@".png"]) {
                FCImage *image = [[FCImage alloc] initWithSource:filePath];
                if (image) {
                    [self.allImages addObject:image];
                }
            }
        }
    }
    
    for (FCImage *image in self.allImages) {
        CGRect trimmedFrame = [image trimmedFrame];
        if (trimmedFrame.origin.x >= 0.f) {
            if ([self.allImages indexOfObject:image] == 0) {
                globalFrame = trimmedFrame;
            } else {
                globalFrame = CGRectUnion(globalFrame, trimmedFrame);
            }
        }
    }
    
    if ([self subregionsCount] > 0) {
        self.subregionData = nil;
        FCImage *firstImage = nil;
        for (FCImage *image in self.allImages) {
            if (!firstImage) {
                firstImage = image;
                self.subregionData = [NSMutableData dataWithLength:[[firstImage pixelData] length]];
            } else {
                NSData *diff = [firstImage subtract:image];
                unsigned char * ptr1 = (unsigned char*)[self.subregionData bytes];
                unsigned char * ptr2 = (unsigned char*)[diff bytes];
                
                for(int i=0; i<[self.subregionData length]; i++) {
                    if (*ptr2 > *ptr1) {
                        *ptr1 = *ptr2;
                    }
                    ptr1++;
                    ptr2++;
                }
            }
        }
        [FCImage dumpData:self.subregionData size:firstImage.size];
        [FCImage writeMaskImageFromData:self.subregionData size:firstImage.size toPath:@"/tmp/mask.png"];
    }
}

- (NSInteger) subregionsCount {
    return [self.maxSubregions selectedItem].tag;
}

#pragma mark - Toolbar item callbacks

- (IBAction) loadCallback:(id)sender {
    [self showLoadFramesSheet];
}

- (IBAction) processCallback:(id)sender {
    [self processFrames];
}

- (IBAction) editCallback:(id)sender {
    
}

- (IBAction) exportCallback:(id)sender {
    
}



#pragma mark - Document lifetime

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SPDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

@end
