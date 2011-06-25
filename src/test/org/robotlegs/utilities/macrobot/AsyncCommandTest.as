package test.org.robotlegs.utilities.macrobot
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flexunit.framework.Assert;
	
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.adapters.SwiftSuspendersReflector;
	import org.robotlegs.base.CommandMap;
	import org.robotlegs.base.MediatorMap;
	import org.robotlegs.core.ICommandMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.core.IReflector;
	
	import test.org.robotlegs.utilities.macrobot.support.CompletionDirective;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandConfigEvent;
	import test.org.robotlegs.utilities.macrobot.support.TestAsyncCommand;
	import test.org.robotlegs.utilities.macrobot.support.TestCommandMap;
	
	public class AsyncCommandTest
	{		
		protected var command:TestAsyncCommand;
		
		protected var commandComplete:Boolean;
		protected var commandSuccess:Boolean;
		
		protected var injector:IInjector;
		protected var commandMap:TestCommandMap;
		
		[Before]
		public function setUp():void
		{
			var contextView:Sprite = new Sprite();
			var reflector:IReflector = new SwiftSuspendersReflector();
			var eventDispatcher:IEventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			injector.mapValue(IInjector, injector);
			injector.mapValue(IReflector, reflector);
			injector.mapValue(DisplayObjectContainer, contextView);
			commandMap = new TestCommandMap(eventDispatcher, injector, reflector);
			injector.mapValue(ICommandMap, commandMap);
			injector.mapValue(IEventDispatcher, eventDispatcher);
			injector.mapValue(IMediatorMap, new MediatorMap(contextView, injector, reflector));
		}
		
		[After]
		public function tearDown():void
		{
			injector = null;
			commandMap = null;
			commandComplete = false;
			commandSuccess = false;
		}
		
		[Test]
		public function testExecutionSuccess():void
		{
			command = new TestAsyncCommand(new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, 0, 0, CompletionDirective.SUCCESS));
			injector.injectInto(command);
			command.addCompletionListener(completeHandler);
			command.execute();
			Assert.assertTrue("Command should have dispatched complete.", commandComplete);
			Assert.assertTrue("Command should have dispatched completion success.", commandSuccess);
		}
		
		[Test]
		public function testExecutionFailure():void
		{
			command = new TestAsyncCommand(new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, 0, 0, CompletionDirective.FAILURE));
			injector.injectInto(command);
			command.addCompletionListener(completeHandler);
			command.execute();
			Assert.assertTrue("Command should have dispatched complete.", commandComplete);
			Assert.assertFalse("Command should have dispatched completion failure.", commandSuccess);
		}
		
		[Test]
		public function testCommandDetained():void
		{
			command = new TestAsyncCommand(new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, 0, 0, CompletionDirective.PREVENT_COMPLETION));
			injector.injectInto(command);
			command.execute();
			Assert.assertTrue("Command should have been detained.", commandMap.isCommandDetained);
			commandMap.release(command);
		}
		
		[Test]
		public function testCommandReleased():void
		{
			command = new TestAsyncCommand(new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, 0, 0, CompletionDirective.SUCCESS));
			injector.injectInto(command);
			command.addCompletionListener(completeHandler);
			command.execute();
			Assert.assertFalse("Command should have been released.", commandMap.isCommandDetained);
		}
		
		protected function completeHandler(success:Boolean):void
		{
			commandComplete = true;
			commandSuccess = success;
		}
	}
}