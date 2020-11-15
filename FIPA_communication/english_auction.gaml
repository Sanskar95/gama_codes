
model cfp_cfp_2

/*
 Silent auction
 The person who wins. Sell for a higher price?
 */

global {
	int numberOfParticipants <- 5;
	int refusingPrice <-0;
	int circleDistance <- 8;
	int globalDelayTime <- 100; 
	
	int number_of_people <- 10;
	int numberOfInitiators <- 1;
	
	
	list<participant> participantsDecidedToJoin;
	list<participant> participantsDecidedToJoinHasArrived;
	
	
	int distanceToAuction <- 100;
	
	init {
				
		create initiator number: numberOfInitiators
		{
		location <- {50,50,0};
		}
		create participant number: numberOfParticipants returns: ps;
		
		
	}
}

species initiator skills: [fipa] {
	
	int startingBid <- rnd(50000,100000,50000);
	string itemType <- 'Antilia';
	bool isSold <- false;
	bool sentSecondCommunication <- false;
	bool sentFirstCommnunication <- false;
	int delayStart;
	bool delayFlag <- true;
	
	int participantListIndex <- 0;	
	
		
	reflex resetAttributes when: isSold 
	{
		startingBid <- rnd(50000,150000, 50000);
		sentSecondCommunication <- false;
		sentFirstCommnunication <- false;
		isSold <- false;
		delayFlag <- false;
		delayStart <- time;	
		participantsDecidedToJoin <- [];
		participantsDecidedToJoinHasArrived <- [];
		refusingPrice<-0;
	}
	
		
	reflex countDelay when: !delayFlag 
	{
		if((time-delayStart)>globalDelayTime)
		{
			delayFlag<-true;
		}
			
	}
		
	reflex broadcastInfoToAllParticipants when: !sentFirstCommnunication and !sentSecondCommunication and delayFlag {
	
	
		write '(Time ' + time + '): ' + name + 'sending inform message to all participants';
				
		do start_conversation with: [ to :: list(participant), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform:English  Auction starts at: "+self.name),itemType,self] ];
		sentSecondCommunication <- true;
		
		
	}
	
				
	reflex broadcastCallForProposalsToParticiapants when: !sentFirstCommnunication and sentSecondCommunication and length(participantsDecidedToJoin)>0 and length(participantsDecidedToJoin)=length(participantsDecidedToJoinHasArrived) {
		
		sentFirstCommnunication <- true;
		
		write '(Time ' + time + '): ' + name + ' sending call for proposal message to all participants';
		do start_conversation with: [ to :: participantsDecidedToJoin, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemType,startingBid] ];
	}
	
	
	
	reflex recieveRefuseMessages when: !empty(refuses)  {
		int dynamicPrice <-0;
		string dynamicWinner;
		loop r over: refuses {
		
		remove r.sender from: list(participantsDecidedToJoin);
		write '\t' + name + ' receives a refuse message from ' + agent(r.sender).name + ' with content ' + list(r.contents)[0]+list(r.contents)[1];
	    refusingPrice<- int(list(r.contents)[1]);
	   
	   if(refusingPrice > dynamicPrice){
				dynamicPrice <- refusingPrice;  
				dynamicWinner <- agent(r.sender).name;
			}
	}
    if(length(participantsDecidedToJoin)=1){
		write '\t' +"House is being sold to" + participantsDecidedToJoin[0];
		isSold <- true;
		do start_conversation with: [ to :: list(participant), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: ENDS: "+self.name),"Ends",self] ];
	}
 		if(length(participantsDecidedToJoin)=0){
		write '\t' +"House is being  sold to"+" "+dynamicWinner+" "+"for"+" "+dynamicPrice;
		isSold <- true;
		do start_conversation with: [ to :: list(participant), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: ENDS: "+self.name),"Ends",self] ];
	}
	
	}
	
	
	
	reflex recieveProposeMessages when: !empty(proposes) {
		
		if(!isSold){
		write '(Time ' + time + '): ' + name + ' receives propose messages';
	 	int participantPrice <-0;
		int maximumParticipantPrice <-0;
		int restartMetric <-0;
		loop p over: proposes {
		write '\t' + name + ' receives a propose message from ' + agent(p.sender).name + ' with content ' + list(p.contents)[0] + " "+ list(p.contents)[1];
		   
		participantPrice <- int(list(p.contents)[1]);
			restartMetric<-restartMetric+1;
			if(participantPrice > maximumParticipantPrice){
				maximumParticipantPrice <- participantPrice;	
			}
	
		}
		
		if(restartMetric!=1){
			write "Bidding restarts at"+" "+ maximumParticipantPrice;
		    do start_conversation with: [ to :: list(participantsDecidedToJoin), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemType,maximumParticipantPrice] ];
		}
		
	}
	}
	 	
	
	aspect base {
		draw circle((circleDistance)#m) color: #lightblue depth:1;
		draw circle(1) color: #red depth:4;
	}
}

species participant skills: [fipa,moving] {
	
	bool setbiddingPrice <- false;
	bool sat_bid_neg <- false;
	int maximumPrice <- 0;
	int seed <-0;
	bool isNotIdle <- false;
	bool gotFirstProposalFlag <- false;
	bool goingToAuctionFlag <- false;
	int firstProposal;
	string interestItem <- "Antilia";
	int currentMaximumPrice <-0;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	point targetPoint <- nil;

    reflex beIdle when: !(isNotIdle) {
    	
		do wander;
	 
		}
		
	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	reflex arrivedAtAuction when: goingToAuctionFlag{
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At House Auction";
			self.targetPoint <- nil;
			add self to: participantsDecidedToJoinHasArrived;
			self.goingToAuctionFlag <- false;
			
			}
		}
		
	reflex goBackToInitPoint when: distance_to(self,initPoint)<1 and isNotIdle{
			if(targetPoint=initPoint){
			write self.name + "At InitPoint";
			self.targetPoint <- nil;
			self.isNotIdle <- false;
			
			}
		}
		reflex recieveInitialInfoFromInitiator when: !empty(informs) and !isNotIdle {
		 		
		message informFromInitiator <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromInitiator.sender).name + ' with content ' + informFromInitiator.contents;
		
		agent auctioneer <- list(informFromInitiator.contents)[2];
		string auctionItem <- list(informFromInitiator.contents)[1];
		
		
		if (distance_to(self,auctioneer)<=distanceToAuction and auctionItem=interestItem)
		{
			write name + ' decided to join auction at: ' + agent(informFromInitiator.sender).name+"loc:";
			add self to: participantsDecidedToJoin;
			self.isNotIdle <- true;	
			self.targetPoint <- any_location_in(auctioneer);
			self.targetPoint <- {(targetPoint.x-rnd(1,circleDistance/2)),(targetPoint.y-rnd(circleDistance/2)),targetPoint.z};
			self.goingToAuctionFlag <- true;
		}
			
			
		}
		
		//receive end INFO
		reflex recieveSomeOtherInfoWhenBusy when: !empty(informs) and isNotIdle{

		message informFromInitiator <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromInitiator.sender).name + ' with content ' + informFromInitiator.contents;
		
		agent auctioneer <- list(informFromInitiator.contents)[2];
		string infoText <- list(informFromInitiator.contents)[1];

		
		if (infoText="Ends")
		{
			write name + ' Goes back  home: ';
			self.targetPoint <- self.initPoint;			
			self.goingToAuctionFlag <- false;
		}
			
			
		}
			
		reflex recieveCallForProposalsFromInitiator when: !empty(cfps) and isNotIdle  {
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		
		firstProposal <- int(list(proposalFromInitiator.contents)[1]);
		
		
		if(setbiddingPrice){
		maximumPrice <- rnd(firstProposal, seed, 50000);
		} else{
			seed <- rnd(100000,1000000, 50000);
			maximumPrice <- rnd(100000, seed, 50000);
  		 	setbiddingPrice <- true;
		}
		ask participant{
			if(self.maximumPrice = myself.maximumPrice ){
				myself.maximumPrice <- myself.maximumPrice + rnd(myself.seed,1000000 , 50000);              
			   
			}
			}
				
		if (self.maximumPrice >= firstProposal) {
			write '\t' + name + ' sending  a propose message to ' + agent(proposalFromInitiator.sender).name +self.maximumPrice;
			currentMaximumPrice<-self.maximumPrice;
			do propose with: [ message :: proposalFromInitiator, contents :: ['I will buy '+self.interestItem+' for -',self.maximumPrice, self.name] ];
		   
		}
		
	    if(self.maximumPrice < firstProposal) {
			
			do refuse with: [ message :: proposalFromInitiator, contents :: ['The max I can go for this house is', self.currentMaximumPrice] ];
		}
	
	}
	
	aspect base {
		draw circle(1) color: #blue depth:1;
	}
	
}

experiment runEnglishAuction type: gui {
	parameter "Total People in Auction" var: number_of_people;
	parameter "Initiators" var: numberOfInitiators;
	output {
		display my_display type:opengl {
			species initiator aspect:base;
			species participant aspect:base;	
			
			
			}
	}
}