//
//  MaxCBridge.h
//  maxswift
//
//  Created by Joseph Mattiello on 8/6/16.
//
//

#ifndef MaxCBridge_h
#define MaxCBridge_h

#include <stdio.h>
//#include <ext_common.h>
//#include <max_types.h>
//#include <ext.h>

#include "ext_common.h"
#include "max_types.h"
#include "ext_mess.h"
//#include "commonsyms.h"

/*
 Functions to help deal with Max's variadic functions which are not presently automatically bridge by Swift
 */
void object_post_swift(t_object *x, C74_CONST char *s);
void object_warn_swift(t_object *x, C74_CONST char *s);
void object_error_swift(t_object *x, C74_CONST char *s);

#endif /* MaxCBridge_h */
