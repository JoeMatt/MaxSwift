//
//  MaxCBridge.c
//  maxswift
//
//  Created by Joseph Mattiello on 8/6/16.
//
//

#include "MaxCBridge.h"
#include "ext_prefix.h"
#include "ext_proto.h"

void object_post_swift(t_object *x, C74_CONST char *s) {
    object_post(x, s);
}

void object_error_swift(t_object *x, C74_CONST char *s) {
    object_error(x, s);
    void object_warn(t_object *x, C74_CONST char *s, ...);

}

void object_warn_swift(t_object *x, C74_CONST char *s) {
    object_warn(x, s);
}