
model cfp_cfp_3


global {
	int numberOfParticipants <- 5;
	int numOfRefusers <-0;
	int circleDistance <- 8;
	int globalDelayTime <- 80; 
	
	int number_of_people <- 10;
	int nbOfinitiators <- 1;
	
	
	list<participant> participantsDecidedToJoin;
	list<participant> participantsDecidedToJoinHasArrived;
	
	
	
	int distanceToAuction <- 100;
	
	init {
				
		create initiator number: nbOfinitiators// returns: ps
		{
		location <- {50,50,0};
		}
		create participant number: numberOfParticipants returns: ps;
		
	}
}

species initiator skills: [fipa] {
	
	int startBid <- rnd(1000,5000,100);
	bool foundWinner <- false;
	string ItemType <- 'Clothes';
	bool itemsold <- false;
	bool sentSecondCommunication <- false;
	bool sentFirstCommunication <- false;
	int sort <-0;
	int delayStart;
	bool delayOK <- true;
	bool flag<-false;
	string first_best <-"";
	string second_best <-"";
	float temp1 <-0.0;
	float temp2 <-0.0;
	
	reflex resetAttributes when: itemsold 
	{
		startBid <- rnd(1000,5000,100);
	foundWinner <- false;
	 ItemType <- 'Clothes';
	itemsold <- false;
	 sentSecondCommunication <- false;
	 sentFirstCommunication <- false;
	 sort <-0;
	delayStart <- time;
	 delayOK <- false;
	 flag<-false;
	 first_best <-"";
	 second_best <-"";
	 temp1 <-0.0;
	temp2 <-0.0;
	participantsDecidedToJoin <- [];
	participantsDecidedToJoinHasArrived <- [];
	}
		
 	reflex countDelay when: !delayOK 
	{
		if((time-delayStart)>globalDelayTime)
		{
			delayOK<-true;
		}
			
	}
		
	reflex sendInfoToParticipants when: !sentFirstCommunication and !sentSecondCommunication and delayOK {
	
	
		write '(Time ' + time + '): ' + name + ' sends a inform message to all participants';
				
		do start_conversation with: [ to :: list(participant), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: Auction starts at: "+self.name),ItemType,self] ];
		sentSecondCommunication <- true;
			
	}
				
	reflex sendCallForProposals when: !sentFirstCommunication and sentSecondCommunication and length(participantsDecidedToJoin)>0 and length(participantsDecidedToJoin)=length(participantsDecidedToJoinHasArrived) {
		
		sentFirstCommunication <- true;
		
		write '(Time ' + time + '): ' + name + ' sends a cfp message to all participants';
		do start_conversation with: [ to :: list(participantsDecidedToJoin), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [ItemType,startBid] ];
	}


	reflex recieveProposeMessages when: !empty(proposes)  {
	float x <- 0.0;
	
	int i <-0;
	write '(Time ' + time + '): ' + name + ' receives propose messages';
		loop p over: proposes {
			
			write '\t' + name + ' receives a propose message from ' + agent(p.sender).name + ' with content ' + list(p.contents)[0] + " "+ list(p.contents)[1];
			 x <- float(list(p.contents)[1]);
			
			if(x>temp1){
			temp2 <-temp1+0.1;
		 	temp1<-x;
		 	first_best <-agent(p.sender).name;
		 }
			 else if(x>temp2 and x<temp1){
	     	temp2 <- x + 0.1;
	     	second_best <-agent(p.sender).name;
	     }
			  remove p.sender from: list(participantsDecidedToJoin);
		}
	   
	    do start_conversation with: [ to :: list(participant), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Item sold to "+first_best+" for second best price, bidded by "+second_best+" for "+temp2+". The actual bidded price by "+first_best+" is "+temp1),"Ends",self] ];
	  itemsold<-true;
	}
	
	aspect base {
		draw circle((circleDistance)#m) color: #lightblue depth:1;
		draw circle(1) color: #red depth:4;
	}
}

species participant skills: [fipa,moving] {
	
	//random value of half of the first initiatior.
	bool sat_bid_price <- false;
	bool sat_bid_neg <- false;
	int maxPrice <- 0;
	int i_have <-0;
	bool busy <- false;
	bool gotFirstProposal <- false;
	bool goingToAuction <- false;
	int firstProposal;
	string interestItem <- "Clothes";
	int participantListIndex;
	int mymax <-0;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	bool snack<-false;
	point targetPoint <- nil;
	
	

    reflex beIdle when: !(busy) {
    	
		do wander;
	 
		}
		
	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	reflex arrivedAtAuction when: goingToAuction{
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At Auction";
			self.targetPoint <- nil;
			add self to: participantsDecidedToJoinHasArrived;
			self.goingToAuction <- false;
			
			}
		}
		
	reflex goBackToInitPoint when: distance_to(self,initPoint)<1 and busy{
			if(targetPoint=initPoint){
			write self.name + "At InitPoint";
			self.targetPoint <- nil;
			self.busy <- false;
			
			}
		}
		reflex recieveStartInfoFromInitiator when: !empty(informs) and !busy  {
		message informFromInitiator <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromInitiator.sender).name + ' with content ' + informFromInitiator.contents;
		
		agent auctioneer <- list(informFromInitiator.contents)[2];
		string auctionItem <- list(informFromInitiator.contents)[1];
        
		
		if (distance_to(self,auctioneer)<=distanceToAuction and auctionItem=interestItem)
		{
			write name + ' decides to join auction at: ' + agent(informFromInitiator.sender).name+"loc:";
			add self to: participantsDecidedToJoin;
			self.busy <- true;	
			self.targetPoint <- any_location_in(auctioneer);
			self.targetPoint <- {(targetPoint.x-rnd(1,circleDistance/2)),(targetPoint.y-rnd(circleDistance/2)),targetPoint.z};
			self.goingToAuction <- true;
		}	
		}
		
		
		reflex recieveOtherInfoFromInitiator when: !empty(informs) and busy{

		message informFromInitiator <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromInitiator.sender).name + ' with content ' + informFromInitiator.contents;
		
		agent auctioneer <- list(informFromInitiator.contents)[2];
		string infoText <- list(informFromInitiator.contents)[1];

		if (infoText="Ends")
		{
			write name + ' Goes home: ';
			self.targetPoint <- self.initPoint;			
			self.goingToAuction <- false;
		}	
			
		}
			
		reflex recieveCallForProposals when: !empty(cfps) and busy {
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		firstProposal <- int(list(proposalFromInitiator.contents)[1]);
		
		if(!sat_bid_price)
		{
		
		maxPrice <- rnd(firstProposal, 10000, 100);
	    
     	sat_bid_price <- true;
		}
	
			write '\t' + name + ' sends a propose message to ' + agent(proposalFromInitiator.sender).name +self.maxPrice;
			do propose with: [ message :: proposalFromInitiator, contents :: ['I will buy '+self.interestItem+' for -',self.maxPrice, self.name] ];
	
	}
	
	aspect base {
		draw circle(1) color: #blue depth:1;
	}
	
}

experiment runVickeryAuction type: gui {
	parameter "Total People in Aution" var: number_of_people;
	parameter "Initiators" var: nbOfinitiators;
	output {
		display my_display type:opengl {
			species initiator aspect:base;
			species participant aspect:base;	
			}
	}
}
