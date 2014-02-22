---
project: winapi
tagline: developer documentation
---

## How to use the binding infrastructure

Wrap winapi calls in `callnz`, `callh` and friends according to what constitutes
an error in the result: you get automatic error handling and clear code.

Use `own(object, finalizer)` on all newly created objects but call
`disown(object)` right after any successful api call that assigns that object
an owner responsible for freeing it, and use `own()` again every time a call
leaves an object without an owner. Doing this consistently will complicate
the implementation sometimes but it prevents leaks and you get automatic object
lifetime management (for what is worth, given the non-deterministic nature of the gc).

Avoid surfacing ABI boilerplate like buffers, buffer sizes and internal data
structures. Sometimes you may want to reuse a buffer to avoid heap trashing especially on
a function you know it could be called repeatedly many times. In this case add
the buffer as an optional trailing argument - if given it will be used, if not
an internal buffer will be created. If there's a need to pass state around
beyond this, make a class (that is, do it in the object layer).

Use `wcs(arg)` on all string args: if arg is a lua string, it's assumed to be
an utf8 encoded string and it's converted to wcs, otherwise it's assumed a wcs
and passed through as is. This makes the api accept both lua strings and wcs
strings coming from winapi transparently.

Use `flags(arg)` on all flag args so that you can pass a string of the form
`'FLAG1 | FLAG2 | ...'` as an alternative to `bit.bor(FLAG1, FLAG2, ...)`. It
also changes nil into 0 to allow for optional flag args to be passed where winapi
expects an int.

Count from 1! Use `countfrom0` on all positional args: this will decrement
the arg but only if it's strictly > 0 so that negative numbers are passed through
as they are since we want to preserve values with special meaning like -1.

### Struct constructors

Create struct definitions with `struct()` and later apply the struct constructor
to all struct args. This allows you to pass in a table where a struct cdata is
expected in which case a cdata will be created and its fields initialized with the
values from the table. As with `wcs`, other types are passed through as they are
so you can pass in a previously created cdata.

There are other advantages to using struct constructors:

  * a size field will be set to sizeof(cdata) upon creation if specified in the struct definition.
  * fields will be initialized with default values according to the struct definition.

The struct constructor also sets a metatable on the ctype (using ffi.metatype) which adds
virtual fields to all cdata of that ctype per your struct definition. The virtual fields will
be available alongside the cdata fields for indexing and setting. Working with a struct through
the virtual fields instead of the typedef'ed fields allows for some magic:

  * the struct's mask field, if any, will be set based on which fields are set, provided the bitmasks
    are specified in the struct's definition.
  * a cast function will be applied to the field value if specified in the struct's definition
    (eg. wcs, countfrom0, another struct constructor, etc).
  * individual bits of bitmask fields can be read and set provided you define the data field and the mask
    field (and the prefix for the mask constants) in the struct definition.

All in all this is a real time saver and results in self-documenting code.

Btw, use the lowercase-with-underscores naming convention for virtual field names.
Use names like caption, x, y, w, h, pos, parent, etc. consistently throughout.

## How to use the OO system

The easiest way to bind a new control is to use the code of an existing control as a template.
Basically, you subclass from `Control` (or a specific control, if your control is a refinement
of a standard control) after you define the style bitmasks, default values, and event name mappings, if any.
You override the constructor and/or any methods and define any new properties by way of getters and setters.
