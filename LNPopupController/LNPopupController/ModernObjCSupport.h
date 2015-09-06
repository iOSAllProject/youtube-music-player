//
//  ModernObjCSupport.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#ifndef __MODERN_OBJC_SUPPORT_H
#define __MODERN_OBJC_SUPPORT_H

#ifndef _ 
#define _ 
#endif

#ifndef _ 
#define _ 
#endif

#if __has_feature(objc_generics)
#define LNObjectOfKind(type) __kindof type
#define LNArrayOfType(type) NSArray<type>
#define LNDictionaryOfType(t1,t2) NSDictionary<t1, t2>
#else
#define LNObjectOfKind(type) type
#define LNArrayOfType(type) NSArray
#define LNDictionaryOfType(t1,t2) NSDictionary
#endif

#endif