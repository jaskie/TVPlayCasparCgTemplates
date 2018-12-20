package  
{
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.globalization.DateTimeFormatter;

	/**
	 * ...
	 * @author Jerzy Jaśkiewicz
	 */
	public class Clock extends Sprite
	{
		//the text field
		private var _tf:TextField;
		private var _formatter:DateTimeFormatter;
		
		public function Clock(timeFormat:String, fontFormat:TextFormat, filters:Array, stretch:Number) 
		{
			_tf = new TextField(); 
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.embedFonts = true;
			_tf.scaleX = stretch;
			
			_tf.filters =  filters;
			
			//set the format for the font
			_tf.defaultTextFormat = fontFormat;
			_formatter = new DateTimeFormatter("pl-PL");
			_formatter.setDateTimePattern(timeFormat);
			
			//add to the display list
			this.addChild(_tf);
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				e.currentTarget.removeEventListener(e.type, arguments.callee);
				addEventListener(Event.ENTER_FRAME, Update); // run on every frame
				addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
					e.currentTarget.removeEventListener(e.type, arguments.callee);
					removeChild(_tf);
					removeEventListener(Event.ENTER_FRAME, Update); 
					_tf = null;
					trace("clock cleared");
				});
			});
		}
		
		public function Update(e:Event):void
		{
			var currentTime:Date = new Date();
			_tf.text = _formatter.format(currentTime);
			_tf.x = - _tf.width / 2;
		}
	}

}