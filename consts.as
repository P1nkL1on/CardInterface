

	class consts {
	
		static var playerStartingLifeTotal = 20;
		static var playerStartingCardsInHand = 7;
		
		
		
		static var lastMess = "";
		static function LOG(mess){ trace((lastMess == mess)? "same" : mess); lastMess = mess; }
		
		static function isNumberArrayOrNumber(arr):Boolean{return (arr.length != undefined);}
		
		static function makeNumberArray(arr):Boolean{
			if (isNumberArrayOrNumber(arr)) return arr;
			var newArr = new Array();
			newArr.push(arr);
			return newArr;
		}
		
		static function makeSortedNumberArray(arr):Boolean{
			var resultArr = makeNumberArray(arr);
			resultArr.sort(Array.NUMERIC); 
			return resultArr;
		}
		
		static function stringArr(arr):String{return("("+arr.length+"){"+arr+"}");}
		static function traceArr(arr):Array {trace(stringArr(arr)); return arr;}
		
		static function isInArray(arr, val){
			for (var i = 0; i < arr.length; ++i) if (arr[i] == val) return true; return false;
		}
		static function indexOfInArray(arr, val){
			for (var i = 0; i < arr.length; ++i) if (arr[i] == val) return i; return -1;
		}
		
		static function uniqArray(arr1, arr2):Array{
			//trace(arr1 + "+" + arr2)
			var resArr = new Array();
			for (var i = 0; i < arr1.length; ++i)
				if (!isInArray(resArr, arr1[i]))
					resArr.push(arr1[i]);
			for (var i = 0; i < arr2.length; ++i)
				if (!isInArray(resArr, arr2[i]))
					resArr.push(arr2[i]);
			return resArr;
		}
	}