//
//  Playground.h
//  SpiderWars
//
//  Created by Simone Vicentini on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface Playground : CCLayer
{
    b2World* world;
    GLESDebugDraw* m_debugDraw;
    b2Body* spider;
    b2Body* spiderAnchor;
    b2Joint* web;
}

    

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;



@end