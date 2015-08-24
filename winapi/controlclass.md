---
tagline: controls
---

## `require'winapi.controlclass'`

This module implements the `Control` class which is the base class for controls.
`Control` inherits from `BaseWindow` from [winapi.basewindowclass] module.

The `Control` class is for subclassing, not for instantiation. Nevertheless,
it contains properties that are common to all controls which are documented here.


## API

The tables below list all initial fields and properties specific to the `Control` class.
Everything listed for `BaseWindow` in [winapi.basewindowclass] is available too.


### Initial fields and properties

<div class=small>

__NOTE:__ the table below `i` means initial field, `r` means read-only property,
`rw` means read-write property.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
anchors.left				irw		left anchor											true
anchors.top					irw		top anchor											true
anchors.right				irw		right anchor										false
anchors.bottom				irw		bottom anchor										false
parent						irw		control's parent														Get/SetParent
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>
