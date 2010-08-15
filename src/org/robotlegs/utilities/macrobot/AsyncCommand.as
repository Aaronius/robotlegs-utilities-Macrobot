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

	public class AsyncCommand extends Command implements IAsyncCommand
	{
		protected var listeners:Array;
		protected var complete:Boolean = false;
		
		public function addCompletionListener(listener:Function):void
		{
			listeners ||= [];
			listeners.push(listener);
		}
		
		override public function execute():void
		{
			super.execute();
			if (!complete)
			{
				commandMap.detain(this);
			}
		}
		
		protected function dispatchComplete(success:Boolean):void
		{
			complete = true;
			commandMap.release(this);
			for each (var listener:Function in listeners)
			{
				listener(success);
			}
			listeners = null;
		}
	}
}