//
//  SpiderWebRope.h
//  SpiderWars
//
//  Created by Simone Vicentini on 29/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpiderWeb.h"

@interface SpiderWebRope : NSObject <SpiderWeb>
{
    @private
    

}
+(id) rope;
-(void) InitialiseWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(const b2Body&)body inWorld:(b2World *) world;

@end
