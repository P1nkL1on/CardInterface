
	class back{
		static var layer = null;
		static var effectlayer = null;
		
		static var objs = new Array();
		
		static var lastSpawn = null;
		
		static function find_pid(what){
			for (var i = 0; i < objs.length; i += 2)
				if (objs[i] == what)
					return ++objs[i+1];
			
			objs.push(what);
			objs.push(1);
			return 1;
		}
		static function next_unique_name(what){
			return what+"_"+find_pid(what);
		}
		
		static function create_layer():MovieClip{
			return layer = create_obj(undefined, "empty", "layer");
		}
		static function create_obj(where, what, newname):MovieClip{
			if (where == undefined) where = _root;
			if (newname == undefined) newname = what;
			var obj:MovieClip = where.attachMovie(
				what, next_unique_name(newname),
				where.getNextHighestDepth());
			lastSpawn = obj;
			return obj;
		}
		static function exists (){ return layer != null; }
		
		static function base_layer (){ 
			return (exists())? layer : create_layer();
		}
		
		
		static function effect_layer (){ 
			return (effectlayer != null)? effectlayer : (effectlayer = create_obj(undefined, "empty", "effectlayer"));
		}
	}