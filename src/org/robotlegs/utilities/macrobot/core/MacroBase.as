/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot.core
{
	import flash.events.Event;
	
	import org.robotlegs.core.IReflector;
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.utilities.macrobot.AsyncCommand;
	import org.swiftsuspenders.Reflector;
	
	/**
	 * Base functionality for <code>ParallelCommand</code> and <code>SequenceCommand</code>.  This 
	 * provides the main API for adding and executing commands.
	 */
	public class MacroBase extends AsyncCommand
	{
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
		 * @inheritDoc
		 */
		override public function execute():void
		{
			super.execute();
			success = true; // undo/redo compatibility
		}
		
		/**
		 * Executes a command.
		 * 
		 * @param commandOrDescriptor A command or <code>CommandDescriptor</code> instance.
		 */
		protected function executeCommand(commandOrDescriptor:Object):void
		{
			var command:Object = prepareCommand(commandOrDescriptor);
			var isAsync:Boolean = command is IAsyncCommand;
			
			if (isAsync)
			{
				IAsyncCommand(command).addCompletionListener(commandCompleteHandler);
			}
			
			// If the command map is IMacroCommandMap, use it.  This is allows us to maintain
			// a single point of execution within the application.  This can be very useful when
			// it comes to debugging or having a custom command map with logging support, etc.
			if (commandMap is IMacroCommandMap)
			{
				IMacroCommandMap(commandMap).executePrepared(command);
			}
			else
			{
				command.execute();
			}
			
			if (!isAsync)
			{
				commandCompleteHandler(true);
			}
		}
		
		/**
		 * Prepares a command by instantiation if necessary and fulfilling injections.
		 * 
		 * @param commandOrDescriptor An instantiated command object or a command descriptor.
		 * 
		 * @return A command instance with fulfilled injections.
		 */
		protected function prepareCommand(commandOrDescriptor:Object):Object
		{
			if (commandOrDescriptor is CommandDescriptor)
			{
				return prepareCommandFromDescriptor(CommandDescriptor(commandOrDescriptor));
			}
			else
			{
				injector.injectInto(commandOrDescriptor);
				return commandOrDescriptor;
			}
		}
		
		/**
		 * Instantiates and injects a command based on a command descriptor.
		 * 
		 * @param descriptor A command descriptor.
		 * 
		 * @return A command instance with fulfilled injections.
		 */
		protected function prepareCommandFromDescriptor(descriptor:CommandDescriptor):Object
		{
			var command:Object;
			
			// If we have an IMacroCommandMap, use it to prepare the command object.
			if (commandMap is IMacroCommandMap)
			{
				command = IMacroCommandMap(commandMap).prepare(descriptor.commandClass, 
					descriptor.payload, descriptor.payloadClass, descriptor.named);
			}
			// Otherwise, we'll do our best to prepare it ourselves.
			else
			{
				// Perform injections.
				// Note: if RL's CommandMap ever implements an interface like IMacroCommandMap 
				// we could use it instead and wouldn't need IMacroCommandMap or the code
				// below at all.
				if (descriptor.payload != null)
				{
					var payloadClass:Class;
					if (descriptor.payloadClass)
					{
						payloadClass = descriptor.payloadClass;
					}
					else
					{
						var reflector:IReflector = injector.getInstance(IReflector);
						
						if (reflector)
						{
							payloadClass = reflector.getClass(descriptor.payload);
						}
						else
						{
							payloadClass = Event;
						}
					}
					injector.mapValue(payloadClass, descriptor.payload, descriptor.named);
					command = injector.instantiate(descriptor.commandClass);
					injector.unmap(payloadClass, descriptor.named);
				}
				else
				{
					command = injector.instantiate(descriptor.commandClass);
				}
			}
			
			return command;
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
 * be instantiated, injected into, and then executed.
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