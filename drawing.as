

	class drawing {
		
		
		static function makePictureForCard(cardObject:Object):Number{
			if (cardObject.cTypes()[0] + cardObject.cTypes()[1] == 101)
				return makePictureForBasicLand(cardObject.cardColor[0]);
			return makePicture(cardObject._name);
		}
		
		static function makePicture(cardName){
			return cardName;
		}
		static var colorToPic = new Array(-1, 4, 2, 1, 5, 3);
		static function makePictureForBasicLand(cardColor):Number{
			return colorToPic[cardColor] + (random(5)) * 5;
		}
		
		
		
		// VISUAL TRACE FUNCTIONS
		static function traceToMovieClip(cardObject:Object, mc:MovieClip):MovieClip{
			var isSeenHere = false;
			//trace( cardObject.isVisibleTo+'/'+mc.onFieldOfID)
			for (var i = 0; i < cardObject.isVisibleTo.length; ++i)
			if (mc.onFieldOfID == cardObject.isVisibleTo[i]){
				isSeenHere = true; break;
			}
			mc.isBack = !isSeenHere;
			if (isSeenHere){
					var wasNot1 = mc._currentframe != 1;
					mc.gotoAndStop(1);
					if (wasNot1) {
						mc.pic.gotoAndStop((cardObject.usedImage == undefined)? makePictureForCard(cardObject) : cardObject.usedImage);// apply color
						cardObject.usedImage = mc.pic._currentframe;
					}
					
					var clrs:Array = cardObject.cColors(); var clL = clrs.length;

					if (clL == 2){ colors.colorTo(mc.clr0, clrs[0]); colors.colorTo(mc.clr1, clrs[1]); } 
					if (clL == 0) colors.colorArrTo(new Array(mc.clr0, mc.clr1), colors.none);
					if (clL == 1) colors.colorArrTo(new Array(mc.clr0, mc.clr1), clrs[0]);
					if (clL >= 3) colors.colorArrTo(new Array(mc.clr0, mc.clr1), -1);
				}
			else
			// draw unseen cards back up
				mc.gotoAndStop('unseen');
				
			//consts.LOG("'"+cardObject._name + "' proected to movieclip '" + mc._name + "'");
			return mc;
		}
		
		static function traceToNewMovieClip(cardObject:Object):Array{
			var arr = new Array();
			var plIDS = cardObject.host.game.allPlayersIDS;
			for (var i = 0; i < plIDS.length; ++i){
				var newCard = back.create_obj(cardObject.host.game.players[plIDS[i]].map, "card" );	// cards are on back stage
				newCard.orig = cardObject;				// link to a card object, that was done from
				newCard.onFieldOfID = plIDS[i];
				traceToMovieClip(cardObject, newCard);  // draw a card
				arr.push(newCard);
			}
			return arr;
		}
		static var stopMoveWhen = 1;
		static var selectedItem = -1;
		static var selectedItemX = -1;
		static function createMcForEveryPlayerCard(playerObject:Object, x, y):Void{
			for (var i = 0, cardWas = 0; i < 5; ++i, cardTotal += cardTotal){
				var place = i;
				var cardNumber = 0;
				var cardTotal = player.cardCountIn(playerObject, place);
				//var xFrom = 50; var xTo = 550;
				
				player.forEachCardIn(playerObject, place, function(ccard:Object){ 
					var mcs = traceToNewMovieClip(ccard);	
					ccard.mcs = mcs;
					for (var i = 0; i < mcs.length; ++i){
						var mc = ccard.mcs[i];
						mc._x = (x == undefined)? playerStartX : x; mc._y = (y == undefined)? (mc._height / 2 - 10) : y;
						mc.xx = playerStartX; mc.yy = 0; mc.zz = 0;	// global word coordinations
						mc._rotation = (random(9)-4) / 3;
						mc.cacheAsBitmap = true;	// to descrease perfomance
						mc.timeout = -1;	// timers does not work now.
											// -1 - do nothing
											// > 0 - wait something
											// == 0 working
						// for the first time of creation we leave depthes of cards default
						mc.movespd = 5;
						mc._z = 0; mc._yy = 0;	// special additional coordinates to simulate height
						mc.sp_z = 0; 			// speed in height coordinates
						mc.nextDepth = mc.getDepth();
						mc.choosingX = 0; mc.choosingY = 0;
						mc.onEnterFrame = function (){
							//trace(this.timeout)
							if (this.timeout == -1){ 
								// there is no card choosing in Deck!
								if (this.indeck == true) return;
								if (this.mouseOver) card.traceCardInfoToText(this.orig);
								// glow border of needed color
								this.gotoFr = 1; if (this.canbePlayed) this.gotoFr = 4; if (this.mouseOver) this.gotoFr = 2; if (this.selected) this.gotoFr = 3;
								if (this.glow._currentframe != this.gotoFr) this.glow.gotoAndStop(this.gotoFr);
								this.mouseOver = false;
								
								// is mouse i zone of hand, battlefield, etc
								this._x += (this.choosingX - this._x) / 3;
								this._y += (this.choosingY - this._y) / 8;
								this.notInZone = (Math.abs(this.yy - _root._ymouse) > 50 || _root._xmouse <= this.xfrom - 50 || _root._xmouse >= this.xto + 50);
								if (this.space <= 0){
									this.mouseOver = !this.notInZone && (Math.abs(this.xx - _root._xmouse) < 48);
									this.choosingY = this._yy - 30 * this.mouseOver;
									return; // cards are enougth wide to be seen well
								}
								// or else we need to move them casuse of cursors
								//this.dy = this.yy - _root._ymouse;
								// do not do anything, if mouse not in a place
								if (this.notInZone)
									{ this.choosingX = this.xx; this.choosingY = this._yy; return; }	 
								this.mouseOver = (_root._xmouse >= this.selectX && _root._xmouse < this.selectXt);
								if (this.isBack) return;
								if (this.mouseOver)
									{ this.choosingX = this.xx; this.choosingY = this._yy - 30; selectedItem = this.lastNumber; selectedItemX = this.xx - this.xfrom; return; }	
								else
									this.choosingY = this._yy;
								if (_root._xmouse >= this.selectXt)
									this.choosingX = this.xfrom + (selectedItemX - 100) / (selectedItem - 1) * (this.lastNumber);
								if (_root._xmouse <= this.selectX)
									this.choosingX = this.xfrom + selectedItemX + 100 + (this.xto - (selectedItemX + 100 + this.xfrom)) / (this.lastTotal - selectedItem) * (this.lastNumber - selectedItem - 1);
								if (Math.abs(this.choosingX - this.xx) > 100) this.choosingX = this.xx;
								return;
							}
							if (this.timeout <= 1 && this.timeout >= 0 && this.sp_z <= .1) this.swapDepths(this.nextDepth);
							if (this.timeout > 0) {this.timeout--; return;}
							
							this.dx = (this.xx - this._x);
							this.dy = (this.yy - this._yy);
							this.dz = (this.zz - this._z);
							this._x += this.dx / (this.movespd * 2);
							this._yy += this.dy / (this.movespd * 2);
							this._z += this.dz / (this.movespd * 3);
							this._z += this.sp_z; if (this.sp_z > .2) this.sp_z /= 1.03; else this.sp_z = 0; 
							
							if (-this.dz / this.movespd / 3 > this.sp_z && this.nextDepth != null)
							{this.swapDepths(this.nextDepth); this.nextDepth = null;}
							
							this._y = this._yy - this._z;
							if (Math.abs(this.dx) < stopMoveWhen && Math.abs(this.dy) < stopMoveWhen && Math.abs(this.dz) < stopMoveWhen * .2)
								this.timeout = -1;
							
						}
					}
				});
			}
		}
		static function moveCardMc(mc:MovieClip, XX, YY, ZZ, wait){
			if (mc == undefined)
				return;
			
				mc.xx = XX; mc.yy = YY; mc.zz = ZZ;
				mc.choosingX = XX; mc.choosingY = YY;
				mc.nextDepth = Math.round(mc.xx + mc.yy * 15 + mc.zz * 100)
				//mc.swapDepths();
				mc.timeout = wait;
			
			//trace(XX+'/'+YY+'/'+ZZ+'/'+wait+"   " + cardObj._name);
		}
		static var playerStartX = 80;
		static var playerStartY = 620;
		static function placeDecksForPlayer(playerObject:Object):Void{
			var places = new Array(0,3,4);
			for (var i = 0; i < places.length; ++i){
				var place = places[i];
				var cardTotal = player.cardCountIn(playerObject, place);
				var cardNumber = 0;
				var moveCardNumber = 0;
				var movenCardNumber = 0;
				var startX = playerStartX + 130 * i;
				player.forEachCardIn(playerObject, place, function(card:Object){
					++cardNumber;
					card.mc = card.mcs[0];
					for (var i = 0; i < card.mcs.length; card.mc = card.mcs[++i]){
						var moveToX = startX + randomOffset() * 2;
						var moveToY = playerStartY + randomOffset();
						// if it is deck it is backwards, cause you are drawing from the top!
						var moveToZ = (place == 0)? ( cardTotal - cardNumber) : cardNumber;
						// this IF prevent from moving giant count of cards, when ther place do not moves
						// there was an error, when standing stil lcards makes a giant timer
						if (Math.abs(card.xx -moveToX ) + Math.abs(card.yy - moveToY) + Math.abs(card.zz - moveToZ) < 20)
							return;
						var timer = 0;
						if (Math.abs(startX - card.mc.xx) < 5) 
							timer = 0.1; 		// this case prevent a 250 card deck to sloowly goon in match start
						else {
							++movenCardNumber;
							timer = moveCardNumber; 	// to show each card, whats is drawn, or discarded
							moveCardNumber += Math.max( 2, 30 - movenCardNumber * .3);		// time delay between card mvoements
							card.mc.sp_z = 25;			// speed of upping when card mvoes
						}
						card.mc.indeck = true;
						moveCardMc(card.mc, moveToX, moveToY, moveToZ,  timer / card.host.game.playerCount);
					}
				});
			}
		}
		static function randomOffset():Number{
			return random(30)/10 - 1.5;
		}
		static function placeBattlefield(playerObject:Object):Void{
			var creatureTotal = player.cardCountInFilter(playerObject, places.battlefield, player.filterCreatures);
			var landTotal = player.cardCountInFilter(playerObject, places.battlefield, player.filterLand); 
			var otherTotal = player.cardCountIn(playerObject, places.battlefield) - creatureTotal - landTotal;

			var crC = 0; var lC = 0; var oC = 0; var cardNumber = 0;
			var xFrom = 100; var xTo = 860; var yLine1 = 350; var yLine2 = 470;
			var xTo1 = 340; var xFrom1 = 620;
			
			var moveCardNumber = 30;
			player.forEachCardIn(playerObject, places.battlefield, function(ccard:Object){
				++cardNumber;
				var isCreature = card.isType(ccard, typ.Creature);
				var moveToX = 0; var moveToY = 0; var moveToZ = 0;
				var isLand = card.isType(ccard, typ.Land);
				
				
				if (isCreature){
					++crC
					for (var i = 0; i < ccard.mcs.length; ++i){
						moveToX = calculateXCoord(xFrom, xTo, creatureTotal-1, crC - 1);
						moveToY = yLine1;
						spaceMc(ccard.mcs[i], xFrom, xTo, creatureTotal, crC - 1, moveToX)
						moveCardMc(ccard.mcs[i], moveToX, moveToY, moveToZ,  0);
					}
				}else{
					moveToY = yLine2;
					if (isLand){
						++lC;
						for (var i = 0; i < ccard.mcs.length; ++i){
							moveToX = calculateXCoord(xFrom, xTo1, landTotal-1, lC- 1);
							spaceMc(ccard.mcs[i], xFrom, xTo1, landTotal, lC - 1, moveToX)
							moveCardMc(ccard.mcs[i], moveToX, moveToY, moveToZ,  0);
						}
					}else{
						++oC;
						for (var i = 0; i < ccard.mcs.length; ++i){
							moveToX = calculateXCoord(xFrom1, xTo, otherTotal-1, oC- 1);
							spaceMc(ccard.mcs[i], xFrom1, xTo, otherTotal, oC - 1, moveToX)
							moveCardMc(ccard.mcs[i], moveToX, moveToY, moveToZ,  0);
						}
					}
				}
			});
		}
		
		static function placeHandForPlayer(playerObject:Object):Void{
			var cardTotal = player.cardCountIn(playerObject, places.hand);
			var cardNumber = 0;
			var xFrom = 480;
			var xTo = 880;
			var moveCardNumber = 30;
			player.forEachCardIn(playerObject, places.hand, function(card:Object){
				card.mc = card.mcs[0];
				for (var i = 0; i < card.mcs.length; card.mc = card.mcs[++i]){
					var moveToX = calculateXCoord(xFrom, xTo, cardTotal - 1, cardNumber);
					var moveToY = playerStartY;
					var moveToZ = 0;
					var timer = 0;
					if (Math.abs(moveToX - card.mc.xx) < 200) 
						timer = 0.2; 		// this case prevent a 250 card deck to sloowly goon in match start
					else {
						timer = moveCardNumber; 	// to show each card, whats is drawn, or discarded
						moveCardNumber += 30;		// time delay between card mvoements
						card.mc.sp_z = 15;			// speed of upping when card mvoes
						card.mc._rotation = 0;
					}
					spaceMc(card.mc, xFrom, xTo, cardTotal, cardNumber, moveToX)
					moveCardMc(card.mc, moveToX, moveToY, moveToZ,  timer / card.host.game.playerCount);
				}
				cardNumber ++;
			});
		}
		
		// update eactly of players place, or all of them if none paramtetr given
		// is special pater function for 3 other
		static function updatePlayerCardHolders(pl:Object, place:Number):Void{
			if (place == undefined) place = -1;
			switch (place){
				case places.deck:
				case places.graveyard:
				case places.exile:
					placeDecksForPlayer(pl);
					break;
				case places.hand:
					placeHandForPlayer(pl);
					break;
				case places.battlefield:
					placeBattlefield(pl);
					break;
				default:
					placeDecksForPlayer(pl);
					placeBattlefield(pl);
					placeHandForPlayer(pl);
					break;	
			}
		}
		
		static function calculateXCoord (xFrom, xTo, cardTotal, cardNumber):Number{
			return xFrom + ((spaceDiff(xFrom, xTo, cardTotal) > 0)?((xTo - xFrom) / (cardTotal) * (cardNumber)) : ((xTo - xFrom) / 2 + 100 * (cardTotal * (-.5) + cardNumber)));
		}
		
		static function spaceDiff (xFrom, xTo, cardTotal):Number{
			return cardTotal - (xTo - xFrom) / 100;
		}
		
		static function spaceMc(mc:MovieClip, xFrom, xTo, cardTotal, cardNumber, moveToX){
			mc.indeck = false;
			mc.lastTotal = cardTotal - 1;
			mc.lastNumber = cardNumber;
			mc.xfrom = xFrom; mc.xto = xTo;
			mc.spaceStep = (xTo - xFrom) / (cardTotal - 1);
			mc.selectX = moveToX - mc.spaceStep * .5; mc.selectXt = moveToX + mc.spaceStep * .5;
			mc.cOffset = 50 / mc.spaceStep;						
			if (cardNumber == 0) mc.selectX -= 50;				// left most
			if (cardNumber == cardTotal - 1) mc.selectXt += 50;	// right most cad zone add
			mc.space = spaceDiff(xFrom, xTo, mc.lastTotal);		// a palce between cards, which are common
		}
		
		
		
		
		// mana problems
		static var manaSpdMlt = 150;
		static var nowmana = 0;
		static function createManaAtCard(mc:MovieClip, manaColor:Number):MovieClip{
			var mn = back.create_obj(back.effect_layer(), "mana", "manadoteffect" );
			nowmana++;
			mn._x = mc.xx;
			mn._y = mc.yy;
			mn.gotoX = mn._x; mn.gotoY = mn._y;	 mn.sp_x = mn.sp_y = 0; mn.moveTimer = 0;
			mn.gotoAndStop(manaColor + 1);
			mn.onEnterFrame = function (){
				if (this.moveTimer < 1) return;
				this.moveTimer++;
				// stop move when reach target
				if (Math.abs(this._x - this.gotoX) + Math.abs(this._y - this.gotoY) < 5){ 
					if (this.destroyOnFinish) {nowmana --; this.removeMovieClip();}
					this.moveTimer = 0; this.sp_x = 0; this.sp_y = 0; return;
				}
				//
				this._x += this.sp_x; this._y += this.sp_y;
				this.sp_x += (this.gotoX - this._x) / manaSpdMlt * .3;
				this.sp_y += (this.gotoY - this._y) / manaSpdMlt;
				this.attepdspd = Math.max(2, 100 - this.moveTimer);
				this._x += (this.gotoX - this._x) / this.attepdspd;
				this._y += (this.gotoY - this._y) / this.attepdspd;
				if (random(nowmana) > 5) return;
				this.t = back.create_obj(back.effect_layer(), "mana_trace");
				this.swapDepths(this.t)
				this.t._x = this._x; this.t._y = this._y; this.t.gotoAndStop(this._currentframe);
			}
			return mn;
		}
		static var manaPoolX = 435;
		static var manaPoolY = 515;
		
		static function createManaAtCardAndMoveToManaPool(cardObj:Object, manaColor:Number):MovieClip{
			return createManaAtCardMcAndMoveToManaPool(cardObj.mc, manaColor);
		}
		
		static function createManaAtCardMcAndMoveToManaPool(mc:MovieClip, manaColor:Number):MovieClip{
			var mn = createManaAtCard(mc, manaColor);
			mn.gotoX = manaPoolX + manaColor * 20;
			mn.gotoY = manaPoolY;
			mn.moveTimer = 1;
			mn.destroyOnFinish = true;
			mn.sp_y = -15;
			mn.sp_x = (random(100) - 50) * .1;
			return mn;
		}
	}