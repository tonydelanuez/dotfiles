// query_spaces.m – macOS helper that maps windows to Mission Control spaces
// via CoreGraphics and SkyLight private APIs.  Replaces yabai -m query.
//
// Compile:  clang -framework Foundation -framework CoreGraphics \
//                -framework AppKit -fobjc-arc -O2 -o query_spaces query_spaces.m

#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>

typedef int CGSConnectionID;

// ── private SkyLight/CoreGraphics symbols (loaded at runtime) ────────

static CGSConnectionID (*CGSMainConnectionID)(void);
static int (*CGSGetActiveSpace)(CGSConnectionID);
static CFArrayRef (*CGSCopySpaces)(CGSConnectionID, int);
static CFArrayRef (*SLSCopySpacesForWindows)(CGSConnectionID, int, CFArrayRef);

static bool load_symbols(void) {
  CGSMainConnectionID = dlsym(RTLD_DEFAULT, "CGSMainConnectionID");
  CGSGetActiveSpace = dlsym(RTLD_DEFAULT, "CGSGetActiveSpace");
  CGSCopySpaces = dlsym(RTLD_DEFAULT, "CGSCopySpaces");
  SLSCopySpacesForWindows =
      dlsym(RTLD_DEFAULT, "SLSCopySpacesForWindows");
  return CGSMainConnectionID && CGSCopySpaces && SLSCopySpacesForWindows;
}

// ── main ─────────────────────────────────────────────────────────────

int main(void) {
  @autoreleasepool {
    if (!load_symbols()) {
      fprintf(stderr, "query_spaces: SkyLight symbols not available\n");
      return 1;
    }

    CGSConnectionID cid = CGSMainConnectionID();

    // 1. Discover spaces & build internal→user index mapping ------------
    CFArrayRef spacesRaw = CGSCopySpaces(cid, 7);
    if (!spacesRaw) return 1;
    NSArray<NSNumber *> *internalIDs = CFBridgingRelease(spacesRaw);

    NSArray<NSNumber *> *sortedIDs =
        [internalIDs sortedArrayUsingSelector:@selector(compare:)];

    NSMutableDictionary<NSNumber *, NSNumber *> *internalToUser =
        [NSMutableDictionary dictionary];
    int userIdx = 1;
    for (NSNumber *idNum in sortedIDs) {
      internalToUser[idNum] = @(userIdx++);
    }

    int activeInternal = CGSGetActiveSpace ? CGSGetActiveSpace(cid) : -1;
    NSNumber *activeUser = internalToUser[@(activeInternal)];

    // 2. Discover windows — filter to real GUI app windows --------------
    CFArrayRef winsRaw = CGWindowListCopyWindowInfo(kCGWindowListOptionAll,
                                                    kCGNullWindowID);
    if (!winsRaw) return 1;
    NSArray<NSDictionary *> *allWindows = CFBridgingRelease(winsRaw);

    NSMutableArray<NSNumber *> *winIDs = [NSMutableArray array];
    NSMutableArray<NSString *> *winOwners = [NSMutableArray array];

    for (NSDictionary *w in allWindows) {
      // Only layer 0 (normal windows)
      NSNumber *layer = w[(__bridge NSString *)kCGWindowLayer];
      if (layer.intValue != 0) continue;

      // Only regular GUI apps (visible in Dock, not background agents)
      NSNumber *pid = w[(__bridge NSString *)kCGWindowOwnerPID];
      if (!pid) continue;
      NSRunningApplication *app =
          [NSRunningApplication runningApplicationWithProcessIdentifier:pid.intValue];
      if (!app || app.activationPolicy != NSApplicationActivationPolicyRegular)
        continue;

      // Exclude tiny proxy windows and thin toolbar strips
      NSDictionary *bounds = w[(__bridge NSString *)kCGWindowBounds];
      CGFloat ww = [bounds[@"Width"] doubleValue];
      CGFloat wh = [bounds[@"Height"] doubleValue];
      if (ww <= 1 || wh <= 40) continue;

      NSNumber *wid = w[(__bridge NSString *)kCGWindowNumber];
      NSString *owner = w[(__bridge NSString *)kCGWindowOwnerName];
      if (!wid || !owner) continue;

      [winIDs addObject:wid];
      [winOwners addObject:owner];
    }

    // 3. Map windows → spaces in batches of 3 (API limit) --------------
    NSMutableDictionary<NSNumber *, NSMutableSet<NSString *> *> *spaceApps =
        [NSMutableDictionary dictionary];

    const NSUInteger kBatchSize = 3;
    for (NSUInteger start = 0; start < winIDs.count; start += kBatchSize) {
      NSUInteger end = MIN(start + kBatchSize, winIDs.count);
      NSArray<NSNumber *> *batch =
          [winIDs subarrayWithRange:NSMakeRange(start, end - start)];

      CFArrayRef mapRaw =
          SLSCopySpacesForWindows(cid, 0x7, (__bridge CFArrayRef)batch);
      if (!mapRaw) continue;

      NSArray<NSNumber *> *mappedSpaces = CFBridgingRelease(mapRaw);

      for (NSUInteger i = 0; i < mappedSpaces.count && i < batch.count; i++) {
        NSNumber *internalSpace = mappedSpaces[i];
        NSNumber *userSpace = internalToUser[internalSpace];
        if (!userSpace) continue;

        NSString *owner = winOwners[start + i];
        NSMutableSet *apps = spaceApps[userSpace];
        if (!apps) {
          apps = [NSMutableSet set];
          spaceApps[userSpace] = apps;
        }
        [apps addObject:owner];
      }
    }

    // 4. Build JSON with user-visible space indices --------------------
    NSMutableArray *outputSpaces = [NSMutableArray array];

    for (NSNumber *idNum in sortedIDs) {
      NSNumber *userNum = internalToUser[idNum];
      NSMutableDictionary *entry = [NSMutableDictionary dictionary];
      entry[@"index"] = userNum;
      entry[@"focused"] = @([userNum isEqual:activeUser]);

      NSSet *apps = spaceApps[userNum];
      if (apps && apps.count > 0) {
        NSArray *sorted =
            [apps.allObjects sortedArrayUsingSelector:@selector(compare:)];
        entry[@"apps"] = sorted;
      } else {
        entry[@"apps"] = @[];
      }

      [outputSpaces addObject:entry];
    }

    NSDictionary *output = @{@"spaces" : outputSpaces};
    NSData *json =
        [NSJSONSerialization dataWithJSONObject:output options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:json
                                          encoding:NSUTF8StringEncoding];
    printf("%s\n", str.UTF8String);
  }
  return 0;
}
