//
//  MMImmutableScrapState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapView.h"
#import "NSArray+Map.h"


@interface MMScrapsOnPaperState (Private)

#pragma mark - Saving Helpers

-(NSUInteger) lastSavedUndoHash;
-(void) wasSavedAtUndoHash:(NSUInteger)savedUndoHash;

@end



@implementation MMImmutableScrapsOnPaperState{
    MMScrapsOnPaperState* ownerState;
    NSArray* allScrapsForPage;
    NSArray* scrapsOnPageIDs;
    NSString* scrapIDsPath;
    NSUInteger cachedUndoHash;
}

-(id) initWithScrapIDsPath:(NSString *)_scrapIDsPath andAllScraps:(NSArray*)_allScraps andScrapsOnPage:(NSArray*)_scrapsOnPage andScrapsOnPaperState:(MMScrapsOnPaperState*)_ownerState{
    if(self = [super init]){
        ownerState = _ownerState;
        scrapIDsPath = _scrapIDsPath;
        scrapsOnPageIDs = [_scrapsOnPage mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            return [obj uuid];
        }];
        allScrapsForPage = [_allScraps copy];
    }
    return self;
}

-(BOOL) isStateLoaded{
    return YES;
}

-(NSArray*) scraps{
    return [[allScrapsForPage filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        // only return scraps that are physically on the page
        // we'll save all scraps, but this method is used
        // to help generate the thumbnail later on, so we only
        // care about scraps on the page
        return [scrapsOnPageIDs containsObject:[evaluatedObject uuid]];
    }]] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        // sort the scraps, so that they are added to the thumbnail
        // in the correct order
        return [scrapsOnPageIDs indexOfObject:[obj1 uuid]] < [scrapsOnPageIDs indexOfObject:[obj2 uuid]] ? NSOrderedAscending : NSOrderedDescending;
    }];
}

-(BOOL) saveStateToDiskBlocking{
    NSLog(@"        - MMImmutableScrapsOnPaperState saveStateToDiskBlocking");
    __block BOOL hadAnyEditsToSaveAtAll = NO;
    if(ownerState.lastSavedUndoHash != self.undoHash){
        NSLog(@"        - MMImmutableScrapsOnPaperState ownerState.lastSavedUndoHash");
        hadAnyEditsToSaveAtAll = YES;
//        NSLog(@"scrapsOnPaperState needs saving last: %lu !=  now:%lu", (unsigned long) ownerState.lastSavedUndoHash, (unsigned long) self.undoHash);
        NSMutableArray* allScrapProperties = [NSMutableArray array];
        if([allScrapsForPage count]){
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
            NSLog(@"        - built sema1");
            
            __block NSInteger savedScraps = 0;
            NSLog(@"        - saving %d scraps", (int) [allScrapsForPage count]);
            void(^doneSavingScrapBlock)(BOOL) = ^(BOOL hadEditsToSave){
                savedScraps ++;
                NSLog(@"        - saved %d of %d", (int) savedScraps,(int) [allScrapsForPage count]);
//                hadAnyEditsToSaveAtAll = hadAnyEditsToSaveAtAll || hadEditsToSave;
                if(savedScraps == [allScrapsForPage count]){
                    // just saved the last scrap, signal
                    NSLog(@"        - signal sema1");
                    dispatch_semaphore_signal(sema1);
                }
            };
            
            for(MMScrapView* scrap in allScrapsForPage){
                NSDictionary* properties = [scrap propertiesDictionary];
                NSLog(@"        - asking scrap to save");
                [scrap saveScrapToDisk:doneSavingScrapBlock];
                // save scraps
                [allScrapProperties addObject:properties];
            }
            NSLog(@"        - waiting on sema1");
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        }
        
        if(!scrapIDsPath){
//            NSLog(@"on no");
        }
        
        NSLog(@"        - writing dictionary");
//        NSLog(@"saving %lu scraps on %@", (unsigned long)[scrapsOnPageIDs count], ownerState.delegate);
        NSDictionary* scrapsOnPaperInfo = [NSDictionary dictionaryWithObjectsAndKeys:allScrapProperties, @"allScrapProperties", scrapsOnPageIDs, @"scrapsOnPageIDs", nil];
        if([scrapsOnPaperInfo writeToFile:scrapIDsPath atomically:YES]){
//            NSLog(@"saved to %@", scrapIDsPath);
        }else{
            NSLog(@"failed saved to %@", scrapIDsPath);
        }
        [ownerState wasSavedAtUndoHash:self.undoHash];
    }else{
        NSLog(@"        - MMImmutableScrapsOnPaperState no edits");
        // we've already saved an immutable state with this hash
//        NSLog(@"scrapsOnPaperState doesn't need saving %lu == %lu", (unsigned long) ownerState.lastSavedUndoHash, (unsigned long) self.undoHash);
    }

    return hadAnyEditsToSaveAtAll;
}

-(void) unload{
    if([self isStateLoaded]){
        [self saveStateToDiskBlocking];
    }
    [super unload];
}


-(NSUInteger) undoHash{
    if(!cachedUndoHash){
        NSUInteger prime = 31;
        NSUInteger hashVal = 1;
        for(MMScrapView* scrap in allScrapsForPage){
            hashVal = prime * hashVal + [[scrap uuid] hash];
            if([scrap.state isScrapStateLoaded]){
                // if we're loaded, use the current hash
                hashVal = prime * hashVal + [scrap.state.drawableView.state undoHash];
            }else{
                // otherwise, use our most recently saved hash
                hashVal = prime * hashVal + [scrap.state lastSavedUndoHash];
            }
            NSDictionary* properties = [scrap propertiesDictionary];
            hashVal = prime * hashVal + [[properties objectForKey:@"center.x"] hash];
            hashVal = prime * hashVal + [[properties objectForKey:@"center.y"] hash];
            hashVal = prime * hashVal + [[properties objectForKey:@"rotation"] hash];
            hashVal = prime * hashVal + [[properties objectForKey:@"scale"] hash];
        }
        hashVal = prime * hashVal + 4409; // a prime from http://www.bigprimes.net/archive/prime/6/
        for(NSString* stroke in scrapsOnPageIDs){
            hashVal = prime * hashVal + [stroke hash];
        }
        cachedUndoHash = hashVal;
    }
    return cachedUndoHash;
}


@end
