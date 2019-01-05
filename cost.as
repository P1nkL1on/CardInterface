

	class cost {
		
		static function createCost(
		
		){
			
		}
		
		static function noCost(){
			var newCost = new Object();
			newCost.isNone = true;
			
			return newCost;
		}
		
		static function costToString(c):String{
			if (c.isNone == true)
				return "no cost";
			return "some cost";
		}
	}