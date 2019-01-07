

	class rule {
		// rule is something, that can be owned by a player, which shows 
		// a permanent or temporary availabilities of doing something
		
		// each rule, which can be used should return the folowwing
		// -1 -- REJECT action, it's regulating
		// 1 -- accept
		// 0 -- do not regulates
		
		
		
		static function createRule(
			playerObject:Object, // player, which has this rule
			description:String, // description of rule, like 'can play zombies from graveyard this turn'
			ruleType:Number, // key code number, which shows the rule meaning
			ruleLong:Number, // keycode, shows when keycode ends
			parameters, // other params of rule are number/array
			source:Object // something, that gives you this rule
		):Object	 // return rule object
		{
			// a special object for default rule's source
			if (gameLogick._name == undefined) gameLogick._name = "Game Logick";
			
			var res = new Object();
			res.description = description;
			res.host = playerObject;
			res.ruleType = ruleType;
			res.ruleLong = ruleLong;
			if (source != undefined) res.source = source; else res.source = gameLogick;
			
			// parameters special
			res.parameters = consts.makeNumberArray(parameters);
			// if it is casting rule, than ad it func
			//if (res.ruleType >= castRulesFrom && res.ruleType <= castRuleTo);
			//	res.checkCastingAvailable = checkFunctions[res.ruleType - castRulesFrom];
				
			return res;
		}
		
		static var gameLogick = new Object();
		
		static var permanent = 50;
		static var untilTurnEnd = 100;
		
		
		// acceptance
		static var playerCanLandDropFromX = 1000;
		static var playerCanCastAnySpellFromX = 1001;
		static var playerCanPlayCardsDuringHisTurnAtPhaseX = 1002;
		static var playerCanAlwaysCastSpellTypeX = 1003;
		static var playerCanAlwaysCastSpellWithAbilityX = 1004;
		static var castRulesFrom = 1000;
		static var castRuleTo = 1100;
		// . . . . .
		
		static var checkFunctions = new Array(
			// 1000
			function (rO:Object, cardObj:Object):Number {  	// for lands
				var isLand = (card.isType(cardObj, typ.Land));
				if (!isLand) return 0;
				if (cardObj.isin == rO.parameters[0]) // if it is this direct place
					return 1;
				return 0; // this rule can not reject
			},
			// 1001
			function (rO:Object, cardObj:Object):Number { 	// for non-lands
				var isLand = (card.isType(cardObj, typ.Land));
				if (isLand) return 0;
				if (cardObj.isin == rO.parameters[0]) // if it is this direct place
					return 1;
				return 0;
			},
			// 1002
			function (rO:Object, cardObject:Object):Number { 	// for non-lands & lands
				var isMyTurn = (rO.host.game.currentTurnPlayerIndex == rO.host.PID); 
				var phase = rO.host.game.phase;
				var isNeedPhase = (phase == rO.parameters[0]);
				return 1 * (isMyTurn & isNeedPhase);
			},
			//1003
			function (rO:Object, cardObject:Object):Number{
				return 1 * card.isType(cardObject, rO.parameters[0]);
			},
			//1004
			function (rO:Object, cardObject:Object):Number{
				return 1 * abilities.has(cardObject, rO.parameters[0]);
			}
		);
		
		static function r1(rO:Object, cardObj:Object):Number {  	// for lands
			var isLand = (card.isType(cardObj, typ.Land));
			if (!isLand) return 0;
			if (cardObj.isin == rO.parameters[0]) // if it is this direct place
				return 1;
			return 0; // this rule can not reject
		}	
		
		static function defaultPlayerPlayCardRules(playerHost:Object):Array{
			var res = new Array();
			res.push(createRule(playerHost, "Can play lands from hand", playerCanLandDropFromX, permanent, places.hand));
			res.push(createRule(playerHost, "Can cast spells from hand", playerCanCastAnySpellFromX, permanent, places.hand));
			res.push(createRule(playerHost, "Can play cards from hand during his main phase", playerCanPlayCardsDuringHisTurnAtPhaseX, permanent, gameengine.main));
			res.push(createRule(playerHost, "Can play cards from hand during his second main phase", playerCanPlayCardsDuringHisTurnAtPhaseX, permanent, gameengine.secondMain));
			res.push(createRule(playerHost, "Can cast instants any time", playerCanAlwaysCastSpellTypeX, permanent, typ.Instant));
			res.push(createRule(playerHost, "Can cast spells with flash any time he can cast instant", playerCanAlwaysCastSpellWithAbilityX, permanent, abilities.flash));
			return res;
		}
		
		// solving function, that uses playing card (1000..1100) rules
		static function addCanPlayResolveFunction(playerHost:Object):Void{
			playerHost.canCast = function(cardObject:Object):Boolean{
				// . . . 
				for (var i = 0; i < this.cardPlayingRules.length; ++i){
					var curRule = this.cardPlayingRules[i];
					if (curRule.ruleType < castRulesFrom || curRule.ruleType > castRuleTo){ 
						consts.LOG("X  Error: rule has no cast checking function!  "+ curRule.description);
						continue;
					}
					var ruleRes = (checkFunctions[curRule.ruleType - castRulesFrom])(curRule, cardObject);
					consts.LOG(ruleRes + "  " + curRule.description);
				}
				return true;
			}
		}
		
		/*
		newPlayer.canCastSpellFilters = defaultcanCastFilter();
			///if at least one rule resolve, than you can cast it
			newPlayer.canCast = function (cardObj:Object):Boolean { 
				for (var i = 0; i < this.canCastSpellFilters.length; ++i)
					if (this.canCastSpellFilters[i](cardObj, this) == false){
						consts.LOG(cardObj._name  + " casting is rejected");
						return false;
					}
				consts.LOG(cardObj._name  + " casting is available");
				return true; // no way to cast!
			}
			
			
			static function defaultcanCastFilter():Array{
			var res = new Array(); // where from you can cast spells?  by default
			res.push(			// cast ANY (-1) SPELL //  from HAND
				function (spell:Object, playerO:Object):Boolean { 
					var isMyTurn = (gameengine.game.currentTurnPlayerIndex == playerO.PID); 
					var phase = gameengine.game.phase;
					var isMainPhase = (phase == gameengine.main || phase == gameengine.secondMain);
					var hasFlash = abilities.has(spell, abilities.flash);
					var isInstant = card.isType(spell, typ.Instant);
					var isInHand = spell.isin == places.hand;
					
					consts.LOG(spell._name  + " is :");
					consts.LOG("  your turn?     " + isMyTurn);
					consts.LOG("  main phase?    " + isMainPhase);
					consts.LOG("  is instant?    " + isInstant);
					consts.LOG("  has flash?     " + hasFlash);
					return (isInstant || hasFlash || (isMyTurn && isMainPhase));
				}
			);
			// now you can not play creatures just because
			res.push(function (spell:Object, playerO:Object):Boolean 
				{ 
					return !(card.isType(spell, typ.Creature)); 
				}
			);
			return res;
		}*/
	}