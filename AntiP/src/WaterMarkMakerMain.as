package 
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import jp.mztm.umhr.create.Ichimatsu;
	/**
	 * ...
	 * @author umhr
	 */
	public class WaterMarkMakerMain extends Sprite 
	{
		
		[Embed(source = 'watermark_w.png')]
		private static const watermark_w:Class;
		[Embed(source = 'watermark_b.png')]
		private static const watermark_b:Class;
		
		private var _waterMarkWBitmap:Bitmap;
		private var _waterMarkBBitmap:Bitmap;
		private var _watermarkBitmap:Bitmap;
		public function WaterMarkMakerMain() 
		{
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			//addChild(new Ichimatsu(stage.stageWidth, stage.stageHeight));
			
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 320, 320);
			graphics.endFill();
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 160, 320, 160);
			graphics.endFill();
			
			_waterMarkWBitmap = new watermark_w();
			//addChild(_waterMarkWBitmap);
			_waterMarkBBitmap = new watermark_b();
			//addChild(_waterMarkBBitmap);
			
			_watermarkBitmap = new Bitmap(new BitmapData(_waterMarkWBitmap.width, _waterMarkWBitmap.height, true, 0));
			addChild(_watermarkBitmap);
			
					var bList:Array = [0, 0, 0];
					var wList:Array = [0, 0, 0];
			var n:int = _waterMarkWBitmap.height;
			for (var ty:int = 0; ty < n; ty++) 
			{
				var m:int = _waterMarkWBitmap.width;
				for (var tx:int = 0; tx < m; tx++) 
				{
					var rgb:int;
					var argb:int;
					var b:int;
					
					rgb = _waterMarkWBitmap.bitmapData.getPixel(tx, ty);
					b = rgb & 0xFF;
					if (b < (0xFF-16)) {
						b = 0xFF - (rgb & 0xFF);
						argb = (b << 24) | 0x000000;
						_watermarkBitmap.bitmapData.setPixel32(tx, ty, argb);
						wList[0] ++;
					}else{
						rgb = _waterMarkBBitmap.bitmapData.getPixel(tx, ty);
						b = rgb & 0xFF;
						if (b > 16) {
							argb = (b << 24) | 0xFFFFFF;
							_watermarkBitmap.bitmapData.setPixel32(tx, ty, argb);
							bList[0] ++;
						}else {
							rgb = _waterMarkWBitmap.bitmapData.getPixel(tx, ty);
							b = rgb & 0xFF;
							if (b < (0xFF-8)) {
								b = 0xFF - (rgb & 0xFF);
								argb = (b << 24) | 0x000000;
								_watermarkBitmap.bitmapData.setPixel32(tx, ty, argb);
								wList[1] ++;
							}else {
								rgb = _waterMarkBBitmap.bitmapData.getPixel(tx, ty);
								b = rgb & 0xFF;
								if (b > 8) {
									argb = (b << 24) | 0xFFFFFF;
									_watermarkBitmap.bitmapData.setPixel32(tx, ty, argb);
									bList[1] ++;
								}else {
									rgb = _waterMarkWBitmap.bitmapData.getPixel(tx, ty);
									b = rgb & 0xFF;
									if (b < (0xFF)) {
										b = 0xFF - (rgb & 0xFF);
										argb = (b << 24) | 0x000000;
										_watermarkBitmap.bitmapData.setPixel32(tx, ty, argb);
										wList[2] ++;
										//trace(tx, ty);
									}else{
									
										rgb = _waterMarkBBitmap.bitmapData.getPixel(tx, ty);
										b = rgb & 0xFF;
										if (b > 2) {
											argb = (b << 24) | 0xFFFFFF;
											_watermarkBitmap.bitmapData.setPixel32(tx, ty, argb);
											bList[2] ++;
											//trace("B2");
										}
									}
								}
							}
							
						}
					}
					
					
				}
			}
			trace(bList);
			trace(wList);
			
			var byteArray:ByteArray = _watermarkBitmap.bitmapData.encode(new Rectangle(0, 0, _watermarkBitmap.width, _watermarkBitmap.height), new PNGEncoderOptions());
			var fileReference:FileReference = new FileReference();
			fileReference.save(byteArray, "watermark.png");
		}
	}
	
}