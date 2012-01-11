//
//  MultiNodeRevoluteRope.m
//  SpiderWars
//
//  Created by Simone Vicentini on 05/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MultiNodeRevoluteRope.h"

@implementation MultiNodeRevoluteRope

@synthesize bodies;

+(id) createWebWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) world
{
    return [[[self alloc] initWithAnchorAt:anchorPoint andAnchoredBody:body inWorld:world] autorelease];
}


-(id) initWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) myWorld
{
    
    self = [super init];
    if (self) 
    {
        self->anchors = [[NSMutableArray array] retain];
        [self setBodies:[NSMutableArray array]];
        self->world = myWorld;
        
        b2Vec2 bodyPosition = body->GetPosition();
        
        
        b2Vec2 xAxis;
        xAxis.x = 0;
        xAxis.y = 1;
        
        
        
        b2Vec2 dist = [self midpointBetweenBody:anchorPoint andBody:bodyPosition];
        
        b2Vec2 originalDist = anchorPoint - bodyPosition;
        
        float dot = b2Dot(originalDist, xAxis);
        float angle = acosf(dot / originalDist.Length());

        
        xAxis.x = -1;
        xAxis.y = 0;
        if (b2Dot(originalDist, xAxis) < 0.0f)
            angle = M_PI * 2 - angle;

        
        while (dist.Length() > 1.2f)
        {
            dist = [self midpointBetweenBody:anchorPoint andBody:(anchorPoint - dist)];
        }
        
        
        b2Vec2 nd = originalDist - dist;
        
        while (b2Dot(originalDist, nd) >= 0.0f)
        {
            b2Vec2* aa = new b2Vec2(bodyPosition + nd);
            
            
            [self->anchors addObject:[NSValue valueWithPointer:aa]];
            nd -= dist;
            
        }
        
        b2Vec2 lastPoint = *(b2Vec2 *)[[self->anchors lastObject] pointerValue];
        
        lastPoint = lastPoint - bodyPosition;
        if (b2Dot(originalDist, lastPoint) < dist.Length()/2)
            [self->anchors removeLastObject];
        
        b2Body* webAnchor = [self createAnchorAt:anchorPoint];
        b2Body* staticAnchor = webAnchor;
        [self->bodies addObject:[NSValue valueWithPointer:webAnchor]];
        [self->anchors insertObject:[NSValue valueWithPointer:&webAnchor->GetWorldCenter()] atIndex:0];

                
        int bodycount = [self->anchors count];

        float mass = body->GetMass() / (bodycount-1);


        
        
        b2Body* midWebAnchor;
        
        int i = 0;

        for (NSValue* v in self->anchors)
        {
            b2Vec2 aa = *(b2Vec2 *)[v pointerValue];
        
            
            midWebAnchor = [self createAnchorAt:aa withHeight:&dist andAngle:angle remainingMass:mass];
            
            [[self bodies] addObject:[NSValue valueWithPointer:midWebAnchor]];
            
            //midWebAnchor->SetLinearDamping(0.2f);
            
            
            b2RevoluteJointDef *jd = new b2RevoluteJointDef();
            if (i == 0)
            {
                jd->Initialize(webAnchor, midWebAnchor, webAnchor->GetWorldCenter());
            }
            else
            {
                jd->Initialize(webAnchor, midWebAnchor, aa);
            }

            
            world->CreateJoint(jd);
            webAnchor = midWebAnchor;
            i++;
        }
        
        
        b2RevoluteJointDef *jd = new b2RevoluteJointDef();
        jd->Initialize(midWebAnchor, body, body->GetWorldCenter());
        jd->collideConnected  =false;
        world->CreateJoint(jd);
        
        
        b2RopeJointDef *d = new b2RopeJointDef();
        d->bodyA = staticAnchor;
        d->bodyB = body;
        d->localAnchorA = staticAnchor->GetLocalCenter();
        d->localAnchorB = body->GetLocalCenter();
        d->maxLength = originalDist.Length() + dist.Length();

        
        self->ropeJoint = world->CreateJoint(d);   
    }
    
    return self;
}


-(BOOL) checkCutP1:(b2Vec2 *)p1 P2:(b2Vec2 *)p2
{
    b2RayCastInput input;
    input.p1 = *p1;
    input.p2 = *p2;
    input.maxFraction = 1;
    for (NSValue *body in [self bodies])
    {
        b2Body *m = (b2Body *) [body pointerValue];
        for (b2Fixture* f = m->GetFixtureList(); f; f = f->GetNext()) 
        {
            b2RayCastOutput output;
            if (f->RayCast(&output, input, 0))
            {
                [[self bodies] removeObject:body];
                world->DestroyBody(m);
                world->DestroyJoint(self->ropeJoint);
                
                return TRUE;
            }
                
        }
        
    }
    
    return FALSE;
}


-(b2Vec2) midpointBetweenBody:(b2Vec2)bodyA andBody:(b2Vec2)bodyB
{
    
    b2Vec2 hh = bodyA - bodyB;
    
    hh *= .5f;
    
    return hh;
    
}


-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint
{
    b2Body *anchor;
    b2BodyDef spiderAnchorDef;
    
    spiderAnchorDef.type = b2_staticBody;
	spiderAnchorDef.position = anchorPoint;
    
    
    anchor =  world->CreateBody(&spiderAnchorDef);
    
	b2PolygonShape box;

    box.SetAsBox(.5f, .5f);
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef1;
	fixtureDef1.shape = &box;	
	fixtureDef1.density = 1.0f; 
	fixtureDef1.friction = 0.0f;
    fixtureDef1.filter.groupIndex = -8;
    
	anchor->CreateFixture(&fixtureDef1);
    
    
	return anchor;
}

-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint withHeight:(b2Vec2*) h andAngle:(float) angle remainingMass:(float) mass
{
    b2Body *anchor;
    b2BodyDef spiderAnchorDef;
    
    spiderAnchorDef.type = b2_dynamicBody;
    b2Vec2 halfHeight = *h;
    halfHeight *= .5f;
	spiderAnchorDef.position = anchorPoint - halfHeight;
    spiderAnchorDef.angle = angle;
    
    anchor =  world->CreateBody(&spiderAnchorDef);
    
    
	b2PolygonShape box;
    b2Vec2 vertices[4];
    float height = halfHeight.Length() + 0.1f;
    vertices[0] = b2Vec2(-.05f, -height);
    vertices[1] = b2Vec2(.05f, -height);
    vertices[2] = b2Vec2(.05f, height);
    vertices[3] = b2Vec2(-.05f, height);
    
    box.Set(vertices, sizeof(vertices) / sizeof(vertices[0]) );
    
    
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef1;
	fixtureDef1.shape = &box;	
    float boxArea = 0.1 * height*2;
	fixtureDef1.density = mass / boxArea;

    fixtureDef1.filter.groupIndex = -8;
    
    
    
	anchor->CreateFixture(&fixtureDef1);
    

    
    
	return anchor;
    
}

-(void) dealloc
{
    
    for (NSValue *v in self->anchors)
    {
        delete (b2Vec2*)[v pointerValue];
    }
    for (NSValue *v in [self bodies])
        world->DestroyBody((b2Body*)[v pointerValue]);
    
    self->anchors = Nil;
    [super dealloc];
}



@end
