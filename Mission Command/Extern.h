//
//  Extern.h
//  Mission Command
//
//  Created by josh on 3/29/26.
//

#import <ApplicationServices/ApplicationServices.h>

extern AXUIElementRef _AXUIElementCreateWithRemoteToken(CFDataRef data);
extern AXError _AXUIElementGetWindow(AXUIElementRef ref, uint32_t *wid);

extern int SLSMainConnectionID(void);
extern CFArrayRef SLSCopySpacesForWindows(int cid, int selector, CFArrayRef window_list);
extern CFTypeRef SLSWindowQueryWindows(int cid, CFArrayRef windows, int count);
extern CFArrayRef SLSCopyWindowsWithOptionsAndTags(
		int cid, uint32_t owner, CFArrayRef spaces,
		uint32_t options, uint64_t *set_tags, uint64_t *clear_tags
);
