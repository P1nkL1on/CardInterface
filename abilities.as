

	class abilities {
	
		static var flying = 500;
		static var flash = 501;
		
		static function staticAbilityToString(c):String{
			switch (c){
				case flying: return "flying";
				case flash: return "flash";
				default: return "!?staticAbility!?" + c;
			}
			return "????";
		}
		
		static function has(cardObject:Object, statAb:Number):Boolean{
			for (var i = 0; i < cardObject.abilities.length; ++i)
				if (cardObject.abilities[i] == statAb)
					return true;
			return false;
		}
		
	}