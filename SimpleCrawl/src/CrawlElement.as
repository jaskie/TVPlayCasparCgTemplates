package  
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.GridFitType;
	
	public class CrawlElement extends Sprite 
	{
		//the text field
		private var _tf:TextField;
		
		public function CrawlElement(text:String, format:TextFormat, filters:Array) :void
		{			
			//create text field
			_tf = new TextField(); 
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.embedFonts = true;
			_tf.multiline = false;
			_tf.gridFitType = GridFitType.NONE;
			
			_tf.filters =  filters;
			
			//set the format for the font
			_tf.defaultTextFormat = format;
			_tf.text = text;

			//add to the display list
			this.addChild(_tf);
		}
		
		//called from the template host when removed
		public function dispose():void 
		{
			this.removeChild(_tf);
			_tf = null;
		}
		
		//sets the font size of the text field		
		public function set fontSize(value:Number):void 
		{
			var format:TextFormat = _tf.getTextFormat();
			format.size = value;
			_tf.defaultTextFormat = format;
		}
		
		//sets the color of the text field
		public function set color(value:uint):void 
		{
			var format:TextFormat = _tf.getTextFormat();
			format.color = value;
			_tf.defaultTextFormat = format;
		}
		
		public function set text(value:String):void
		{
			_tf.text = value;
		}
		
	}

}