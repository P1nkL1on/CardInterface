

	class cost {
		
		static function createCost(
		
		){
			
		}
		
		static function noCost(){
			var newCost = new Object();
			newCost.isNone = true;
			
			return newCost;
		}
		
		static function lcostToString(c:Object):String{
			if (c.isNone == true)
				return "no cost";
			return "some cost";
		}
		
		static function costToStringArray(cCostArr:Array, cFromArr:Array):Array{
			var res = new Array();
			for (var i = 0; i < cCostArr.length; ++i)
				res.push("can be cast for " + lcostToString(cCostArr[i]) + " from " + places.placeToString(cFromArr[i]));
			return res;
		}
		static function costToString(cCostArr:Array, cFromArr:Array):String{
			var res = ""; var ar = costToStringArray(cCostArr, cFromArr);
			for (var i = 0; i < ar.length; ++i)
				res += ar[i] + ((i < ar.length - 1)? ", " : "");
			return res;
		}
		
		static function payTheCost(c):Boolean{
			return (c.isNone == true);
		}
	}