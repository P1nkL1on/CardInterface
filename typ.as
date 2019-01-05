

	class typ {
	
	// -- -- -- TYPE
	// 30...
		static var Land = 51;
		static var Basic = 50;
		static var Artifact = 100;
		static var Creature = 101;
		static var Enchantment = 102;
		static var Planewalker = 103;
		static var Emblem = 105;
		static var Instant = 200;
		static var Sorcery = 201;
		static var Legendary = 30;
		static var Token = 31;
	// .. 300 .. 
		static function subtypeF (typeValue, personalValue):Number{ return typeValue * 100 + personalValue;}
	// -- -- -- SUBTYPE
		static var Plane = subtypeF(Land, 1);
		static var Island = subtypeF(Land, 2);
		static var Forest = subtypeF(Land, 3);
		static var Swamp = subtypeF(Land, 4);
		static var Mountain = subtypeF(Land, 5);
	
		
		static function typToString(t):String{
			switch (t){
				case Land: return "Land";
				case Basic: return "Basic";
				case Artifact: return "Artifact";
				case Creature: return "Creature";
				case Enchantment: return "Enchantment";
				case Planewalker: return "Planewalker";
				case Emblem: return "Emblem";
				case Instant: return "Instant";
				case Sorcery: return "Sorcery";
				case Legendary: return "Legendary";
				case Token: return "Token";
				default: return "Type"+t;
			}
			return "????";
		}
		
		
		static function subTypToString(t):String{
			switch (t){
				case subtypeF(Land, 1): return "Plane";
				case subtypeF(Land, 2): return "Island";
				case subtypeF(Land, 3): return "Forest";
				case subtypeF(Land, 4): return "Swamp";
				case subtypeF(Land, 5): return "Mountain";
				default: return "SubType"+t;
			}
			return "????";
		}
	}