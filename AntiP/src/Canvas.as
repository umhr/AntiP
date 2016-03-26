package 
{
	
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import jp.mztm.umhr.create.Ichimatsu;
	import jp.mztm.umhr.net.FetchFile;
	/**
	 * ...
	 * @author umhr
	 */
	public class Canvas extends Sprite 
	{
		[Embed(source = '800_w.jpg')]
		private static const ImageEx:Class;
		
		[Embed(source = 'watermark.png')]
		private static const WaterMark:Class;
		
		private var _ichimatsuCanvas:Sprite = new Sprite();
		private var _uiCanvas:Sprite = new Sprite();
		private var _photoCanvas:Sprite = new Sprite();
		private var _targetBitmap:Bitmap;
		private var _waterMarkBitmap:Bitmap;
		private var _fetchFile:FetchFile;
		private var _watermarkMaker:WatermarkMaker = new WatermarkMaker();
		public function Canvas() 
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
			stage.addEventListener(Event.RESIZE, resize);
			
			_watermarkMaker.addEventListener(Event.COMPLETE, watermarkMaker_complete);
			_watermarkMaker.start();
			
			addChild(_ichimatsuCanvas);
			addChild(_photoCanvas);
			addChild(_uiCanvas);
		}
		
		private function watermarkMaker_complete(e:Event):void 
		{
			_watermarkMaker.removeEventListener(Event.COMPLETE, watermarkMaker_complete);
			
			new PushButton(_uiCanvas, 8, 8, "Load jpg", onLoad);
			
			resize(null);
			
		}
		
		private function resize(e:Event):void 
		{
			_ichimatsuCanvas.removeChildren();
			_ichimatsuCanvas.addChild(new Ichimatsu(stage.stageWidth, stage.stageHeight));
		}
		private function onLoad(e:Event = null):void {
			_fetchFile = new FetchFile();
			_fetchFile.addEventListener(Event.COMPLETE, fetchFile_complete);
			_fetchFile.start([new FileFilter("Jpeg", "*.jpg")]);
		}
		
		private function fetchFile_complete(e:Event):void 
		{
			_fetchFile.removeEventListener(Event.COMPLETE, fetchFile_complete);
			
			_photoCanvas.removeChildren();
			
			_targetBitmap = _fetchFile.content as Bitmap;
			if (_targetBitmap == null) {
				trace("画像が存在しません");
				return;
			}
			
			_photoCanvas.addChild(_targetBitmap);
			
			_waterMarkBitmap = new Bitmap(new BitmapData(_targetBitmap.width, _targetBitmap.height, true, 0));
			var shape:Shape = new Shape();
			shape.graphics.beginBitmapFill(_watermarkMaker.watermarkBitmapData);
			//shape.graphics.beginBitmapFill((new WaterMark() as Bitmap).bitmapData);
			shape.graphics.drawRect(0, 0, _targetBitmap.width, _targetBitmap.height);
			shape.graphics.endFill();
			
			_waterMarkBitmap.bitmapData.draw(shape);
			
			var n:int = _waterMarkBitmap.height;
			for (var ty:int = 0; ty < n; ty++) 
			{
				var m:int = _waterMarkBitmap.width;
				for (var tx:int = 0; tx < m; tx++) 
				{
					var waterMarkARGB:uint = _waterMarkBitmap.bitmapData.getPixel32(tx, ty);
					var waterMarkA:int = waterMarkARGB >> 24 & 0xFF;
					if (waterMarkA > 0) {
						var waterMarkR:int = waterMarkARGB >> 16 & 0xFF;
						var waterMarkG:int = waterMarkARGB >> 8 & 0xFF;
						var waterMarkB:int = waterMarkARGB & 0xFF;
						var targetRGB:int = _targetBitmap.bitmapData.getPixel(tx+0, ty);
						var targetR:int = targetRGB >> 16 & 0xFF;
						var targetG:int = targetRGB >> 8 & 0xFF;
						var targetB:int = targetRGB & 0xFF;
						
						var rgb:int = fukugen(waterMarkR, targetR, waterMarkA) << 16 | fukugen(waterMarkG, targetG, waterMarkA) << 8 | fukugen(waterMarkB, targetB, waterMarkA);
						
						_targetBitmap.bitmapData.setPixel32(tx+0, ty, rgb);
					}
					
				}
			}
			
			new PushButton(_photoCanvas, 200, 8, "Save", onSave);
			
		}
		private function onSave(e:Event = null):void {
			var byteArray:ByteArray = _targetBitmap.bitmapData.encode(new Rectangle(0, 0, _targetBitmap.width, _targetBitmap.height), new JPEGEncoderOptions(90));
			var fileReference:FileReference = new FileReference();
			var name:String = _fetchFile.name;
			fileReference.save(byteArray, name.substr(0, name.length - 4) + "_de.jpg");
		}
		
		
		private function fukugen(waterMark:int, target:int, a:int):int {
			var ratio:Number = a / 0xFF;
			
			var result:int = (target -waterMark * ratio) / (1 - ratio);
			
			return Math.max(Math.min(result, 0xFF), 0);
		}
		private function gousei(waterMark:int, target:int, a:int):int {
			var ratio:Number = a / 0xFF;
			var result:int = (waterMark * ratio) + (target * (1 - ratio));
			return Math.min(result, 0xFF);
		}
	}
	
}