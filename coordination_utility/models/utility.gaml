
model Task2LeaderElection

/*
 
 */

global {
	
	int globalDelayTime <- 50; 
	int numberOfParticipants <- 20;
	int circleDistance <- 8; 
	list<list> participantsDecidedToJoin <- [[],[],[],[],[],[]];
			
	
	
	
	init {		
		
		create FestivalGuest number: numberOfParticipants;
	
				
		create Stage number: 1
		{
		location <- {50,50,0};
		participantListIndex <- 0;
		//light shows, visuals, music type, space, food, drinks
		bandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		}
		
		create Stage number: 1
		{
		location <- {10,10,0};
		participantListIndex <- 1;
		bandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
		
		create Stage number: 1
		{
		location <- {80,80,0};
		participantListIndex <- 2;
		bandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
		
		create Stage number: 1
		{
		location <- {40,80,0};
		participantListIndex <- 3;
		bandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
	}
}

species Stage skills: [fipa] {
	bool stageResetFlag <- false;
	list<float> bandAttributes;
	bool sentFirstCommunication <- false;
	bool sentSecondCommunication <- false;
	
	int delayStart;
	
	int localDelayTimeBand <- rnd(50,150);
	
	int delayStartBandPlay;
	bool delaybandOK<-true;
	
	
	bool delayOK <- true;
	bool isStageActive <- false;
	

	
	int participantListIndex;	
	
		reflex receive_cfp_when_playing when: !empty(cfps) {
		if (isStageActive)
		{
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		do start_conversation with: [ to :: list(agent(proposalFromInitiator.sender)), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Concert is being conducted at: "+self.name),bandAttributes,self,participantListIndex,"START"] ];
		
		}
	}
	
		
	reflex resetAttributes when: stageResetFlag 
	{
		delayOK <- false;
		sentFirstCommunication <- false;
		sentSecondCommunication <- false;
		stageResetFlag <- false;
		delayStart <- time;	
		participantsDecidedToJoin[participantListIndex] <- [];
		isStageActive <- false;		
		bandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		localDelayTimeBand <- rnd(50,150);
		
	}
	
	reflex countDelay when: !delayOK 
	{
		if((time-delayStart)>globalDelayTime)
		{
			delayOK<-true;
		}
			
	}
	
		reflex countDelayBand when: !delaybandOK 
	{
		if((time-delayStartBandPlay)>localDelayTimeBand)
		{
			delaybandOK<-true;
			write "Sending concert end info to participants:";
			if (length(participantsDecidedToJoin[participantListIndex])>0)
			{
			do start_conversation with: [ to :: participantsDecidedToJoin[participantListIndex], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("The concert has ended , bye everyone: "+self.name),bandAttributes,self,participantListIndex,"END"] ];
			
			}
			isStageActive<-false;
			stageResetFlag<-true;
		}
			
	}
	
	
		
	reflex send_info_to_possible_participants when: !sentSecondCommunication and !sentFirstCommunication and delayOK {
		
		write "These are the attributes we offer "+self.name+"   bandAttributes: "+bandAttributes;
		
		isStageActive <- true;
		list notBusyParticipants <- (list(FestivalGuest));
		if(length(notBusyParticipants)>0)
		{
		
		do start_conversation with: [ to :: notBusyParticipants, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Concert is being conducted at: "+self.name),bandAttributes,self,participantListIndex,"START"] ];
		sentFirstCommunication <- true;
		
		}
		
		delayOK <- false;
		delayStartBandPlay <- time;
		delaybandOK<-false;
		
	}
	
	aspect base {
		draw circle((circleDistance)#m) color: #lightblue depth:1;
		draw circle(1) color: (isStageActive) ? #purple : #red depth:4;
	}
}

species FestivalGuest skills: [fipa,moving] {
	
	bool busy <- false;
	bool gotFirstProposal <- false;
	bool goingToStageFlag <- false;
	list<float> utilityValuesList <- [(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10)];
	bool leaderElection <- false;
	bool isNormalParticipant<-false;
	bool isLeader<-false;
	bool initiator<-false;
	bool isCrowdSensititive <- flip(0.2);
	int crowdMassValue <- int(rnd(1, numberOfParticipants));
	
	agent leaderagent;
	
	agent currentStage;
	
	
	float currentBestUtility <- 0.0;
	
	int participantListIndex;
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	point targetPoint <- nil;
	
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
		
		
		int highest <- max(voteslist); 
		int sendIndex <- voteslist index_of highest; 
		
		write "Winner is"+sendIndex+"with votes: "+voteslist[sendIndex];
		
		
		do start_conversation with: [ to :: list(festivalguests), protocol :: 'fipa-contract-net', performative :: 'subscribe', contents :: [sendIndex] ];
	}
	
	
	bool send_once<-false;
	reflex sendLeaderElectionToOthers when: !empty(failures) and !(send_once) {
		send_once<-true;
		write name+"sends leader election";
		list<agent> festivalguests <- list(FestivalGuest);
		
		do start_conversation with: [ to :: list(festivalguests), protocol :: 'fipa-contract-net', performative :: 'query', contents :: ["STARTELECTION"] ];
	}
	
		reflex receiveFinalVote when: !empty(subscribes) {
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
				isNormalParticipant<-true;	
			}
		}
		
		
	}
	
		bool voteOnce<-false;
		reflex agentVote when: !empty(queries) and !voteOnce {
			
		voteOnce<-true;
		 	
		list<agent> festivalguests <- list(FestivalGuest);	
		
		int vote <- rnd(0,(length(festivalguests)-1));
		write name+"send his vote"+vote;
		
		
	
		do start_conversation with: [ to :: list(festivalguests[0]), protocol :: 'fipa-contract-net', performative :: 'accept_proposal', contents :: [vote] ];
    	
		}
	   			
    reflex beIdle when: !(busy) and !leaderElection and !isNormalParticipant {
    	if (!leaderElection and !isNormalParticipant and !isLeader)
    	{
    	leaderElection <- false; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    	if(leaderElection)
    	{
    		write name+"sends leader election";
    		list<agent> festivalguests <- list(FestivalGuest);
    		
    		do start_conversation with: [ to :: list(festivalguests[0]), protocol :: 'fipa-contract-net', performative :: 'failure', contents :: ["START"] ];
    		
    	}
    	}
    	
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil and !isNormalParticipant
	{
		do goto target:targetPoint;
	}
	
	point lastLocation;
		reflex moveToTargetIfSlave when: isNormalParticipant
	{
		FestivalGuest leaderLocal <- FestivalGuest(leaderagent);
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
	
	
	reflex arrivedAtStage when: goingToStageFlag{
			if(distance_to(self,targetPoint)<1){
			write self.name + "At Stage " + currentStage;
			self.targetPoint <- nil;
			self.goingToStageFlag <- false;
			
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

		float calculateUtility <- (stageAttributes[0]*utilityValuesList[0])+(stageAttributes[1]*utilityValuesList[1])+(stageAttributes[2]*utilityValuesList[2])+(stageAttributes[3]*utilityValuesList[3])+(stageAttributes[4]*utilityValuesList[4])+(stageAttributes[5]*utilityValuesList[5]);
		write name+"The calculated utility is "+calculateUtility+" while the previous utility was   : "+currentBestUtility;
		
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
			self.goingToStageFlag <- true;		
			if(isCrowdSensititive){
				if(	length(participantsDecidedToJoin[participantListIndex])>crowdMassValue){
					write '###############'+ self.name + 'Am not going there ,sorry stage' +stage +'has' + length(participantsDecidedToJoin[participantListIndex]) +  'while my limit is ' + crowdMassValue;
					remove self from: list(participantsDecidedToJoin[participantListIndex]);
					self.targetPoint <- self.initPoint;			
			         self.goingToStageFlag <- false;
			         self.currentBestUtility<-0.0;
			         currentStage <- nil;
				}
				
		      }	
		}
		
		}
		
				if(startOrEndMessage="END")
		{
			write name + ' Goes back: ';
			self.targetPoint <- self.initPoint;			
			self.goingToStageFlag <- false;
			self.currentBestUtility<-0.0;
			currentStage <- nil;
			
			
			do start_conversation with: [ to :: list(Stage), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['Is anyone still active m was hoping to join'] ];
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

experiment run_simulation type: gui {

	output {
		display my_display type:opengl {
			species Stage aspect:base;
			species FestivalGuest aspect:base;	
			
			
			}
	}
}