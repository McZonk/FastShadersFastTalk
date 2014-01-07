// Autogenerated

#import <OpenGLPlus/GLPProgram.h>

@interface MyProgram : GLPProgram

+ (instancetype)programWithError:(NSError **)error;

// attributes
@property (nonatomic, assign, readonly) GLint positionLocation;
@property (nonatomic, assign, readonly) GLint texcoordLocation;

// uniforms
@property (nonatomic, assign, readonly) GLint alphaLocation;
@property (nonatomic, assign, readonly) GLint textureLocation;
@property (nonatomic, assign, readonly) GLint transformLocation;

- (void)setAlpha:(GLfloat)alpha;
- (void)setTexture:(GLint)texture;
- (void)setTransform:(const GLfloat[16])transform;

@end
