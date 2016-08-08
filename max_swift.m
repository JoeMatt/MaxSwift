/**
	@file
	maxswift - a Max external to help route SYSEX through Max for Live
        - Currently only implimented in CoreMIDI for OS X
	joe mattiello - mail@joemattiello.com

	@ingroup	M4L
*/

// Max
#include "ext.h"							// standard Max include, always required
#include "ext_obex.h"						// required for new style Max object
#include "z_dsp.h"
#include "commonsyms.h"

// For Obj-C objc_msgSend
#import <objc/objc.h>
#import <objc/objc-runtime.h>

#import <MaxSwift/MaxSwift.h>
#import <MaxSwift/MaxSwift-Swift.h>

//////// Define struct to hold our object state
typedef struct _maxswift
{
    t_object	ob;
    t_atom		val;
    t_symbol	*name;
    
    void    *inputsOutlet;  // Hookup for a umenu
    void    *outputsOutlet; // Hookup for a umenu
    
    __strong MaxSwift *swiftObject;
} t_maxswift;

//////////////////////// global class pointer variable
static t_class *maxswift_class = NULL;

///////////////////////// function prototypes
//// standard set
void *maxswift_new(t_symbol *s, long argc, t_atom *argv);
void maxswift_free(t_maxswift *x);
void maxswift_assist(t_maxswift *x, void *b, long m, long a, char *s);

t_max_err maxswift_int(t_maxswift *x, long n);
t_max_err maxswift_float(t_maxswift *x, double f);
t_max_err maxswift_anything(t_maxswift *x, t_symbol *s, long ac, t_atom *av);
t_max_err maxswift_list(t_maxswift *x, t_symbol *s, long argc, t_atom *argv);
t_max_err maxswift_bang(t_maxswift *x);
t_max_err maxswift_dblclick(t_maxswift *x);

#pragma mark -
#pragma mark Main
int C74_EXPORT main(void)
{
    post("Loaded MaxSwift build %s %s", __DATE__, __TIME__);

    t_class *c;
    
    c = class_new("maxswift", (method)maxswift_new, (method)maxswift_free, sizeof(t_maxswift),
                  (method)0L /* leave NULL!! */, A_GIMME, 0);
    //c->c_flags |= CLASS_FLAG_POLYGLOT;

    /////* ----------- INPUTS ------------------------------*/
    class_addmethod(c, (method)maxswift_bang,       "bang", 0);
    class_addmethod(c, (method)maxswift_int,        "int",		A_LONG, 0);
    class_addmethod(c, (method)maxswift_list,       "list",		A_GIMME, 0);
    class_addmethod(c, (method)maxswift_float,      "float",	A_FLOAT, 0);
    class_addmethod(c, (method)maxswift_anything,	"anything",	A_GIMME, 0);
    
    
    ///////* ----------- Methods aka messages ----------------*/
    ////class_addmethod(c, (method)c_method_name, "max_message_name", A_DEFSYM, 0);

    
    ///////* ------------ Actions -------------------------------*/
    class_addmethod(c, (method)maxswift_dblclick,  "dblclick",		A_CANT, 0);
    
    ///////* ------------ Other ----------------------------------*/
    class_addmethod(c, (method)maxswift_assist,    "assist",		A_CANT, 0);
    
    ///////* ------------ Properties ------------------------------*/
    CLASS_ATTR_SYM(c, "name", 0, t_maxswift, name);

    
    class_register(CLASS_BOX, c);
    maxswift_class = c;

    return 0;
}

///// Function for the help overlay
void maxswift_assist(t_maxswift *x, void *b, long m, long a, char *s)
{
    if (m == ASSIST_INLET) { //inlet
        sprintf(s, "I am inlet %ld", a);
    }
    else {	// outlet
        switch (a) {
            case 0:
                sprintf(s, "Incoming MIDI data");
                break;
            case 1:
                sprintf(s, "MIDI Output endpoints");
                break;
            case 2:
                sprintf(s, "MIDI Input endpoints");
                break;
                
            default:
                sprintf(s, "I am outlet %ld", a);
                break;
        }
    }
}

