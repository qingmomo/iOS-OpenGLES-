//
//  GLESUtils.h
//  OpenGLES-02
//
//  Created by 黎仕仪 on 17/11/5.
//  Copyright © 2017年 shiyi.Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES3/gl.h>

@interface GLESUtils : NSObject

// Create a shader object, load the shader source string, and compile the shader.
//
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;

@end
