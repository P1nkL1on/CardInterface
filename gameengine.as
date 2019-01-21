

	class gameengine {
	
		static function test(){
			
			var g = initialiseGame(
				new Array(
					"John", 
					"Paul"
				), 
				new Array(
					new Array(
					20, "Basic Plane",
					20, "Basic Swamp",
					4, "Test Dogo",
					4, "Test Artifact",
					4, "Test Robot"), 
					new Array(
					20, "Basic Forest",
					20, "Basic Mountain",
					4, "Test Creature",
					4, "Test Wizard",
					4, "Test Ogre"
					)
				));
			
			var ivan = g.getPlayer(0);
			player.playerShuflesDeck(ivan);
			drawing.createMcForEveryPlayerCard(ivan);
			drawing.updateCardsOfPlayer(ivan);
			//player.playerDrawsCards(ivan, 7);
			
			// emblem! 
			// at the begginig of each unkeep all player untap all shit he has
			// then all the shit abilities works
			// at the end of each unkeep that player draws a card
			
			// player can play only 1 land dureing his turn
			
			game = g;
		}
	
		static function createMapsForAGame(gameObject:Object):Array{
			gameObject.gameFields = new Array();
			for (var i = 0; i < gameObject.players.length; ++i){
				var map = back.create_obj(back.base_layer(), "map");
				gameObject.players[i].map = map;
				map._x = (map._width + 20) * i;
				map.playerID = gameObject.allPlayersIDS[i];
				gameObject.gameFields.push(map);
				map.xmouse = function (){ return _root._xmouse - this._x; }
				map.ymouse = function (){ return _root._ymouse - this._y; }
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
			
			createMapsForAGame(newGame);
			
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