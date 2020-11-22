model queen_baseasshw3
global {
    int numberOfQueens <- 8;
    int boardSize <- 8; //4x4
    bool createBoard <- false;
    list<list> chessBoard;
    list<board_cell> listOfCells;
    int initPlaceCounter <- 0;
    
    init {
    create queen number: numberOfQueens ;
    }
}

species queen skills: [fipa]{
    float size <- 1.0 ;
    rgb color <- #blue;
    board_cell my_cell <- one_of (board_cell) ;
    int lastRowOnWhichQueenWasPlaced <-0; //we continue from here if we receive message from successor to move.
    bool placedForTheFirstTime <- false;
    int startingColumn<-0;
    
    bool isFirstAgent <- false;
    bool firstAgentInitialized <- false;
    
        
    init {
    location <- my_cell.location;
    location <- {initPlaceCounter,0,0};
    initPlaceCounter<-initPlaceCounter+10;
    	if(!createBoard)
    	{
    		
    		listOfCells <- list(board_cell);
    		createBoard<-true;		
				int indexCounter<-0;
				
				loop i from: 0 to: (boardSize-1) { 
					add [] to: chessBoard;
					
					loop j from: 0 to: (boardSize-1) {
						add 0 to: chessBoard[i];						
					} 
				} 
				write "CHESS BOARD:"+chessBoard;	
				isFirstAgent <- true;
    	}
    
    
    }
    	
    	reflex firstAgentInit when: isFirstAgent and !firstAgentInitialized{
    		firstAgentInitialized <- true;
    		
				list<queen> tempQueens <- list(queen);
				write "#### queens: "+tempQueens;
				int indexOfSelf <- tempQueens index_of self;
				
												
				if(returnQueenPlacedSuccessfullFlag(startingColumn))
				{
				write "Succeeded Placing Queen: "+indexOfSelf;
				do start_conversation with: [ to :: list(tempQueens[indexOfSelf+1]), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("You should place from "+self.name),"Place",self,(startingColumn+1)] ];
				}
				else{
				write "Failed placing Queen: "+indexOfSelf;
				}
    		
    	}
    
    	reflex receive_placeInfo when: !empty(informs) {
		message informFromInitiator <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromInitiator.sender).name + ' with content ' + informFromInitiator.contents;
		
		int columnToTry <- int(list(informFromInitiator.contents)[3]);
		startingColumn<-columnToTry;
        
		list<queen> tempQueens <- list(queen);
		int indexOfSelf <- agents index_of self;
				
			write "Attempting  to place the  queen: "+indexOfSelf+" at the  column "+columnToTry;
			if(returnQueenPlacedSuccessfullFlag(columnToTry) and indexOfSelf<numberOfQueens)
			{
			write "Succeeded in Placing  the Queen: "+indexOfSelf;
			if((startingColumn+1)<numberOfQueens)
			{
			do start_conversation with: [ to :: list(tempQueens[indexOfSelf+1]), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("You should reference the postition from "+self.name),"Place",self,(startingColumn+1)] ];
			}
			}
			else{
			write "Failed placing Queen: "+indexOfSelf;
			placedForTheFirstTime<-false;
			lastRowOnWhichQueenWasPlaced<-0;
			do start_conversation with: [ to :: list(tempQueens[indexOfSelf-1]), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("You should reference the postition from "+self.name),"Place",self,(startingColumn-1)] ];
			
			}
		
		
		}
    
    aspect base {
    draw circle(size) color: color ;
    }
    
    	int getPositionInGrid(int row,int column)
    {
    	
			int tempCounter<-0;
			int position<-0;
				
				loop rowObject from: 0 to: (boardSize-1) { 
					
					loop columnObject from: 0 to: (boardSize-1) {

						if(row=rowObject and column=columnObject)
						{
							position<-tempCounter;
						}
							
						tempCounter<-tempCounter+1;
						//write "indexcounterL: "+indexCounterL;						
					} 
				} 
    	return (position);
    }
    
    
        bool returnQueenPlacedSuccessfullFlag(int columnToConsider)
    {

        if (columnToConsider >= boardSize) {
            return true;
        }
        	
        	//resetting the board and clearing out the current position
        	if(placedForTheFirstTime)
        	{
        		chessBoard[lastRowOnWhichQueenWasPlaced][columnToConsider] <- 0;  
        	}
        	
        		//Queen is placed on the last row already , cant move from here!!!!
        	if(placedForTheFirstTime and lastRowOnWhichQueenWasPlaced=(boardSize-1))
        	{
        		return false;
        	}
			
			loop rowIteratorObject from: (!placedForTheFirstTime ? lastRowOnWhichQueenWasPlaced : lastRowOnWhichQueenWasPlaced+1) to: (boardSize-1) {
				
				
				if(rowIteratorObject<boardSize)
				{
				write "Try to place queen:"+self.name+"in: row:"+rowIteratorObject+"column:"+columnToConsider;
				
	            if (validateNeighbourAttacks( rowIteratorObject, columnToConsider)) {
	           	 chessBoard[rowIteratorObject][columnToConsider] <- 1;  
	           	 int positionToPlace <- getPositionInGrid(rowIteratorObject,columnToConsider);
	           	 write "The safe position is: "+positionToPlace;
	           	 location<-point(listOfCells[positionToPlace]);
	           	 lastRowOnWhichQueenWasPlaced<-rowIteratorObject;
	           	 placedForTheFirstTime<-true;
	           	 return true;                                   
	            }
	            
	            }
				
			} 
        return false;                                              
    }
    
    
    
 bool validateNeighbourAttacks(int inputRow, int inputColumn)
    {
        int rowIterator;
      
		loop rowIterator from: 0 to: (inputColumn-1) {
			
			if(rowIterator>=0)
			{
            if (chessBoard[inputRow][rowIterator] = 1) {
                return false;
            }
            
            }
		}

		int tempColumn<-inputColumn;
		int tempRow<-(inputRow-1);
		if(tempRow>=0)
		{
		loop rowIterator from: tempRow to: 0 step: (-1) { 
			tempColumn<-tempColumn-1;
			
			if(tempColumn>=0 and rowIterator>=0)
			{
			
	     	if (chessBoard[rowIterator][tempColumn] = 1) {
                return false;
            }
            
            }
            else{
            	break;
            }
		}
		}
			
 		 	tempColumn<-inputColumn;
			loop rowIterator from: (inputRow+1) to: (boardSize-1) step: (1) { 
			tempColumn<-tempColumn-1;
			
			if(tempColumn>=0)
			{
			
	     	if (chessBoard[rowIterator][tempColumn] = 1) {
                return false;
            }
            
            }
            else{
            	break;
            }
		}
 		   
        return true;
    }
      
        
        reflex cellColors 	{
        	
        	int cellCounter<-1;
        	int cellTimes <- 1;
        	rgb startColor <- rgb(int(255 ), 255, int(255));
        	rgb secondColor <- rgb(int(200 ), 200, int(200));
        	
        	
        	//list<board_cell> listcells <- list(board_cell);
        	
        	int index<-0;
        	loop a_temp_var over: listOfCells { 
			if(index=0)
			{
				listOfCells[index].color <- rgb(int(255 ), 255, int(255));
			}
			
			else{
			

				
			int checkMod <- index mod 2;
			
			if(checkMod=0)
			{
				listOfCells[index].color <- startColor;
				
			}
			else{
				listOfCells[index].color <- secondColor;
			}
				
			}
			
			index<-index+1;
			
			cellCounter<-cellCounter+1;
			//write "cellCounter:"+cellCounter+"index: "+index;
			if(cellCounter>(boardSize))
			{
				int checkTimes <- cellTimes mod 2;
				if(checkTimes=0)
			{
				startColor <- rgb(int(255 ), 255, int(255));
	        	secondColor <- rgb(int(200 ), 200, int(200));
				
			}
			else{
				secondColor <- rgb(int(255 ), 255, int(255));
	        	startColor <- rgb(int(200 ), 200, int(200));
				
			}
			cellCounter<-1;
			checkTimes<-0;
			cellTimes<-cellTimes+1;
			}	

			
			}

        	
        }
    
}

grid board_cell width: (boardSize) height: (boardSize) {
    rgb color <- rgb(int(255 ), 255, int(255)) ;
}

experiment run_simulation type: gui {
    output {
    display main_display {
        grid board_cell lines: #black ;
        species queen aspect: base ;
    }
    }
}
