

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
				default: return "Color" + c;
			}
			return "????";
		}
	}