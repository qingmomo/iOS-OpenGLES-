//
//  TextureManager.h
//  LearnOpenGLES
//
//  Created by aj on 2017/3/8.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TextureManager : NSObject

/*
 *  通过UIImage的方式获取纹理对象
 */
+ (GLuint)getTextureImage:(UIImage *)image;

@end
