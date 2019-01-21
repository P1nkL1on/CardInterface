

	class places {
	
		static var deck = 0;
		static var hand = 1;
		static var battlefield = 2;
		static var graveyard = 3;
		static var exile = 4;
		static var stack = 5;
		
		
		static var totalPlaceCount = 6;
		
		
		static function placeToString(c):String{
			switch (c){
				case deck: return "deck";
				case hand: return "hand";
				case battlefield: return "battlefield";
				case graveyard: return "graveyard";
				case exile: return "exile";
				case stack: return "stack";
				default: return "!?place!?" + c;
			}
			return "????";
		}
		
	}