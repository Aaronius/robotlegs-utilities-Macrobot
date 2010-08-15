/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot.core
{
	public interface IAsyncCommand
	{
		/**
		 * Registers a function to be executed when this command completes.  The function must
		 * accept a single boolean parameter which will indicate whether this command completed 
		 * successfully.
		 */
		function addCompletionListener(listener:Function):void;
	}
}