/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot
{
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.macrobot.core.IAsyncCommand;

	/**
	 * Provides functionality for holding an asynchronous command in memory and dispatching
	 * when the command is complete.
	 */
	public class AsyncCommand extends Command implements IAsyncCommand
	{
		/**
		 * Registered listeners.
		 */
		protected var listeners:Array;
		
		/**
		 * Whether the command has finished executing.
		 */
		protected var complete:Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		public function addCompletionListener(listener:Function):void
		{
			listeners ||= [];
			listeners.push(listener);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void
		{
			complete = false; // undo/redo compatibility
			super.execute();
			
			// Maintain a reference to this command while it executes so it doesn't get
			// garbage collected.
			if (!complete)
			{
				commandMap.detain(this);
			}
		}
		
		/**
		 * Notifies any registered listeners of the completion of this command along with
		 * whether or not it was successful.
		 */ 
		protected function dispatchComplete(success:Boolean):void
		{
			complete = true;
			commandMap.release(this);
			for each (var listener:Function in listeners)
			{
				listener(success);
			}
		}
	}
}