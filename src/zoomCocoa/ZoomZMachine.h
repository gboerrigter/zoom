//
//  ZoomZMachine.h
//  ZoomCocoa
//
//  Created by Andrew Hunter on Wed Sep 10 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZoomProtocol.h"
#import "ZoomServer.h"

extern NSAutoreleasePool* displayPool;

@interface ZoomZMachine : NSObject<ZMachine> {
    // Remote objects
    NSObject<ZDisplay>* display;
    NSObject<ZWindow>*  windows[3];
    NSMutableAttributedString* windowBuffer[3];

    // The file
    ZFile* machineFile;

    // Some pieces of state information
    NSMutableString* inputBuffer;
    NSMutableArray*  outputBuffer;
}

- (NSObject<ZDisplay>*) display;
- (NSObject<ZWindow>*)  windowNumber: (int) num;
- (NSMutableString*)    inputBuffer;

- (void) bufferString: (NSString*) string
            forWindow: (int) windowNumber
            withStyle: (ZStyle*) style;
- (void) bufferMovement: (NSPoint) point
              forWindow: (int) windowNumber;
- (void) bufferEraseLine: (int) windowNumber;
- (void) bufferSetWindow: (int) windowNumber
               startLine: (int) startline;
- (void) bufferSetWindow: (int) windowNumber
                 endLine: (int) endline;
- (void) flushBuffers;

@end