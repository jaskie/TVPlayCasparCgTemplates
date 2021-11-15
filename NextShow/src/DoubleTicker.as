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

	
	public class DoubleTicker extends Sprite 
	{
		public static const FINISHED:String = "Finished";

		private const textDissolveTime:Number = 0.2;
		private const animationTime:Number = 1.2;
		private const displayTime:Number = 3.0;
		private const textMargin:Number = 10;
		private const headerFontSize:int = 14;
		private const titleFontSize:int = 18;

		private var text1Layer:Sprite = new Sprite();
		private var text2Layer:Sprite = new Sprite();
		private var whiteRect:Shape = new Shape();
		private var darkBlueRect:Shape = new Shape();
		private var lightBlueRect:Shape = new Shape();
		private var fullWidth:Number;

		
		public function DoubleTicker(header1:String, title1:String, header2:String, title2:String ) 
		{
			var header1Field:TextField = AddTextField(header1, headerFontSize, true);
			header1Field.scaleX = 0.8;
			header1Field.x = textMargin + 1.5;
			text1Layer.addChild(header1Field);
			var title1Field:TextField = AddTextField(title1, titleFontSize, true);
			title1Field.x = textMargin;
			title1Field.y = header1Field.height - 8;
			text1Layer.addChild(title1Field);
			text1Layer.alpha = 0;

			var header2Field:TextField = AddTextField(header2, headerFontSize, true);
			header2Field.x = textMargin + 1.5;
			header2Field.scaleX = 0.8;
			text2Layer.addChild(header2Field);
			var title2Field:TextField = AddTextField(title2, titleFontSize, true);
			title2Field.x = textMargin;
			title2Field.y = header2Field.height - 8;
			text2Layer.addChild(title2Field);
			text2Layer.alpha = 0;
			
			fullWidth = Math.max(text1Layer.width, text2Layer.width) + 4 * textMargin;

			lightBlueRect.graphics.beginFill(0x2272e1);
			lightBlueRect.graphics.drawRect(0, 0, fullWidth, text1Layer.height);
			lightBlueRect.graphics.endFill();
			lightBlueRect.width = 0;

			darkBlueRect.graphics.beginFill(0x1b579d);
			darkBlueRect.graphics.drawRect(0, 0, fullWidth, text1Layer.height);
			darkBlueRect.graphics.endFill();
			darkBlueRect.width = 0;
						
			whiteRect.graphics.beginFill(0xF0F0F0);
			whiteRect.graphics.drawRect(0, 0, fullWidth, text1Layer.height);
			whiteRect.graphics.endFill();
			whiteRect.width = 0;

			addChild(lightBlueRect);
			addChild(darkBlueRect);
			addChild(whiteRect);
			addChild(text1Layer);
			addChild(text2Layer);
			super();
		}
		
		public function Show():void
		{
			TweenLite.to(lightBlueRect, animationTime * 0.5, { width: fullWidth, ease:Sine.easeIn } );
			
			TweenLite.to(new Object(), animationTime * 0.05, { onComplete: function():void // delay
			{
				TweenLite.to(darkBlueRect, animationTime * 0.55, { width: fullWidth, ease:Sine.easeIn } );
			}});
			
			TweenLite.to(new Object(), animationTime * 0.05, { onComplete: function():void { // delay
				TweenLite.to(whiteRect, animationTime * 0.7, { width: fullWidth, ease:Sine.easeIn, onComplete: ShowFirst});
			}});
		}
		
		public function Hide():void
		{
			TweenLite.to(text1Layer, textDissolveTime, {
				alpha: 0.0, 
				ease:Sine.easeOut, 
				onComplete: Finish
			});			
			TweenLite.to(text2Layer, textDissolveTime, {
				alpha: 0.0, 
				ease:Sine.easeOut, 
				onComplete: Finish
			});			
		}
		
		private function Finish():void
		{
			TweenLite.to(whiteRect, animationTime * 0.7, { width: 0.0, x: whiteRect.width, ease:Linear.easeOut, onComplete: function():void 
			{
				dispatchEvent(new Event(FINISHED));
			}});
		}

		private function ShowFirst():void
		{
			removeChild(lightBlueRect);
			removeChild(darkBlueRect);
			TweenLite.to(text1Layer, textDissolveTime, { alpha: 1.0, onComplete: function():void
			{
				TweenLite.to(new Object(), displayTime, { onComplete: function():void
				{
					TweenLite.to(text1Layer, textDissolveTime, {
						alpha: 0.0, 
						ease:Sine.easeOut,
						onComplete: function():void
						{
							TweenLite.to(new Object(), textDissolveTime * 2, { onComplete: ShowSecond }); // pause between texts
						}
					});
				
				}});
			}});
		}
		
		private function ShowSecond():void
		{
			TweenLite.to(text2Layer, textDissolveTime, {
				alpha: 1.0, 
				ease:Sine.easeIn, 
				onComplete: function():void 
				{
					TweenLite.to(new Object(), displayTime, { onComplete: function():void
					{
						TweenLite.to(text2Layer, textDissolveTime, {
							alpha: 0.0, 
							ease:Sine.easeOut, 
							onComplete: Finish
						});			
					}});
				}});
		}

		
		private function AddTextField(text:String, size:int, bold:Boolean, filters:Array = null) :TextField
		{
			var tf:TextField = new TextField(); 
			tf.antiAliasType = AntiAliasType.NORMAL;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.embedFonts = true;
			tf.multiline = false;
			
			tf.gridFitType = GridFitType.PIXEL;
			
			tf.filters =  filters;
			
			tf.defaultTextFormat = new TextFormat("TVP", size, 0x1A589B, bold);
			tf.text = text;
			return tf;
		}

	}

}