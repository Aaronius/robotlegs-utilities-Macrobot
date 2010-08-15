/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot.core
{
	import flash.events.Event;
	
	import org.robotlegs.utilities.macrobot.AsyncCommand;
	
	/**
	 * Base functionality for <code>ParallelCommand</code> and <code>SequenceCommand</code>.  This 
	 * provides the main API for adding and executing commands.
	 */
	public class MacroBase extends AsyncCommand
	{
		/**
		 * Whether the macro command should execute subsequent commands when a command fails.
		 * If <code>atomic</code> is true, the macro command will continue executing commands.
		 */
		public var atomic:Boolean = true;
		
		/**
		 * Whether all commands have completed successfully.
		 */
		protected var success:Boolean = true;
		
		/**
		 * A collection of command or <code>CommandDescriptor</code> instances.
		 */
		protected var commands:Array;
		
		/**
		 * Add a command to the macro using metadata that will be used to instantiate, inject
		 * into, and execute the command at the appropriate time.
		 * 
		 * @param commandClass The command class to instantiate - must have an execute() method
		 * @param payload An optional payload
		 * @param payloadClass  An optional class to inject the payload as
		 * @param named An optional name for the payload injection
		 */
		public function addCommand(commandClass:Class, payload:Object=null, payloadClass:Class=null, 
				named:String=''):void
		{
			commands ||= [];
			commands.push(new CommandDescriptor(commandClass, payload, payloadClass, named));
		}
		
		/**
		 * Add a command instance to the macro.  Injections will occur before execution.
		 * 
		 * @param command The command instance to add to the macro - must have an execute() method.
		 */
		public function addCommandInstance(command:Object):void
		{
			commands ||= [];
			commands.push(command);
		}
		
		/**
		 * Executes a command.
		 * 
		 * @param command A command or <code>CommandDescriptor</code> instance.
		 */
		protected function executeCommand(command:Object):void
		{
			if (command is CommandDescriptor)
			{
				var descriptor:CommandDescriptor = CommandDescriptor(command);
				
				// Perform injections.
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
		
		/**
		 * Handles completion of a command.
		 */
		protected function commandCompleteHandler(success:Boolean):void
		{
			// Override.
		}
	}
}

/**
 * Holds "meta" information regarding a command so when it becomes time to execute, the command can 
 * be instantiated, injected into, and then be executed.
 */
class CommandDescriptor
{
	public function CommandDescriptor(commandClass:Class, payload:Object=null, 
			payloadClass:Class=null, named:String='')
	{
		this.commandClass = commandClass;
		this.payload = payload;
		this.payloadClass = payloadClass;
		this.named = named;
	}
	
	public var commandClass:Class;
	public var payload:Object;
	public var payloadClass:Class;
	public var named:String;
}