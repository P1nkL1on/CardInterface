

	class drawing {
		
		
		static function makePictureForCard(cardObject:Object):Number{
			if (cardObject.cTypes()[0] + cardObject.cTypes()[1] == 101)
				return makePictureForBasicLand(cardObject.cardColor[0]);
			return makePicture(cardObject._name);
		}
		
		static function makePicture(cardName):Number{
			return 1;
		}
		static var colorToPic = new Array(-1, 4, 2, 1, 5, 3);
		static function makePictureForBasicLand(cardColor):Number{
			return colorToPic[cardColor] + (random(5)) * 5;
		}
		
		
		
		// VISUAL TRACE FUNCTIONS
		static function traceToMovieClip(cardObject:Object, mc:MovieClip):MovieClip{
			// apply color
				var clrs:Array = cardObject.cColors(); var clL = clrs.length;

				if (clL == 2){ colors.colorTo(mc.clr0, clrs[0]); colors.colorTo(mc.clr1, clrs[1]); } 
				if (clL == 0) colors.colorArrTo(new Array(mc.clr0, mc.clr1), colors.none);
				if (clL == 1) colors.colorArrTo(new Array(mc.clr0, mc.clr1), clrs[0]);
				if (clL >= 3) colors.colorArrTo(new Array(mc.clr0, mc.clr1), -1);
			
			if (cardObject.isVisibleTo.length > 0)
				mc.pic.gotoAndStop(makePictureForCard(cardObject));
			else
			// draw unseen cards back up
				mc.gotoAndStop('unseen');
				
			consts.LOG("'"+cardObject._name + "' proected to movieclip '" + mc._name + "'");
			return mc;
		}
		
		static function traceToNewMovieClip(cardObject:Object):MovieClip{
			var newCard = back.create_obj(back.base_layer(), "card" );
			traceToMovieClip(cardObject, newCard);
			return newCard;
		}
		static var stopMoveWhen = 1;
		static function createMcForEveryPlayerCard(playerObject:Object, x, y):Void{
			for (var i = 0, cardWas = 0; i < 5; ++i, cardTotal += cardTotal){
				var place = i;
				var cardNumber = 0;
				var cardTotal = player.cardCountIn(playerObject, place);
				var xFrom = 50; var xTo = 550;
				
				player.forEachCardIn(playerObject, place, function(card:Object){ 
					var mc = traceToNewMovieClip(card);	
					card.mc = mc;
					mc._x = (x == undefined)? mc._width / 2 : x; mc._y = (y == undefined)? (mc._height / 2 - 10) : y;
					mc.xx = 0; mc.yy = 0; mc.zz = 0;	// global worl coordinations
					mc._rotation = (random(9)-4) / 3;
					mc.cacheAsBitmap = true;	// to descrease perfomance
					mc.timeout = -1;	// timers does not work now.
										// -1 - do nothing
										// > 0 - wait something
										// == 0 working
					// for the first time of creation we leave depthes of cards default
					mc.movespd = 5;
					mc.onEnterFrame = function (){
						//trace(this.timeout)
						if (this.timeout == -1) return;
						if (this.timeout > 0) {this.timeout--; return;}
						
						this.dx = (this.xx - this._x);
						this.dy = (this.yy - this.zz - this._y);
						this._x += this.dx / this.movespd;
						this._y += this.dy / this.movespd * .5;
						if (Math.abs(this.dx) < stopMoveWhen && Math.abs(this.dy) < stopMoveWhen)
							this.timeout = -1;
					}
				});
			}
		}
		static function moveCard(cardObj:Object, XX, YY, ZZ, wait){
			if (cardObj.mc == undefined)
				return;
			cardObj = cardObj.mc;
			cardObj.xx = XX; cardObj.yy = YY; cardObj.zz = ZZ;
			cardObj.swapDepths(Math.round(cardObj.xx - cardObj.yy * 15 + cardObj.zz * 100));
			cardObj.timeout = wait;
			//trace(XX+'/'+YY+'/'+ZZ+'/'+wait+"   " + cardObj._name);
		}
		static var playerStartX = 60;
		static var playerStartY = 660;
		static function placeDecksForPlayer(playerObject:Object):Void{
			var places = new Array(0,3,4);
			var place = 0;
			var cardTotal = player.cardCountIn(playerObject, place);
			var cardNumber = 0;
			player.forEachCardIn(playerObject, place, function(card:Object){ 
				moveCard(card, playerStartX + randomOffset() * 2, playerStartY + randomOffset(), ++cardNumber, cardNumber * 2);
			});
		}
		static function randomOffset():Number{
			return random(50)/10 - 2.5;
		}
		//mc.xx = (!place)? (xFrom + 50 + random(80) / 10 - 4) : (xFrom + (xTo - xFrom) / (cardTotal - 1) * (cardNumber++));
		//mc.yy = (place + 1) * 120;
		//mc.zz = (place)? 0 : (cardNumber ++ );
		//mc.swapDepths(Math.round(mc.xx + mc.zz * 100));
		//trace(place+":" + cardNumber + ":" + Math.round(-mc.xx + mc.zz * 100))
	}