

	class defaultStats {
	
		// creature basics
		static var PT_perName = new Array(
			"Rustwing Falcon", 1, 2,
			"Daybreak Chaplain", 1, 3,
			
			"Test Creature", 4, 5,
			"Test Wizard", 2, 2
			"Test Ogre", 3, 4,
			"Test Dogo", 1, 1
		);
		
		static function findStatByName(nam:String, isPower:Boolean):Number{
			for (var i = 0; i < PT_perName.length; i+=3)
				if (PT_perName[i] == nam)
					return  PT_perName[i + 2 - 1 * isPower];
			return 0;
		}
		
		
		static function createAsCreatureObject(nam:String):Object{
			
			var asCreature = new Object();
			asCreature.Pbase = findStatByName(nam, true);
			asCreature.Tbase = findStatByName(nam, false);
			asCreature.Pplus = new Array();
			asCreature.Tplus = new Array();
			asCreature.Pset = new Array();
			asCreature.Tset = new Array();
			asCreature.damage = new Array();
			
			asCreature.Pow = function ():Number { 
				if (this.Pset.length == 0){
					var res = this.tougthness;
					for (var i = 0; i < this.Pplus.length; ++i)
						res += this.Pplus[i];			// summ of base + all other
					return res;
				}
				return this.Pset[this.Pset.length - 1];	// if T is seted, than it will be set to some of valeus
			}
			asCreature.Tof = function ():Number { 
				if (this.Tset.length == 0){
					var res = this.tougthness;
					for (var i = 0; i < this.Tplus.length; ++i)
						res += this.Tplus[i];			// summ of base + all other
					return res;
				}
				return this.Tset[this.Tset.length - 1];	// if T is seted, than it will be set to some of valeus
			}
			asCreature.TofDamaged = function ():Number{
				var res = this.Tof();
				for (var i = 0; i < this.damage.length; ++i)
						res -= this.damage[i];			// summ of base + all other - all incomed damaged
				return res;
			}
			
			return asCreature;
		}
	}