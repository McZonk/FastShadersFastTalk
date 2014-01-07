//
//  ViewController.m
//  FastShadersFastTalk
//
//  Created by Maximilian Christ on 06/12/13.
//  Copyright (c) 2013 McZonk. All rights reserved.
//

#import "ViewController.h"

#import "MyProgram.h"


@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;

@property (nonatomic, strong) NSData *positionData;
@property (nonatomic, strong) NSData *texcoordData;

@property (nonatomic, assign) float rotation;
@property (nonatomic, assign) GLKMatrix4 transform;

@property (nonatomic, strong) MyProgram *program;
@property (nonatomic, strong) GLPTexture *texture;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (void)setupGL
{
	float positions[12][3];
	float texcoords[12][2];
	
	positions[0][0] = 0.0f;
	positions[0][1] = 0.0f;
	positions[0][2] = 0.0f;

	texcoords[0][0] = 0.5f;
	texcoords[0][1] = 0.5f;

	for(int i = 0; i <= 10; ++i)
	{
		const float radius = (i & 1 ? 0.5f : 1.0f);
		const float angle = (i / 10.0f) * M_PI * 2.0f;
		
		const float x = cosf(angle) * radius;
		const float y = sinf(angle) * radius;
		
		positions[i+1][0] = x;
		positions[i+1][1] = y;
		positions[i+1][2] = 0.0f;
		
		texcoords[i+1][0] = x * 0.5f + 0.5f;
		texcoords[i+1][1] = y * 0.5f + 0.5f;
	}
	
	self.positionData = [NSData dataWithBytes:positions length:sizeof(positions)];
	self.texcoordData = [NSData dataWithBytes:texcoords length:sizeof(texcoords)];
	
    [EAGLContext setCurrentContext:self.context];
    
	self.program = [MyProgram programWithError:nil];
	
	self.texture = [GLPTexture textureWithUIImage:[UIImage imageNamed:@"Texture"]];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
	self.rotation += self.timeSinceLastUpdate * M_PI * 0.1;
	
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	
	GLKMatrix4 transform;
	if(aspect < 1.0)
	{
		transform = GLKMatrix4MakeOrtho(-1.2, 1.2, -1.2 / aspect, 1.2 / aspect, 0.0, 1.0);
	}
	else
	{
		transform = GLKMatrix4MakeOrtho(-1.2 * aspect, 1.2 * aspect, -1.2, 1.2, 0.0, 1.0);
	}
	transform = GLKMatrix4Rotate(transform, self.rotation, 0.0, 0.0, 1.0);
	self.transform = transform;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    MyProgram *program = self.program;
	GLPTexture *texture = self.texture;
	
	[program use];
	
	[program setTransform:self.transform.m];
	[program setTexture:0];
	
	[texture bindToUnit:0];
		
	glEnableVertexAttribArray(program.positionLocation);
	glVertexAttribPointer(program.positionLocation, 3, GL_FLOAT, GL_FALSE, 0, self.positionData.bytes);

	glEnableVertexAttribArray(program.texcoordLocation);
	glVertexAttribPointer(program.texcoordLocation, 2, GL_FLOAT, GL_FALSE, 0, self.texcoordData.bytes);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, 12);
}


@end
