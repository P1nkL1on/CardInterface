

	class colors {
	
		static var none = 0;
		static var white = 1;
		static var blue = 2;
		static var green = 3;
		static var black = 4;
		static var red = 5;
		
		static function colorToString(c):String{
			switch (c){
				case white: return "White";
				case blue: return "Blue";
				case green: return "Green";
				case black: return "Black";
				case red: return "Red";
				case none: return "Colorless";
				default: return "Color" + c;
			}
			return "????";
		}
		
		
		static var whiteColor = new Array(245,244,240);
		static var blueColor = new Array(0,138,209);
		static var greenColor = new Array(0,139,70);
		static var blackColor = new Array(64,61,61);
		static var redColor = new Array(192,60,39);
		
		// aplly color
		static function colorToRGB(who, r, g, b){
			var clr:Color = new Color(who); 
			clr.setTransform({rb:r, gb:g, bb:b});
		}
		static function colorToRGBArray(who, rgb:Array):Void{
			var clr:Color = new Color(who); 
			clr.setTransform({rb:rgb[0], gb:rgb[1], bb:rgb[2]});
		}
		static function colorTo(who, colorIndex):Void{
			switch (colorIndex){
				case white: colorToRGBArray(who, whiteColor); break;
				case blue: colorToRGBArray(who, blueColor);break;
				case green: colorToRGBArray(who, greenColor);break;
				case black: colorToRGBArray(who, blackColor);break;
				case red: colorToRGBArray(who, redColor);break;
				case none: colorToRGB(who, 120, 120, 120);break;	// neutral no clor spell
				case -1: colorToRGB(who, 237, 204, 78);break;		// 3+ colors
				default: return;
			}
			return;
		}
		static function colorArrTo(who:Array, colorIndex):Void{
			for (var i = 0; i < who.length; ++i)
				colorTo(who[i], colorIndex);
		}
	}