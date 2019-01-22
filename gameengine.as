

	class gameengine {
	
		static function test(){
			
			var g = initialiseGame(
				new Array(
					"John", 
					"Paul"
				), 
				new Array(
					new Array(
					10, "Basic Plane",
					10, "Basic Swamp",
					10, "Basic Forest",
					10, "Basic Mountain",
					10, "Basic Island",
					14, "Test Dogo",
					14, "Test Artifact",
					14, "Test Robot"), 
					new Array(
					2, "Basic Forest",
					20, "Basic Mountain",
					4, "Test Creature",
					7, "Test Wizard",
					14, "Test Ogre",
					7, "Test Artifact"
					)
				));
			
			g.forEachPlayer(function(playerObject){
				player.playerShuflesDeck(playerObject);
				drawing.createMcForEveryPlayerCard(playerObject);
				drawing.updateCardsOfPlayer(playerObject);
				drawing.updateCoutners();
			});
			//player.playerDrawsCards(ivan, 7);
			
			// emblem! 
			// at the begginig of each unkeep all player untap all shit he has
			// then all the shit abilities works
			// at the end of each unkeep that player draws a card
			
			// player can play only 1 land dureing his turn
			
			game = g;
		}
	
		static function createMapsForAGame(gameObject:Object, scale:Number):Array{
			gameObject.gameFields = new Array();
			if (scale == undefined) scale = 1;
			for (var i = 0; i < gameObject.players.length; ++i){
				var map = back.create_obj(back.base_layer(), "map");
				gameObject.players[i].map = map;
				map._x = (map._width + 20) * (i % 2) * scale;
				map._y = (map._height + 20) * (i - i %2) / 2 * scale + 100;
				map._xscale = map._yscale = 100 * scale;
				map.scale = scale;
				map.playertxt.text = gameObject.players[i]._name+"'s perspective";
				map.gametxt.text = gameObject.getCurrentTurnString();
				map.playerID = gameObject.allPlayersIDS[i];
				gameObject.gameFields.push(map);
				map.xmouse = function (){ return (_root._xmouse - this._x) / this.scale; }
				map.ymouse = function (){ return (_root._ymouse - this._y) / this.scale; }
				
				for (var dc = 0, plc = 0; dc < 3; ++dc, plc = (new Array(0, 3, 4))[dc]){
					var deckCounter = back.create_obj(back.effect_layer(), "flying_number" );
					deckCounter.num.text = "";
					deckCounter.pl = gameObject.players[i];
					deckCounter.place = plc; deckCounter._x = map._x + (drawing.viewLeftBorder + drawing.viewDeckMargin* dc) * scale; deckCounter.yy = 570; deckCounter._y = deckCounter.yy;
					drawing.deckCoutners.push(deckCounter);
					deckCounter.onMouseMove = function (){
						if (this.num.text == "0"){this._visible = false; return;}
						this._visible = (Math.abs(this._x - _root._xmouse) < drawing.cardScale / 2 && Math.abs(this._y - _root._ymouse) < drawing.cardScale / 2);
					}
				}
			}
			return gameObject.gameFields;
		}
	
	
		static var game:Object = null;	// last instantiated game copy
		
		static function initialiseGame(
			players:Array,		// { "player1", "player2 ", ...} 
			playerCards:Array 	// {"array = deck of player1", "arrary = deck of player 2", ...}
		):Object			// return the Game object
		{
			var newGame = new Object();
			newGame.allPlayersIDS = new Array();
			newGame.players = new Array(); // player objects array
			for (var i = 0; i < players.length; ++i){
				newGame.players.push(player.createPlayer(newGame, i, players[i], playerCards[i]));
				newGame.allPlayersIDS.push(i);
			}
			newGame.playerCount = newGame.players.length; 					// number of players
			newGame.currentTurnPlayerIndex = 0;//random(newGame.playerCount);	// will start the game
			
			newGame.getPlayer = function (PID:Number):Object{return this.players[PID];}
			newGame.getCurrentPlayer = function ():Object{return this.getPlayer(this.currentTurnPlayerIndex);}
			newGame.phase = main;
			newGame.infoTextBox = _root.infotxt;
			newGame.getCurrentTurnString = function ():String { return this.getCurrentPlayer()._name+"'s " + typ.gamePhaseToString(this.phase); } 
			createMapsForAGame(newGame, .72);
			newGame.forEachPlayer = function (action):Void{ for (var i = 0; i < this.playerCount; ++i) action(this.players[(i + this.currentTurnPlayerIndex)%this.playerCount]); }
			game = newGame;	// assign a last copy
			
			return game;
		}
		static var untap = 10;
		static var unkeep = 11;
		static var draw = 12;
		static var main = 13;
		static var declareattackers = 14;
		static var declareblockers = 15;
		static var damage = 16;
		static var secondMain = 17;
		static var endstep = 18;
	}