

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
	// - - - -- - creature subtypes
		static var Beast = subtypeF(Creature, 1);
		static var Vampire = subtypeF(Creature, 2);
		static var Skeleton = subtypeF(Creature, 3);
		static var Human = subtypeF(Creature, 4);
		static var Dog = subtypeF(Creature, 5);
		static var Ogr = subtypeF(Creature, 6);
		static var Wizard = subtypeF(Creature, 7);
	
		
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
				case Plane: return "Plane";
				case Island: return "Island";
				case Forest: return "Forest";
				case Swamp: return "Swamp";
				case Mountain: return "Mountain";
				
				case Beast: return "Beast";
				case Vampire: return "Vampire";
				case Vampire: return "Vampire";
				case Skeleton: return "Skeleton";
				case Human: return "Human";
				case Dog: return "Dog";
				case Ogr: return "Ogr";
				case Wizard: return "Wizard";
				default: return "SubType"+t;
			}
			return "????";
		}
		
		static function gamePhaseToString(t){
			switch (t){
				case gameengine.untap: return "untap";
				case gameengine.unkeep: return "unkeep";
				case gameengine.draw: return "draw";
				case gameengine.main: return "main";
				case gameengine.declareattackers: return "declare attackers";
				case gameengine.declareblockers: return "declare blockers";
				case gameengine.damage: return "damage";
				case gameengine.secondMain: return "second main";
				case gameengine.endstep: return "end";
				
				default: return "Phase"+t;
			}
			return "????";
		}
	}