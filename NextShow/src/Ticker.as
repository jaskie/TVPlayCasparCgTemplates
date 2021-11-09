package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.GridFitType;
	import flash.display.BlendMode;
	import com.greensock.easing.Sine;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;

	
	public class Ticker extends Sprite 
	{
		public static const FINISHED:String = "Finished";

		private const textDissolveTime:Number = 0.2;
		private const animationTime:Number = 1.0;
		private const textMargin:Number = 10;

		private var background:Sprite = new Sprite();
		private var textLayer:Sprite = new Sprite();
		private var whiteRect:Shape = new Shape();
		private var darkBlueRect:Shape = new Shape();
		private var lightBlueRect:Shape = new Shape();
		private var fullWidth:Number;

		
		public function Ticker(header:String, title:String) 
		{
			var headerField:TextField = AddTextField(header, 25, false);
			headerField.x = textMargin;
			textLayer.addChild(headerField);
			var titleField:TextField = AddTextField(title, 35, true);
			titleField.x = textMargin;
			titleField.y = headerField.height;
			textLayer.addChild(titleField);
			textLayer.alpha = 0;
			fullWidth = textLayer.width + 4 * textMargin;

			lightBlueRect.graphics.beginFill(0x1010F0);
			lightBlueRect.graphics.drawRect(0, 0, fullWidth, textLayer.height);
			lightBlueRect.graphics.endFill();
			lightBlueRect.width = 0;
						
			whiteRect.graphics.beginFill(0xF0F0F0);
			whiteRect.graphics.drawRect(0, 0, fullWidth, textLayer.height);
			whiteRect.graphics.endFill();
			whiteRect.width = 0;
			
			background.addChild(lightBlueRect);
			background.addChild(whiteRect);
			background.addChild(textLayer);
			
			addChild(background);
			super();
		}
		
		public function Show():void
		{
			TweenLite.to(lightBlueRect, animationTime* 0.7, { width: fullWidth, ease:Linear.easeIn } );
			TweenLite.to(this, animationTime * 0.1, {onComplete: function():void {
				TweenLite.to(whiteRect, animationTime * 0.9, { width: fullWidth, ease:Linear.easeIn, onComplete: function():void
				{
					TweenLite.to(textLayer, textDissolveTime, { alpha: 1.0, onComplete: IntroCompleted });			
				} 			
				});
			}});
		}
		
		public function Hide():void
		{
				TweenLite.to(textLayer, textDissolveTime, {
					alpha: 0.0, 
					ease:Sine.easeOut, 
					onComplete: function():void {
						dispatchEvent(new Event(FINISHED));
					}
				});			
		}

		private function IntroCompleted():void
		{
			TweenLite.to(this, 2.0, { onComplete: Hide });
		}

		
		private function AddTextField(text:String, size:int, bold:Boolean, filters:Array = null) :TextField
		{
			var tf:TextField = new TextField(); 
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.autoSize = TextFieldAutoSize.RIGHT;
			tf.embedFonts = true;
			tf.multiline = false;
			
			tf.gridFitType = GridFitType.NONE;
			
			tf.filters =  filters;
			
			tf.defaultTextFormat = new TextFormat("Lato", size, 0x1A589B, bold);
			tf.text = text;
			return tf;
		}

	}

}