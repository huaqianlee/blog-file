title: Andy Lee's C coding style
date: 2021-08-09 23:36:00
categories:
- C/C++
tags: 
- coding style
---

This document describes C code style used by Andy Lee in his projects and libraries.

# Table of Contents

- [Andy Lee's C coding style](#andy-lee's-c-coding-style)
	- [Table of Contents](#table-of-Contents)
	- [General Rules](#general-rules)
	- [Formatting](#formatting)
		- [Indentation](#indentation)
			- [Common Case](#common-case)
			- [Exception Case](#exception-case)
		- [Braces, Parentheses and Spaces placement](#braces%2C-parentheses-and-spaces-placement)
			- [Braces](#braces)
			- [Parentheses](#parentheses)
			- [Spaces](#spaces)
		- [Line Break](#line-break)
		- [If then Else Formatting](#if-then-else-formatting)
		- [Switch Formatting](#switch-formatting)
	- [Naming Also Declaration](#naming-also-declaration)
		- [Make Names Fit](#make-names-fit)
		- [File Names](#file-names)
		- [Function Names](#function-names)
		- [Variable Names](#variable-names)
			- [Local Variable Names](#local-variable-names)
			- [Global Variable Names](#global-variable-names)
		- [Type Names](#type-names)
		- [Structure Names](#structure-names)
		- [Pointer](#pointer)
		- [Global Constants](#global-constants)
		- [Macro Names](#macro-names)
		- [Enum Names](#enum-names)
	- [Functions](#functions)
        - [Function Prototypes](#function-prototypes)
        - [Unwritten Rules](#unwritten-rules)
        - [Inline Functions](#inline-functions)
	- [Structures](#structures)
        - [Structure Requirements](#structure-requirements)
        - [Labeled Identifiers Explained](#labeled-identifiers-explained)
    - [Variables, Macro and Constants](#variables%2C-macro-and-constants)
		- [Declare counter variables in for loop](#declare-counter-variables-in-for-loop)
        - [Floating-point Variables](#floating-point-variables)
        - [Do Not Put Data Definitions in Header Files](#do-not-put-data-definitions-in-header-files)
        - [Be Cautious With Macros](#be-cautious-with-macros)
		- [Bad To Affect Control Flow in Macros](#bad-to-affect-control-flow-in-macros)
		- [Namespace Collisions in Macros](#namespace-collisions-in-macros)
	- [Miscellaneous](#miscellaneous)
        - [No Magic Number](#no-magic-number)
        - [No #ifdef in .c file](#no-%23ifdef-in-.c-file)
        - [#if is preferred not #ifdef](#%23if-is-preferred-not-%23ifdef)
        - [Use Header File Guard](#use-header-file-guard)
        - [Do Not Default If Test To Nonzero](#do-not-default-if-test-to-nonzero)
        - [Usually avoid Embedded Assignments](#usually-avoid-embedded-assignments)
        - [Use of Goto, Continue, Break and ?:](#use-of-goto%2C-continue%2C-break-and-%3F%3A)
        - [Mixing C and C++](#mixing-c-and-c%2B%2B)
        - [Document Null Statements](#document-null-statements)
        - [Error Return Check Policy](#error-return-check-policy)
	- [Commenting](#commenting) 
        - [Comment Style](#comment-style)
        - [Commenting to Closing Braces](#commenting-to-closing-braces)
        - [Commenting Out Large Code Blocks](#commenting-out-large-code-blocks)
        - [Include Statement Documentation](#include-statement-documentation)
    -  [Documentation](#documentation)
        - [Gotcha Keywords](#gotcha-keywords)
		- [File header](#file-header)
		- [Function header](#function-header)
		- [Formatting](#formatting)
		- [How Do They Look Like?](#how-do-they-look-like%3F)
		- [Tips and Tricks](#tips-and-tricks)
            - [VS Code](#vs-code)
            - [Vim](#vim)
	- [Reference](#reference)

# General Rules

In short, consistency matters.
<!--more-->

And, if you are working on upstream or existing projects, please follow the original coding style.

For example, Linux Kernel community requires its own coding style strictly, so we should follow [Linux kernel coding style](https://www.kernel.org/doc/html/v6.1/process/coding-style.html).
> The link is the latest version currently, in case there is any updates, please always check the latest version.

# Formatting

Mainly follow K&R style:

![indetation-k&r](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/C/indentation.png)

## Indentation

### Common Case

Use only spaces, and indent 4 spaces at a time.

We use spaces for indentation. Do not use tabs in your code. You should set your editor to emit spaces when you hit the tab key. For example, we can configure vim as follows.

```vim
set tabstop=4 " set tab's width to 4
set expandtab " replace tab with space
set shiftwidth=4 " set indentation to 4

" Kernel programming, cinoptions to set no switch indention
au BufRead /path/to/kernel/* setlocal shiftwidth=8 softtabstop=8 tabstop=8 cinoptions=:0,g0,(0,w1
```

### Exception Case

If you are developing Linux kernel, please

- Use tabs.
- All tabs are 8 characters.
- If your code is indenting too deeply, fix your code.
> More detailed please visit [Linux kernel coding style - Indentation](https://www.kernel.org/doc/html/v6.1/process/coding-style.html#indentation).

## Braces, Parentheses and Spaces Placement

### Braces

- Opening brace last on the line.
- Closing brace first on the line.
- Exception for functions.

```c
// All non-function statement blocks (if, switch, for, while, do)
if (condition) {
    // Do something ...
}

while (condition) {
    // Do something ...
}

for (;;) {
    // Do something ...
}

switch (action) {
    // Do something ...
}

// Functions
int main(int argc, char *argv[])
{
	// Do something ...
	return 0;
}
```

Note that the closing brace is empty on a line of its own, except in the cases where it is followed by a continuation of the same statement, like a while in a do-statement or an else in an if-statement:

```c
do {
	// Do something ...
} while (condition);
```

and

```c
if (x == y) {
	// Do something ...
} else if (x > y) {
	// Do something ...
} else {
	// Do something ...
}
```

Do not unnecessarily use braces where a single statement will do.

```c
if (condition)
    action();

// Only when a short statement
if (condition) action();
```

and

```c
if (condition)
	do_this();
else
	do_that();
```

This does not apply if only one branch of a conditional statement is a single statement, it must keep the consistency.

```c
if (condition) {
	do_this();
	do_that();
} else {
	otherwise();
}
```

All while and do statements must have braces when a loop contains more than a single simple statement.

```c
while (ture)
	do_something();

do
	do_something();
while (true);

while (true) {
	do_this();
	do_that();
}

do {
	do_this();
	do_that();
} while (true);
```

### Parentheses

Parentheses () with key words and function policy.

- Do not put parentheses next to keywords, put a space between.
- Do put parentheses next to function name.
- Do not use parentheses in return statement when is not necessary.
- Do not add spaces around (inside) parenthesized expressions.

```c
if (condition) {
	// Do something ...
}

while (condition) {
	// Do something ...
}

void func(int arg1, int arg2)
{
	// Do something ...
}

func(arg1, arg2);

// Don't
return (1);

// Don't
sizeof( int );
```

### Spaces

The use of spaces depends (mostly) on function-versus-keyword usage. Use a space after (most) keywords except sizeof, typeof, alignof and __attribute__, which look somewhat like functions.

So use a space after these keywords:

```c
if, switch, case, for, do, while
```

but not with sizeof, typeof, alignof, or __attribute__. E.g.,

```c
s = sizeof(struct file);
```

Use one space around (on each side of) most binary and ternary operators, such as any of these:

```c
=  +  -  <  >  *  /  %  |  &  ^  <=  >=  ==  !=  ?  :
```

but no space after unary operators:

```c
&  *  +  -  ~  !  sizeof  typeof  alignof  __attribute__  defined

// Such as
&x *x +x -x ~x !x sizeof(x) ... defined(x)
```

no space before or after the increment & decrement unary operators:

```c
++  --
```

and no space around the `.` and `->` structure member operators.

## Line Break

- The preferred limit on the length of a single line is 80 columns.
- Statements longer than 80 columns should be broken into sensible chunks, unless exceeding 80 columns significantly increases readability and does not hide information.
- Descendants are always substantially shorter than the parent and are placed substantially to the right. A very commonly used style is to align descendants to a function open parenthesis.
- These same rules are applied to function headers with a long argument list.
- Never break user-visible strings such as log messages because that breaks the ability to grep for them.

## If then Else Formatting

The common approach is:
```c
if (condition) {
	// Do something ...
} else if (condition) {
	// Do something ...
} else {
    // not handled cases or log message
}
```
If one `else if` statement exists then it is usually a good idea to always have an `else` block for finding not handled cases, maybe put a log message in the else even if there is no corrective action taken.

## Switch Formatting

- Falling through a case statement into the next case statement shall be permitted as long as a comment is included.
- The default case should always be present and trigger an error if it should not be reached, yet is reached.
- If you need to create variables put all the codes in a block.

```c
switch (action) {
case 1:
    // Do something ...
/* comments */
case 2:
    // Do something ...
    break;
case 3:	{
	int ret = 0;
	// Do something ...
	break;
}
default:
    // Do something ...
}
```

# Naming Also Declaration

## Make Names Fit

Names are the heart of the programming. If the name is appropriate everything fits together naturally, relationships are clear, meaning is derivable, and reasoning from common human expectations works as expected.

So, please

- Be descriptive
- Be concise
- No Mixed Case
- No encoding type within the name
- Global variables only when necessary
- Local variables short ant to the point

If you find all your names could be Thing and Dolt then you should probably revisit your design.

## File Names

Filenames should be all lowercase with words separated by underscores (`_`). 

C files should end in `.c` and header files should end in `.h`. Do not use filenames that already exist in `/usr/include`, such as `db.h`.

In general, make your filenames very specific. For example, use `http_server_logs.h` rather than `logs.h`. A very common case is to have a pair of files called, e.g., `foo_bar.h` and `foo_bar.c`.

## Function Names

Usually every function performs an action, so the name should make sure what it does.

| Maybe           | Better                |
|-----------------|-----------------------|
| `error_check()` | `check_for_error()`   |
| `data_file()`   | `dump_data_to_file()` |
| `moving()`      | `is_moving()`         |

> This also makes functions and data objects more distinguishable.

Structures and variables are often nouns. By making function names verbs and following other naming convention programs can be read more naturally.

Prefixes are sometimes useful:

- is - to ask a question about something
- get - to get a value
- set - to set a value
> `is_hit_retry_limit()`, `get_retry_count()`, `set_retry_count()`.

## Variable Names

One statement per line, there should be only one statement per line unless the statements are closely related.

```c
// Don't
int *a, *x;

// Do
int *a;
int *x;
```

Suffixes are sometimes suggested:

- max - to mean the maximum value something can have
- count - the current count of a running count variable
- key - key value
> retry_max to mean the maximum number of retries, retry_count to mean the current retry count.

If a variable represents time, weight, or some other unit then include the unit in the name is a good idea.

| Maybe         | Better              |
|---------------|---------------------|
| `int timeout` | `int timeout_msecs` |
| `int length`  | `int length_meters` |
| `int weight`  | `int32 weight_lbs`  |

And always initialize all variables is good, sure it is okay to leave global variables and static variables to compiler.

### Local Variable Names

- Use all lower case letters.
- Use '_' as the word separator.

```c
int handle_error (int error_number) {
    int                 error = os_err();
    time_t              time_of_error;
    error_processor_t	error_processor;
}
```

### Global Variable Names

Good to be prepended with a 'g_'. Global variables should be avoided whenever possible, follow the same rules of local variable when you do need a global variable.

```c
int g_count = 0;
```
## Type Names

Type names are all lowercase, and good to end with a "_t" suffix, e.g.:

```c
typedef struct foo {
    char *name;
} foo_t;
```

If possible, do not use typedef, which hides the real type of the variable.

## Structure Names

Use underscore(`_`) to separate name components, use all lower case letters.

When declaring variables in structures, declare them organized use in manner to attempt to minimize memory wastage because of compiler alignment issue, then by size, and then by alphabetical order.

<table>
<tr>
<td><b> Don't <b></td>
<td><b> Better <b></td>
</tr>
<tr>
<td>

```c
struct x {
  int a;
  char *b;
  int c;
  char *d
}
```

</td>
<td>

```c
struct x {
  int a;
  int c;
  char *b;
  char *d
}
```

</td>
</tr>
</table>

Sometimes, it may be useful to use a meaning prefix for each member name. For example, for `struct car` the prefix could be `sc_brand`, `sc_*`.

Major structures should be declared at the top of the file in which they are used, or in separate header files, if they are used in multiple source files.

Use of structures should be separate declarations and should be `extern` if declared in a header file.

Each variable gets its own type and line, although an exception can be made when declaring bit fields (to clarify that it's part of the one bit fields).
> The use of bit fields in general is discouraged.

```c
struct foo {
	struct foo *next;	/* List of active foo */
	struct mumble amumble;	/* Comment for mumble */
	int bar;
	unsigned int baz:1,	/* Bitfield; line up entries if desired */
		     fuz:5,
		     zap:2;
	uint8_t flag;
};

struct foo *foohead;		/* Head of global foo list */
```

## Pointer

For variables of pointer types, a good idea is to prefix the name with "p_". Additionally, use "pp_" for pointer-to-pointer types. If you need three layers of indirection, consider restructuring your code.

Place the `*` close to the variable name and the function name not pointer type.

```c
int *p_length = NULL;

char *name = NULL;

unsigned long long memparse(char *ptr, char **retptr);

char *match_strdup(substring_t *s);
```

## Global Constants

Global constants should be all capitalized with '_' separators.

```c
const int GLOBAL_MAXIMUM_NUM = 100;
```

## Macro Names

Put `#define` and `macros` in all upper with '_' separator. Macros should be capitalized, parenthesized, and should avoid side-effects.

If the macro is an expression, warp the expression in parenthesis.

If the macro is more than a single statement, use `do {...} while(0)`, so that a trailing semicolon works. Right-justify the backslashes, which makes it easier to read.

```c
#define MAX(a,b) ((a > b) ? a : b)
#define	MACRO(v, w, x, y)   \
	do {					\
	v = (x) + (y);			\
	w = (y) + 2;			\
} while (0)

// Don't
#define ADD(x, y) x + y

// Better
#define ADD(x, y) ((x) + (y))
```

Make Macro Name unique.

- Prepend macro names with package names is a good idea.
- Avoid simple and common names like MAX and MIN.

## Enum Names

Enumeration type names should follow the general rules for types. Names are all lowercase, separated by underscores. 

Labels all upper case with "_" word separators, no comma on the last element.

```c'
enum pin_state_type {
    PIN_ON,
    PIN_OFF
};
```

Make a label for an error state is useful to be able to say an enum is not in any of its valid states. Make a label for uninitialized or error state, make it the first label if possible.

```c
enum {STATE_ERR, STATE_OPEN, STATE_RUNNING, STATE_PAUSING, STATE_DYING};
```

# Functions

- Do one thing, and do it well.
- Short, one or two screens of code.
    - The idea is that each method represents a technical for archiving a single objective.
- OK to have longer function doing small different things.
- If more than 10 local variables, too complex.

## Function Prototypes

In function prototypes, include parameter names with their data types. Although this is not required by the C language, it is preferred because it is a simple way to add valuable information for the reader.

Do not use the `extern` keyword with function declarations as this makes lines longer and isn’t strictly necessary.

```c
/* .c file */
int foo(int arg1, int arg2)
{
	// Do something
	return 0;
}

/* .h file */
// Don't
int foo(arg1, arg2);

// Better
int foo(int arg1, int arg2);
```

## Unwritten Rules

Use code that is already present, such as:

- String functions
- Byte order functions
- Linked lists

## Inline Functions

Define functions inline only when they are small, say, 10 lines or less.

You can declare functions in a way that allows the compiler to expand them inline rather than calling them through the usual function call mechanism.

Inline functions should be in a .h file. If your inline functions are very short, they should go directly into your .h file.

```c
// my_error.h

#define IS_ERR(value) unlikely(value >= MAX_VALUE)

static incline bool is_error_size(int size)
{
	return IS_ERR(size);
}

```

# Structures

## Structure Requirements

Data structures that have visibility outside the single-threaded environment they are created and destroyed in should always have reference counts. 

Reference counting means that you can avoid locking, and allows multiple users to have access to the data structure in parallel - and not having to worry about the structure suddenly going away from under them just because they slept or did something else for a while.

Remember:

> "If another thread can find your data
>  structure, and you do not have a
>  reference count on it, you almost
>  certainly have a bug."

## Labeled Identifiers Explained

```c
struct foo {
   int a;
   int b;
};
```

Old way:

```c
static struct foo bar =
{
    A_INIT,
    B_INIT
};
```

Labeled way:

```c
static struct foo bar = {
   a:  A_INIT,
   b:  B_INIT,
};

// Also good
static struct foo bar = {
   .a =  A_INIT,
   .b =  B_INIT,
};
```

# Variables, Macro and Constants

## Declare Counter Variables in For Loop

```c
// Do
for (size_t i = 0; i < 10; ++i)

// If you need counter variable later
size_t i;
for (i = 0; i < 10; ++i) {
    if (...) {
        break;
    }
}
if (i == 10) {

}

// Don't
size_t i;
for (i = 0; i < 10; ++i) ...
```

## Floating-point Variables

Don't use floating-point variables where discrete values are needed. Using a float for a loop counter is a great way to shoot yourself in the foot.

Always test floating-point numbers as `<=` or `>=`, never use an exact comparison (`==` or `!=`).

## Do Not Put Data Definitions in Header Files 

For example:
```c
/*
 * aheader.h
 */
int x = 0;
```

## Be Cautious With Macros

Prefer inline functions, enums, and const variables to macros.

```c
#define  MAX(x,y)   (((x) > (y) ? (x) : (y))    // Get the maximum

inline int max(int x, int y) {
	 return (x > y ? x : y);
}
```

## Bad To Affect Control Flow in Macros

Macros that affect control flow:

```c
#define FOO(x)                              \
    do {                                    \
            if (blah(x) < 0)                \
                    return -EBUGGERED;      \
    } while (0)
```

## Namespace Collisions in Macros

`ret` is a common name for a local variable,  `__foo_ret` is less likely to collide with an existing variable.

```c
#define FOO(x)                          \
({                                      \
        typeof(x) ret;                  \
        ret = calc_ret(x);              \
        (ret);                          \
})
```

# Miscellaneous

## No magic number

```c
if (22 == foo)
	start_thermo_nuclear_war();
else if (19 == foo)
	refund_lotso_money();
else if (16 == foo)
	infinite_loop();
else
	cry_cause_im_lost();


#define   PRESIDENT_WENT_CRAZY  (22)
const int WE_GOOFED= 19;
enum  {
   THEY_DIDNT_PAY= 16
};

if (PRESIDENT_WENT_CRAZY == foo)
	start_thermo_nuclear_war();
else if (WE_GOOFED            == foo)
	refund_lotso_money();
else if (THEY_DIDNT_PAY       == foo)
	infinite_loop();
else
    happy_days_i_know_why_im_here();
```

## No #ifdef in .c file

`#ifdef` belongs to .h file, make it happen in .h file. Let the compiler do the work.

Before:

```c
// drivers/usb/hid_core.c
static void hid_process_event (struct hid_device *hid, struct hid_field *field,
                                  struct hid_usage *usage, __s32 value)
{
        hid_dump_input(usage, value);
        if (hid->claimed & HID_CLAIMED_INPUT)
                hidinput_hid_event(hid, field, usage, value);
#ifdef CONFIG_USB_HIDDEV
        if (hid->claimed & HID_CLAIMED_HIDDEV)
                hiddev_hid_event(hid, usage->hid, value);
#endif
}
```

After:
```c
// include/linux/hiddev.h
#ifdef CONFIG_USB_HIDDEV
        extern void hiddev_hid_event (struct hid_device *, unsigned int usage,
                                          int value);
#else
        static inline void hiddev_hid_event (struct hid_device *hid,
                                                  unsigned int usage, int value)
                                                 { }
#endif

// drivers/usb/hid_core.c
static void hid_process_event (struct hid_device *hid, struct hid_field *field,
                                  struct hid_usage *usage, __s32 value)
{
        hid_dump_input(usage, value); 
        if (hid->claimed & HID_CLAIMED_INPUT)
                hidinput_hid_event(hid, field, usage, value);
        if (hid->claimed & HID_CLAIMED_HIDDEV)
                hiddev_hid_event(hid, usage->hid, value);
}
```

## #if is preferred not #ifdef

Use `#if` MACRO not `#ifdef` MACRO. Someone might write code like:

```c
#ifdef DEBUG
        temporary_debugger_break();
#endif
```

Always use `#if`, if you have to use the preprocessor. This works fine, and does the right thing, even if `DEBUG` is not defined at all (!)
```c
#if DEBUG
        temporary_debugger_break();
#endif
```

If you really need to test whether a symbol is defined or not, test it with the defined() construct, which allows you to add more things later to the conditional without editing text that's already in the program:
```c
#if !defined(USER_NAME)
 #define USER_NAME "C Language"
#endif
```

## Use Header File Guard

Include files should protect against multiple inclusion through the use of macros that guard the files.

```c
#ifndef MY_CODE_H
#define MY_CODE_H

#endif // MY_CODE_H
```

## Do Not Default If Test To Nonzero

The non-zero test is often defaulted for predicates and other functions or expressions which meet the following restrictions: Returns 0 for false, nothing else.

Is named so that the meaning of a true return is absolutely obvious.

```c
// Don't
if (true == is_valid())
	do_something();

// Better
if (is_valid())
	do_something();
```

Otherwise:

```c
// Don't
if (foo())
if (!(size%2))

// Better
if (FAILED != foo())
if(0 == (size%2))
```

## Usually avoid Embedded Assignments

```c
   a = b + c;
   d = a + r;
```

Should not be replaced by

```c
   d = (a = b + c) + r;
```

There is a time and a place for embedded assignment statements. In some constructs there is no better way to accomplish the results without making the code bulkier and less readable.

```c
while (EOF != (c = getchar())) {
      process the character
}
```

## Use of Goto, Continue, Break and ?:

The `goto` statement should be used sparingly, the main place where it can be usefully employed is to break out several levels of initialization with sequence, switch, for, and while nesting with a success or failure return code.

Actually, the `goto` statement is recommended only when a function exits from multiple locations and some common work such as cleanup has to be done. If there is no cleanup needed then just return directly.

Choose label names which say what the `goto` does or why the `goto` exists.

```c
int fun(int a)
{
    int result = 0;
    char *buffer;

    buffer = kmalloc(SIZE, GFP_KERNEL);
    if (!buffer)
            return -ENOMEM;

    if (condition) {
            while (loop) {
                    ...
            }
            result = 1;
            goto out_free_buffer;
    }
    ...
out_free_buffer:
    // clean up the mess
	kfree(buffer);
	return result;
}
```

`continue` and `break` like `goto` should be used sparingly as they are magic in code. Mixing `continue` with `break` in the same loop is a sure way to disaster.

`?:`

- Put the condition in parentheses
- If possible, make the action simple or a function
- Put the action for the then and else statement on a separate line unless it can be clearly put on one line.

```c
(condition) ? func1() : func2()

(condition)
    ? long statement
    : another long statement
```

## Mixing C and C++

Calling C Functions from C++
```c
extern "C" int strncpy(...);
extern "C" int my_great_function();
extern "C"
{
   int strncpy(...);
   int my_great_function();
};
```

Creating a C Function in C++
```c
extern "C" void a_c_function_in_cplusplus(int a)
{
}
```

Make the C code compatible with C++ linkers.
```c
#ifdef __cplusplus
extern "C" {
#endif

// all of your legacy C code here

#ifdef __cplusplus
}
#endif
```

## Document Null Statements

Always document a null body for a `for` or `while` statement so that it is clear that the null body is intentional and not missing code.
```c
   while (*dest++ = *src++)
   {
         ;
   }
```

## Error Return Check Policy

Check every system call for an error return, unless you know you wish to ignore errors. For example, printf returns an error code but rarely would you check for its return code. In which case you can cast the return to (void) if you really care.

Include the system error text for every system error message.

Check every call to malloc or realloc unless you know your versions of these calls do the right thing. You might want to have your own wrapper for these calls, including new, so you can do the right thing always and developers don't have to make memory checks everywhere.

# Commenting

Good to have, but must be done correctly.

Bad comments:

- Explain how code works
- Over-commenting
- Say who wrote the function
- Have last modified date
- Have other trivial things

Good comments:

- Explain what
- Explain why
- Avoid putting comments inside a function body unless small comments

## Comment Style

Use either the `//` or `/* */` syntax, as long as you are consistent.

You can use either the `//` or the `/* */` syntax; however, be consistent with how you comment and what style you use where. 

And please:
- Put a space next to `//`.
- Put a space next to `/*` and a space before `*/`.

## Commenting to Closing Braces

If you do need a long statement, add comments to closing braces is good.

```c
while (condition) {
    if (valid){
		/* Do something ... */
	/* if valid */
    } else {
		// Do something ...
	} /* not valid */
} /* end condition */
```

## Commenting Out Large Code Blocks

1. Using `#if 0`

```c
void example()
{
	great looking code

	#if 0
	// lots of code
	#endif
	// more code
}
```

2. Use Descriptive Macro Names Instead of `#if 0`

```c
#if NOT_YET_IMPLEMENTED

#if OBSOLETE

#if TEMP_DISABLED
// Add a short comment explaining why it is not implemented, obsolete or temporarily disabled.
```

## Include Statement Documentation

Include statements should be documented, telling the user why a particular file was included.

```c
/*
* Kernel include files come first.
*/

/* Non-local includes in brackets. */

/*
* If it's a network program, put the network include files next.
* Group the includes files by subdirectory.
*/

/*
* Then there's a blank line, followed by the /usr include files.
* The /usr include files should be sorted!
*/

```

# Documentation

Comments Should Tell a Story, use a document extraction system like [Doxgen](https://www.doxygen.nl/).

## Gotcha Keywords

- `@author`:
specifies the author of the module.

- `@version`:
specifies the version of the module.

- `@file`:
Denote this comment related to the file.

- `@brief`:
Explain the module in brief.

- `@param`:
specifies a parameter into a function.

- `@return`:
specifies what a function returns.

- `@deprecated`:
says that a function is not to be used anymore.

- `@see`:
creates a link in the documentation to the file/function/variable to consult to get a better understanding on what the current block of code does.

- `@todo`:
what remains to be done

- `@bug`:
report a bug found in the piece of code

## File Header
`@version` is an optional item, which we usually don't add it unless we are coding an API file.
```c
/**
 * @file
 * @brief
 * @author Name <email>
 * @version 0.1    Name
 *          0.2    Name    description
 *          0.3    Name    description
 * @date
 *
 * @copyright Copyright (c) Andy Lee, "%Y"
 *
 */
```

## Function Header

Function header should be in the file where they are declared, which means that most likely the functions will have a header in the .h file. However, functions with no explicit prototype declaration in the .h file, should have a function header in the c file.

In common, it should be in the header file if header file exists, sometimes only in c file, such as main function.
```c
/**
 * @brief
 *
 * @param argc
 * @param argv[]
 * @return 0
 *         -1
 */
int main(int argc, char *argv[]) {
    if (0 == argc)
        return -1;
    return 0;
}
```

## Formatting

Once the count of snippets is equaling or more than 3, for better readability more than 4 spaces are suggested from the 3rd snippet. Such as the following comment.

```c
/**
 * @version 0.1    Name
 *          0.2    Name    description
 *          0.3    Name    description
 * @return  0     means nothing
 *          -1    means something
 */
```

## How Do They Look Like?

```c
/**
 * @file api.h
 * @brief example for file header
 * @author Li Hua Qian <huaqianlee@gmail.com>
 * @version 0.1    Li, Huaqian
 *          0.2    Andy, Lee    example for version 0.2
 *          0.3    Andy, Lee    example for version 0.3
 * @date 2023-04-04
 *
 * @copyright Copyright (c) Andy Lee, 2023
 *
 */
#include <stdlib.h>
#include <string.h>

/**
 * @brief example for function header
 *
 * @param argc
 * @param argv[]
 * @return 0     means nothing
 *         -1    means something
 */
int main(int argc, char *argv[]) {
    if (0 == argc)
        return -1;
    return 0;
}
```

## Tips and Tricks

### VS Code

1. Install `Doxygen Documentation Generator` extension.
2. Go to `Doxygen Comment` setting.
3. Click `Edit in settings.json` of `'Doxdocgen>File:CopyrightTag'`, and fill in the following similar content.
```json
{
    "doxdocgen.file.fileOrder": [
        "file",
        "author",
        "brief",
        "empty",
        "copyright",
        "empty",
        "custom"
      ],
    "doxdocgen.file.copyrightTag": [
        "@copyright Copyright (c) Andy Lee, {year}"
    ],
    "doxdocgen.generic.authorTag": "@author {author} <{email}>",
    "doxdocgen.generic.authorEmail": "huaqianlee@gmail.com",
    "doxdocgen.generic.authorName": "Li Hua Qian"
}
```
> Open the settings.json file by `<Ctrl-P> ~/.config/Code/User/settings.json` directly can also archive the target of step 2 and 3.
4. More please refer to the extension 'README'.
> Sometimes some unexpected white spaces will be added by this extension, `<Ctrl-Shift-P> Trim Trailing Whitespace` or ` Ctrl-K Ctrl-X` can remove them easily.

### Vim

1. Add `'huaqianlee/DoxygenToolkit.vim'` into `.vimrc` to install the extension.
2. Add the following basic configuration into `.vimrc`.
```vimscript
let g:DoxygenToolkit_authorName="Li Hua Qian <huaqianlee@gmail.com>"
let g:DoxygenToolkit_yearString = strftime("%Y")
let g:DoxygenToolkit_copyrightString = "Copyright (c) Andy Lee, ".g:DoxygenToolkit_yearString
# let g:DoxygenToolkit_versionString = "0.1"
let g:DoxygenToolkit_compactDoc = "yes"
```
3. `:DoxAuthor` to add file header, `:Dox` to add function header, more please refer to [huaqianlee/DoxygenToolkit.vim](https://github.com/huaqianlee/DoxygenToolkit.vim).

# Reference

- [Linux kernel coding style.](https://www.kernel.org/doc/html/v6.1/process/coding-style.html)
- [Recommended C style and coding rules.](https://github.com/MaJerle/c-code-style)
- [Recommended C Style and Coding Standards.](https://www.doc.ic.ac.uk/lab/cplus/cstyle.html)
- [NetBSD C Coding Standard.](https://users.ece.cmu.edu/~eno/coding/CCodingStandard.html)
- [C Coding Conventions.](https://wikileaks.org/ciav7p1/cms/page_26607644.html)


