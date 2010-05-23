/*
 *  NSThread+GNUStep.h
 *  Cioccolata
 *
 *  Created by Chris Corbyn on 23/04/10.
 *  Copyright 2010 Chris Corbyn. All rights reserved.
 *
 */

/*!
 * Cross-platform compatibility macros for NSThread.
 */

#ifdef GNUSTEP

/*!
 * Macro which invokes the GSRegisterThread() function which is required to be invoked on all new threads under GNUStep.
 */
#define CTRegisterCurrentThread() GSRegisterCurrentThread()

#else

/*!
 * NOOP under Cocoa OS X, can safely be called for cross-compatibility with GNUStep, where it invokes GSRegisterCurrentThread().
 */
#define CTRegisterCurrentThread()

#endif
