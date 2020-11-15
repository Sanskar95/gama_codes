
model BaseAssignment

/*
 * https://github.com/gama-platform/gama/wiki/FIPA-Skill-FIPA-CFP-(2)
 */

global {
	
	int interAuctionMockDelay <- 70;
	int numberOfParticipants <- 5; 
	int circleDistance <- 8; 
	int auctionRange <- 100;
	list<participant> participantsJoiningAuction;
	list<participant> participantsArrivedAtAuction;
	participant informedParticipant;
	list<participant> resultInformedParticipants;
	list<participant> refusers<-[];
	
	
	init {		
		create initiator number: 1
		{
		location <- {20,20,0};
		itemType <- 'Clothes';
		}
		create participant number: numberOfParticipants returns: ps;
	}
}

species initiator skills: [fipa] {
	
	int initialBid <- rnd(500,5000);
	int minimumBid <- rnd(10,(initialBid/4));
	bool foundWinner <- false;
	string itemType;
	bool sentFirstCommunication <- false;
	bool sentSecondCommunication <- false;
	
	int delayStart;
	bool delayFlag <- true;
	bool foundMinBid <- false;
	
		
	reflex resetAttributes when: foundWinner 
	{
		initialBid <- rnd(500,5000);
		sentFirstCommunication <- false;
		sentSecondCommunication <- false;
		minimumBid <- rnd(10,(initialBid/4));
		foundWinner <- false;
		resultInformedParticipants <-[];
		informedParticipant <- nil;
		delayFlag <- false;
		delayStart <- time;	
		participantsJoiningAuction <- [];
		participantsArrivedAtAuction <- [];
		refusers <- [];
		
	}
	
		
	reflex includeMockDelay when: !delayFlag 
	{
		if((time-delayStart)>interAuctionMockDelay)
		{
			delayFlag<-true;
		}
			
	}
		
	reflex broadcastFirstCommunication when: !sentSecondCommunication and !sentFirstCommunication and delayFlag {
		
		
		write '(Time ' + time + '): ' + name + ' sending an inform message to all participants';

		do start_conversation with: [ to :: list(participant), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: Auction starts at: "+self.name),itemType,self] ];
		sentFirstCommunication <- true;
		
	}
	
	reflex broadcastCallForProposals when: !sentSecondCommunication and sentFirstCommunication and length(participantsJoiningAuction)>0 and length(participantsJoiningAuction)=length(participantsArrivedAtAuction) {
		
		sentSecondCommunication <- true;
		
		if (initialBid<minimumBid)
		{
		write '(Time ' + time + '): ' + name + ' Minimum bid: '+minimumBid+'Auction comes to an end $$$$$$$$$$$$$$$$$, now buzz off';
		do start_conversation with: [ to :: participantsJoiningAuction, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: ENDS: "+self.name),"Ends",self] ];
		foundWinner <- true;
		sentFirstCommunication <- false;
		}
		else{
		write '(Time ' + time + '): ' + name + ' sending call for proposal  messages to all participants';
		do start_conversation with: [ to :: participantsJoiningAuction, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemType,initialBid] ];
	}
	}
	
	reflex recieveRefuseMessages when: !empty(refuses) {
		write '(Time ' + time + '): ' + name + ' receives refuse messages from participants';
		loop r over: refuses {
			write '\t' + name + 'receives a refuse message from ' + agent(r.sender).name + ' with content ' + r.contents ;
			add r.sender to:refusers;
		}
		
		// when everyone refuses its time to decrease the price similar to bargain
		if(length(refusers)=length(participantsJoiningAuction))  
		{
			write "Reducing bid and starting the next round";
			initialBid<-initialBid-rnd(1,initialBid/2);
			refusers<-[];
			if (initialBid<minimumBid)
			{
			write '(Time ' + time + '): ' + name + ' Minimum bid: '+minimumBid+'Auction comes to an end $$$$$$$$$$$$$$$$$, now buzz off';
			do start_conversation with: [ to :: participantsJoiningAuction, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: ENDS: "+self.name),"Ends",self] ];
			foundWinner <- true;
			sentFirstCommunication <- false;
			}
			else
			{
			do start_conversation with: [ to :: participantsJoiningAuction, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [itemType,initialBid] ];	
			}
			
		}
		
		
	}
	
	reflex recieveProposeMessages when: !empty(proposes) {
		write '(Time ' + time + '): ' + name + ' receives propose messages';
		
		loop p over: proposes {
		
			write '\t' + name + ' receives a propose message from ' + agent(p.sender).name + ' with content ' + p.contents ;
			
			if (foundWinner) { //If already found winner. Reject
			
//				add p to: informedParticipants;
				write '\t' + name + ' sending reject_proposal message to ' + p.sender;
				do reject_proposal with: [ message :: p, contents :: ['Wont be able to proceed, already sold'] ];
							
			} else { //First winner
//				 inform_result_participant<-p;
				write '\t' + name + ' sending  accept_proposal message to ' + p.sender;
				do accept_proposal with: [ message :: p, contents :: ['The price looks good , lets proceed'] ];
								
				//Signal auction ended
				remove p.sender from: participantsJoiningAuction;
				do start_conversation with: [ to :: participantsJoiningAuction, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: ENDS: "+self.name),"Ends",self] ];
				foundWinner <- true;
				
			}
		}
	}
	
	reflex recieveFailureMessages when: !empty(failures) {
		message f <- failures[0];
		write '\t' + name + ' receives a failure message from ' + agent(f.sender).name + ' with content ' + f.contents ;
	}
	
	reflex recieveInformMessagesFromParticipants when: !empty(informs) {
		write '(Time ' + time + '): ' + name + ' receives inform messages';
		
		loop i over: informs {
			write '\t' + name + ' receives a inform message from ' + agent(i.sender).name + ' with content ' + i.contents ;
		}
	}
	aspect base {
		draw circle((circleDistance)#m) color: #mediumspringgreen depth:1;
		draw pyramid(3) color: #midnightblue depth:4;
	}
}

species participant skills: [fipa,moving] {
	
	//random value of half of the first initiatior.
	bool setBiddingPrice <- false;
	int maxPrice <- 0;
	bool isNotIdle <- false;
	bool gotFirstProposal <- false;
	bool goingToAuction <- false;
	bool setInterestItem <- false;
	int firstProposal;
	string interestItem <- "Clothes";
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	point targetPoint <- nil;
	
	
/* 	reflex setInterestitem when: !(set_interestitem) {
		do wander;
	}*/
	
	
	    
    reflex beIdle when: !(isNotIdle) {
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
			add self to: participantsArrivedAtAuction;
			self.goingToAuction <- false;
			
			}
		}
		
	reflex goBackToInitPoint when: distance_to(self,initPoint)<1 and isNotIdle{
			if(targetPoint=initPoint){
			write self.name + "At InitPoint";
			self.targetPoint <- nil;
			self.isNotIdle <- false;
			
			}
		}
	
		reflex recieveInitialInformationFromInitiator when: !empty(informs) and !isNotIdle {
		message informFromInitiator <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromInitiator.sender).name + ' with content ' + informFromInitiator.contents;
		
		agent auctioneer <- list(informFromInitiator.contents)[2];
		string auctionItem <- list(informFromInitiator.contents)[1];
		

		
		if (distance_to(self,auctioneer)<=auctionRange and auctionItem=interestItem)
		{	
			write name + ' decides to join auction at: ' + agent(informFromInitiator.sender).name+"loc:";
			add self to: participantsJoiningAuction;
			self.isNotIdle <- true;	
			self.targetPoint <- any_location_in(auctioneer);
			self.targetPoint <- {(targetPoint.x-rnd(1,circleDistance/2)),(targetPoint.y-rnd(circleDistance/2)),targetPoint.z};
			self.goingToAuction <- true;
		}
			
			
		}
		
		//receive end INFO
		reflex recieveOtherInformationFromInitiatorWhenNotIdle when: !empty(informs) and isNotIdle{

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
		
		
		
		reflex recieveCallForProposalFromInitiator when: !empty(cfps) and isNotIdle {
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives call for proposal  message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		
		firstProposal <- int(list(proposalFromInitiator.contents)[1]);
		
		if(!setBiddingPrice)
		{
		maxPrice <- (rnd(0,(firstProposal)/2));
		setBiddingPrice <- true;
		}
		
		write '(Time ' + time + '): ' + name + ' i will accept' +self.maxPrice;
			
		if (self.maxPrice >= firstProposal) {
			write '\t' + name + ' sends a propose message to ' + agent(proposalFromInitiator.sender).name;
			do propose with: [ message :: proposalFromInitiator, contents :: ['I will buy for that price'] ];
		}
		
		else  {
			write '\t' + name + ' sends a refuse message to ' + agent(proposalFromInitiator.sender).name;
			do refuse with: [ message :: proposalFromInitiator, contents :: ['I will not buy'] ];
		}
	}
	
	reflex recieveRejectProposals when: !empty(reject_proposals) {
		message r <- reject_proposals[0];
		write '(Time ' + time + '): ' + name + ' receives a reject_proposal message from ' + agent(r.sender).name + ' with content ' + r.contents;
	}
	
	reflex recieveAcceptProposals when: !empty(accept_proposals) {
		message a <- accept_proposals[0];
		write '(Time ' + time + '): ' + name + 'receives a accept_proposal message from ' + agent(a.sender).name + ' with content ' + a.contents;
		self.targetPoint <- self.initPoint;			
				
		//Winning
		if (self = informedParticipant) {
			write '\t' + name + ' sends an inform_done message to ' + agent(a.sender).name;
			do inform with: [ message :: a, contents :: ['Inform done'] ];
			self.targetPoint <- self.initPoint;			
		}
		
		//Loosing
		list results <- resultInformedParticipants;	
		if (results contains_key self) {
			write '\t' + name + ' sends an inform_result message to ' + agent(a.sender).name;
			do inform with: [ message :: a, contents :: ['Inform result'] ];
			self.targetPoint <- self.initPoint;			
		}
	}
	
	aspect base {
		draw circle(1) color: #green depth:1;
	}
	
}

experiment runAuction type: gui {
	output {
		display my_display type:opengl {
			species initiator aspect:base;
			species participant aspect:base;	
			
			
			}
	}
}