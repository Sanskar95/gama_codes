
model Task2LeaderElection

/*
 
 */

global {
	
	int globalDelayTime <- 50; //time before stage restarts
	int nbOfParticipants <- 20; //people should be 5
	int circleDistance <- 8; 
	list<list> participantsDecidedToJoin <- [[],[],[],[],[],[]];
			
	
	
	
	init {		
		
		create FestivalGuest number: nbOfParticipants;
	
				
		create Stage number: 1
		{
		location <- {50,50,0};
		participantListIndex <- 0;
		//light shows, visuals, music type, space, food, drinks
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		}
		
		create Stage number: 1
		{
		location <- {10,10,0};
		participantListIndex <- 1;
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
		
		create Stage number: 1
		{
		location <- {80,80,0};
		participantListIndex <- 2;
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
		
		create Stage number: 1
		{
		location <- {40,80,0};
		participantListIndex <- 3;
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
	}
}

species Stage skills: [fipa] {
	bool concertHasEnded <- false;
	list<float> BandAttributes;
	bool sent_info <- false;
	bool sent_first <- false;
	
	int delayStart;
	
	int localDelayTimeBand <- rnd(50,150); //time before stage restarts
	
	int delayStartBandPlay; //start counting when sent inform
	bool delaybandOK<-true;
	
	
	bool delayOK <- true;
	bool is_playing <- false;
	

	
	int participantListIndex;	
	
		reflex receive_cfp_when_playing when: !empty(cfps) {
		if (is_playing)
		{
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		do start_conversation with: [ to :: list(agent(proposalFromInitiator.sender)), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Answer: BAND is playing at: "+self.name),BandAttributes,self,participantListIndex,"START"] ];
		
		}
	}
	
		
	reflex resetAttributes when: concertHasEnded 
	{
		delayOK <- false;
		sent_info <- false;
		sent_first <- false;
		concertHasEnded <- false;
		delayStart <- time;	
		participantsDecidedToJoin[participantListIndex] <- [];
		is_playing <- false;		
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		localDelayTimeBand <- rnd(50,150);
		
	}
	
	//Delay for time for setting up the stage for a new band	
	reflex countDelay when: !delayOK 
	{
		if((time-delayStart)>globalDelayTime)
		{
			delayOK<-true;
		}
			
	}
	
	//How long a band will play
		reflex countDelayBand when: !delaybandOK 
	{
		if((time-delayStartBandPlay)>localDelayTimeBand)
		{
			delaybandOK<-true;
			write "SEND END";
			if (length(participantsDecidedToJoin[participantListIndex])>0)
			{
			do start_conversation with: [ to :: participantsDecidedToJoin[participantListIndex], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("END: "+self.name),BandAttributes,self,participantListIndex,"END"] ];
			
			}
			//sent_info<-false;
			is_playing<-false;
			concertHasEnded<-true;
		}
			
	}
	
	
		
	reflex send_info_to_possible_participants when: !sent_first and !sent_info and delayOK {
		
		write "firstSend"+self.name+"BandAttributes:"+BandAttributes;
		
		is_playing <- true;
		list notBusyParticipants <- (list(FestivalGuest));
		if(length(notBusyParticipants)>0)
		{
		
		do start_conversation with: [ to :: notBusyParticipants, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: BAND starts at: "+self.name),BandAttributes,self,participantListIndex,"START"] ];
		sent_info <- true;
		
		}
		
		//DELAY
		delayOK <- false;
		delayStartBandPlay <- time;
		delaybandOK<-false;
		
		
		
		
	}
	

	
	reflex receive_inform_messages when: !empty(informs) {
		write '(Time ' + time + '): ' + name + ' receives inform messages';
		
		loop i over: informs {
			//write '\t' + name + ' receives a inform message from ' + agent(i.sender).name + ' with content ' + i.contents ;
		}
	}
	aspect base {
		draw circle((circleDistance)#m) color: #lightblue depth:1;
		draw circle(1) color: (is_playing) ? #purple : #red depth:4;
	}
}

species FestivalGuest skills: [fipa,moving] {
	
	bool busy <- false;
	bool gotFirstProposal <- false;
	bool goingToStage <- false;
	list<float> utilityValues <- [(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10)];
	bool leaderElection <- false;
	bool isSlave<-false;
	bool isLeader<-false;
	bool initiator<-false;
	bool isCrowdSensititive <- flip(0.2);
	int crowdMassValue <- int(rnd(1, nbOfParticipants));
	
	agent leaderagent;
	
	agent currentStage;
	
	
	float currentBestUtility <- 0.0;
	
	int participantListIndex;
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	
		
	
	point targetPoint <- nil;
	
	//FIRST Agent receive votes             #4
	reflex firstAgentReceiveVotes when: !empty(accept_proposals) {
		write name+"receives vote on indexs";
		list<agent> festivalguests <- list(FestivalGuest);
		list<int> voteslist;
			
		
		loop a_temp_var over: festivalguests { 
			add 0 to: voteslist;
		}
		
		loop i over: accept_proposals {
			write '\t' + name + ' receives vote from ' + agent(i.sender).name + ' with content ' + i.contents ;
			int vote <- int(list(i.contents)[0]);
			voteslist[vote]<-voteslist[vote]+1;
		}
		
		
		int highest <- max(voteslist); // var0 equals 100.0
		int sendIndex <- voteslist index_of highest; // var1 equals 3 
		
		write "Winner is"+sendIndex+"with votes: "+voteslist[sendIndex];
		
		
		do start_conversation with: [ to :: list(festivalguests), protocol :: 'fipa-contract-net', performative :: 'subscribe', contents :: [sendIndex] ];
	}
	
	
	//FIRST Agent initiates election (not real leader)    #2
	bool send_once<-false;
	reflex sendLeaderElectionToOthers when: !empty(failures) and !(send_once) {
		send_once<-true;
		write name+"sends leader election";
		list<agent> festivalguests <- list(FestivalGuest);
		
		do start_conversation with: [ to :: list(festivalguests), protocol :: 'fipa-contract-net', performative :: 'query', contents :: ["STARTELECTION"] ];
	}
	
		//#5
		reflex receiveFinalVote when: !empty(subscribes) {
		//send_once<-true;
		//write name+"sends leader election";
		list<agent> festivalguests <- list(FestivalGuest);
		int selfIndex <- festivalguests index_of self; 
						
			loop i over: subscribes {
			write '\t' + name + ' receives FINAL VOTE FROM ' + agent(i.sender).name + ' with content ' + i.contents ;
			int vote <- int(list(i.contents)[0]);
			
			if(vote=selfIndex)
			{
				isLeader<-true;
			}
			else{
				leaderagent <- festivalguests[vote];
				isSlave<-true;	
			}
		}
		
		
	}
	
	
	
			//# 3
		bool voteOnce<-false;
		reflex agentVote when: !empty(queries) and !voteOnce {
			
		voteOnce<-true;
		 	
		list<agent> festivalguests <- list(FestivalGuest);	
		
		//list<int> votes;
		int vote <- rnd(0,(length(festivalguests)-1));
		write name+"send his vote"+vote;
		
		
		/*loop a_temp_var over: listcells { 
			add 1 to: votes;
		}*/
			
		do start_conversation with: [ to :: list(festivalguests[0]), protocol :: 'fipa-contract-net', performative :: 'accept_proposal', contents :: [vote] ];
    	
		}
	
		
	// #1 
	//SLAVE RANDOMLY initiate leader election	   			
    reflex beIdle when: !(busy) and !leaderElection and !isSlave {
    	if (!leaderElection and !isSlave and !isLeader)
    	{
    	leaderElection <- false; //TO
    	if(leaderElection)
    	{
    		write name+"sends leader election";
    		list<agent> festivalguests <- list(FestivalGuest);
    		
    		do start_conversation with: [ to :: list(festivalguests[0]), protocol :: 'fipa-contract-net', performative :: 'failure', contents :: ["START"] ];
    		
    	}
    	}
    	
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil and !isSlave
	{
		do goto target:targetPoint;
	}
	
	point lastLocation;
		reflex moveToTargetIfSlave when: isSlave
	{
		FestivalGuest leaderLocal <- leaderagent;
		point leaderPoint <- leaderLocal.targetPoint;
		if (leaderPoint != nil)
		{
		lastLocation <- leaderLocal.targetPoint;
		do goto target:leaderPoint;
		}
		else{
			do goto target:lastLocation;
			
		}
	}
	
	
	//to remove TargetPoint
	reflex arrivedAtStage when: goingToStage{
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At Stage " + currentStage;
			self.targetPoint <- nil;
			self.goingToStage <- false;
			
			}
		}
		
	reflex goBackToInitPoint when: distance_to(self,initPoint)<1 and busy{
			if(targetPoint=initPoint){
			write self.name + "At InitPoint";
			self.targetPoint <- nil;
			self.busy <- false;
			
			}
		}
	
	
	
		reflex receive_startInfo_from_Stage when: !empty(informs) {
		message informFromStage <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromStage.sender).name + ' with content ' + informFromStage.contents;
		
		agent stage <-list(informFromStage.contents)[2];
		currentStage<- stage;
		list<float> stageAttributes <- list(informFromStage.contents)[1];
		int localparticipantListIndex <- int(list(informFromStage.contents)[3]);
		string startOrEndMessage <-list( informFromStage.contents)[4];
		
		if(startOrEndMessage="START")
		{

		float calculateUtility <- (stageAttributes[0]*utilityValues[0])+(stageAttributes[1]*utilityValues[1])+(stageAttributes[2]*utilityValues[2])+(stageAttributes[3]*utilityValues[3])+(stageAttributes[4]*utilityValues[4])+(stageAttributes[5]*utilityValues[5]);
		write name+"calculates utility with"+calculateUtility+"current utility: "+currentBestUtility;
		
		if(self.currentBestUtility<calculateUtility)
		{
			self.currentBestUtility<-calculateUtility;
			if(self.busy)
			{
				remove self from: list(participantsDecidedToJoin[participantListIndex]);
			}
			participantListIndex<-localparticipantListIndex;
			self.busy <- true;	
			write name + ' decides to join stage at: ' + agent(informFromStage.sender).name+"loc:";
			add self to: participantsDecidedToJoin[participantListIndex];
			self.targetPoint <- any_location_in(stage);
			self.targetPoint <- {(targetPoint.x-rnd(1,circleDistance/2)),(targetPoint.y-rnd(circleDistance/2)),targetPoint.z};
			self.goingToStage <- true;		
			if(isCrowdSensititive){
				if(	length(participantsDecidedToJoin[participantListIndex])-1>crowdMassValue){
					write '###################'+ self.name + 'Am not going there ,sorry stage' +stage +'has' + length(participantsDecidedToJoin[participantListIndex]) +  'while my limit is ' + crowdMassValue;
					remove self from: list(participantsDecidedToJoin[participantListIndex]);
					self.targetPoint <- self.initPoint;			
			         self.goingToStage <- false;
			         self.currentBestUtility<-0.0;
			         currentStage <- nil;
				}
				
		      }	
		}
		
		}
		
				if(startOrEndMessage="END")
		{
			write name + ' Goes home: ';
			self.targetPoint <- self.initPoint;			
			self.goingToStage <- false;
			self.currentBestUtility<-0.0;
			currentStage <- nil;
			
			//Check if someone is playing
			do start_conversation with: [ to :: list(Stage), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['Are you playing? Send attributes'] ];
			
			
		}
		
		
			
			
		}
		
	
	aspect base {
		if(isCrowdSensititive){
			draw square(2) color: (busy and self.targetPoint!=self.initPoint) ? ( (participantListIndex=0) ? #black : ((participantListIndex=1) ? #grey : ( (participantListIndex=2) ? #green : #yellow) ) ) :  #blue depth:1;
			
		}else {
			draw circle(1) color: (busy and self.targetPoint!=self.initPoint) ? ( (participantListIndex=0) ? #black : ((participantListIndex=1) ? #grey : ( (participantListIndex=2) ? #green : #yellow) ) ) :  #blue depth:1;
			
		}
			
		
	}
	
}

experiment test type: gui {

	output {
		display my_display type:opengl {
			species Stage aspect:base;
			species FestivalGuest aspect:base;	
			
			
			}
	}
}