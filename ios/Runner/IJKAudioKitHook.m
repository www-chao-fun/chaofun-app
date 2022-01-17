//
//  IJKAudioKitHook.m
//  Runner
//
//  Created by Yue Zhang on 2020/10/31.
//

#import <Foundation/Foundation.h>
#import "IJKAudioKitHook.h"
#import <objc/runtime.h>


@implementation IJKAudioKitHook

+(void)load {
    
 
    Method originalMethod_class = class_getInstanceMethod(self, NSSelectorFromString(@"setupAudioSession"));
    Method swizzledMethod_class = class_getInstanceMethod(NSClassFromString(@"IJKAudioKit"), NSSelectorFromString(@"setupAudioSession"));
    method_exchangeImplementations(originalMethod_class, swizzledMethod_class);

    NSLog(@"yes");
}

-(void) setupAudioSession {
    
}

-(BOOL) setActive: (BOOL) active {
    return true;
}
@end