///// Max Calls Start
t_max_err maxswift_dblclick(t_maxswift *x) {
    return [x->swiftObject doubleClick];
}

t_max_err maxswift_int(t_maxswift *x, long n) {
    return [x->swiftObject int:n];
}

t_max_err maxswift_float(t_maxswift *x, double f) {
    return [x->swiftObject float:f];
}

t_max_err maxswift_anything(t_maxswift *x, t_symbol *s, long argc, t_atom *argv) {
    
    NSString *methodName = nil;
    SEL methodSelector   = NSSelectorFromString(methodName);
    
    // Make object array of the values
    NSMutableArray <MaxAtom*>*atomArray = [NSMutableArray arrayWithCapacity:argc];
    for (int i=0; i<argc; i++) {
        MaxAtom *atom = [[MaxAtom alloc] initWithAtom:argv[0]];
        [atomArray addObject:atom];
    }

    if (argc == 0) {
        // Try to call a method with no 'withValues' component
        [methodName release];
        methodName = [[NSString alloc] initWithCString:s->s_name encoding:NSUTF8StringEncoding];
        methodSelector = NSSelectorFromString(methodName);
        [methodName release];
        if([x->swiftObject respondsToSelector:methodSelector]) {
            return (t_max_err)objc_msgSend(x->swiftObject, methodSelector);
        }
    }

    [methodName release];
    methodName = [[NSString alloc] initWithFormat:@"%sWithValues:",s->s_name];
    methodSelector = NSSelectorFromString(methodName);
    // Try to call 'nameWithValues:'
    if([x->swiftObject respondsToSelector:methodSelector]) {
        [methodName release];
        methodName = [[NSString alloc] initWithFormat:@"%sWithValues:",s->s_name];
        return (t_max_err)objc_msgSend(x->swiftObject, methodSelector, atomArray);
    } else {
        
        // Call the anything selector
        [methodName release];
        methodName     = @"anything:withValues:";
        methodSelector = NSSelectorFromString(methodName);
        [methodName release];
        if([x->swiftObject respondsToSelector:methodSelector]) {
            // TODO: Fix this crash
            //return (t_max_err)objc_msgSend(x->swiftObject, methodSelector, s, atomArray);
        }
    }
    
    return MAX_ERR_GENERIC;
}

t_max_err maxswift_list(t_maxswift *x, t_symbol *s, long argc, t_atom *argv) {

    NSMutableArray <MaxAtom*>*atomArray = [NSMutableArray arrayWithCapacity:argc];
    for (int i=0; i<argc; i++) {
        MaxAtom *atom = [[MaxAtom alloc] initWithAtom:argv[0]];
        [atomArray addObject:atom];
    }
    
    t_max_err retValue = [x->swiftObject list:atomArray];

    return retValue;
}


t_max_err maxswift_bang(t_maxswift *x) {
    return [x->swiftObject bang];
}
///// Max calls end

///// Create a new object here
void *maxswift_new(t_symbol *s, long argc, t_atom *argv)
{
    t_maxswift *x = NULL;


    if ((x = (t_maxswift *)object_alloc(maxswift_class))) {

        // Make name symbol
        x->name = gensym("");
        if (argc && argv) {
            x->name = atom_getsym(argv);
        }
        if (!x->name || x->name == gensym(""))
            x->name = symbol_unique();
        
        atom_setlong(&x->val, 0);
        
        x->inputsOutlet  = outlet_new(x, NULL);
        x->outputsOutlet = outlet_new(x, NULL);
        
         //Create Obj-c / Swift object
        MaxSwift *swiftObject = [[MaxSwift alloc] initWithMaxObject:x->ob];
        x->swiftObject = swiftObject;
    } else {
        error("Failed to create new t_maxswift");
    }
    
    return (x);
}

///// Free any manually managaed memory here
void maxswift_free(t_maxswift *x) {
    if (x->swiftObject != NULL) {
        [x->swiftObject release];
        x->swiftObject = NULL;
    }
}
