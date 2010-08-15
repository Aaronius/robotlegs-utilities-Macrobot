/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot.core
{
	import flash.events.Event;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.macrobot.AsyncCommand;

	public class MacroBase extends AsyncCommand
	{
		public var atomic:Boolean = false;
		protected var success:Boolean = true;
		protected var commands:Array;
		
		public function addCommand(commandClass:Class, payload:Object=null, payloadClass:Class=null, 
				named:String=''):void
		{
			commands ||= [];
			commands.push(new ExecutionDescriptor(commandClass, payload, payloadClass, named));
		}
		
		public function addCommandInstance(command:Object):void
		{
			commands ||= [];
			commands.push(command);
		}
		
		protected function executeCommand(command:Object):void
		{
			if (command is ExecutionDescriptor)
			{
				var descriptor:ExecutionDescriptor = ExecutionDescriptor(command);
				
				// TODO: See if we can get commandMap.execute() to return the command instance so
				// we can use it instead of this nastiness:
				if (descriptor.payload)
				{
					var payloadClass:Class = descriptor.payloadClass || Event;
					injector.mapValue(payloadClass, descriptor.payload, descriptor.named);
					command = injector.instantiate(descriptor.commandClass);
					injector.unmap(payloadClass, descriptor.named);
				}
				else
				{
					command = injector.instantiate(descriptor.commandClass);
				}
			}
			else
			{
				injector.injectInto(command);
			}
			
			var isAsync:Boolean;
			if (command is IAsyncCommand)
			{
				IAsyncCommand(command).addCompletionListener(commandCompleteHandler);
				isAsync = true;
			}
			
			command.execute();
			
			if (!isAsync)
			{
				commandCompleteHandler(true);
			}
		}
		
		protected function commandCompleteHandler(success:Boolean):void
		{
			// Override.
		}
	}
}

class ExecutionDescriptor
{
	public function ExecutionDescriptor(commandClass:Class, payload:Object=null, 
										payloadClass:Class=null, named:String='')
	{
		_commandClass = commandClass;
		_payload = payload;
		_payloadClass = payloadClass;
		_named = named;
	}
	
	protected var _commandClass:Class;
	
	public function get commandClass():Class
	{
		return _commandClass;
	}
	
	protected var _payload:Object;
	
	public function get payload():Object
	{
		return _payload;
	}
	
	protected var _payloadClass:Class;
	
	public function get payloadClass():Class
	{
		return _payloadClass;
	}
	
	protected var _named:String;
	
	public function get named():String
	{
		return _named;
	}
}