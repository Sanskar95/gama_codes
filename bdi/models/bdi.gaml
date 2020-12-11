
model Task2Utility

/*
 * 
5 types of agents 			(TRAITS)
Rock fan - Dances (generous,acceptdrink,wantstodanceorgotopub,fightwinorloose) -> Pub, Stage - Gunnar
(Bad guy (startafight,fightwinorloose) -> Pub or stage, Journalist, Thief?) - flip chill guy - Gunnar
Thief - takes money (goodorbadthief, howoftenIshouldrobpeople, sharemoneywithbadguyornot,getcaught,) -> Pub or stage Akhil
Chill person - gets annoyed (generous, acceptdrink,wantstodanceorgotopub,fightwinorloose) -> Pub or stage - Gunnar
Journalist - takes photos or ask the agent how are you  -> Stage, pub or Photo area/Police station? - Akhil
Police - (catch bad guy, catch thief,fightwinorloose) -> goes everywhere - Akhil


2 Places
Photo area
Pub
Stage 
Police station
Secret place for thief.
  
Attribute:

Drunk
Happy
Thief loose money.				//ÅTERGÅ TILL PREVIOUS BELIEF
 
 */

global {
	
	int nbOfParticipants <- 20; //people should be 5
	int circleDistance <- 8;	
	int talk_range <- 5; //ask if smaller or equal	
	int globalDelayTime <- 20; //time before agent starts talking
	int wantsToDanceLimit<-50;
	int acceptDrinkLimit<-50;
		
	int sumHappy <- 0 update: sum(((RockFan) collect (each.happy)) + (ChillGuy) collect (each.happy));
	int sumDrunk <- 0 update: sum(((RockFan) collect (each.drunk)) + (ChillGuy) collect (each.drunk));
	
	int ChillGuyWantsToDance <- 0 update: ChillGuy count (each.wantsToDance>wantsToDanceLimit);
	int ChillGuyNotWantToDance <- 0 update: ChillGuy count (each.wantsToDance<=wantsToDanceLimit);
			
	list<list> inform_result_participant <- [[],[],[],[],[],[]];
	list<int> numOfRefusers <- [0,0,0,0,0];
	
	
	
	
	init {		
		
		create RockFan number: 4;
		create ChillGuy number: 4;
		create Thief number: 2;
		create Police number: 2;
		create Journalist number: 2;
		create Gamer number: 4;
		

		
		create PhotoArea number: 1
		{
		location <- {80,10,0};
		}
		
		
		
		create GamingArea number: 1
		{
		location <- {50,80,0};
		}
		
		
				
		create Stage number: 1
		{
		location <- {50,50,0};
		}
		
		create Pub number: 1
		{
		location <- {20,80,0};
		}
		
		create ThiefArea number: 1
		{
		location <- {90,90,0};
		}
		
		create PoliceStation number: 1
		{
		location <- {10,10,0};
		}
	}
}

species PhotoArea{
	
		aspect base {
		draw rectangle(10,5) color: #chocolate depth:5;
	}
	
	
}



species PoliceStation{
	
		aspect base {
		draw rectangle(10,5) color: #blue depth:5;
	}
	
	
}

species GamingArea{
		aspect base {
		draw rectangle(10,5) color: #lime depth:5;
	}	
}


species Pub{
	
		aspect base {
		draw rectangle(10,5) color: #green depth:5;
	}
	
	
}

species ThiefArea{
	
		aspect base {
		draw circle(5) color: #grey depth:5;
	}
	
	
}



species Stage skills: [fipa] {
		
	aspect base {
		draw rectangle(13,5) color: #darkslategrey ;
		
	}
}

species Thief skills: [fipa,moving] {
	
	 
	bool Thief <-false;
	
	bool busy <- false;
	
	
	float currentBestUtility <- 0.0;
	
	int participantListIndex;
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
		
	
	point targetPoint <- nil;
	
		
    reflex beIdle when: !(busy) {
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	

	
	aspect base {
		draw circle(1) color: #grey depth:1;
	}
	
}


species Police skills: [fipa,moving] {
	
	bool Police <-true;
	
	bool busy <- false;
	
	
	float currentBestUtility <- 0.0;
	
	int participantListIndex;
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
		
	
	point targetPoint <- nil;
	
		
    reflex beIdle when: !(busy) {
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	

	
	aspect base {
		draw circle(1) color: #blue depth:1;
	}
	
}


species Journalist skills: [fipa,moving] {
	
	bool Journalist<-true; 
	bool busy <- false;
	
	
	float currentBestUtility <- 0.0;
	
	int participantListIndex;
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
		
	
	point targetPoint <- nil;
	
		
    reflex beIdle when: !(busy) {
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	

	
	aspect base {
		draw circle(1) color: #chocolate depth:1;
	}
	
}

species Gamer skills: [fipa,moving] control:simple_bdi {
	
	
	bool busy <- false;
	bool talking<-false;
	int localDelayTime;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	
	predicate wants_to_do_something <- new_predicate("wants to do something") ;
	predicate wants_to_go_somewhere <- new_predicate("wants to go somewhere") ;
	predicate has_decided_where_to_go <- new_predicate("has decided where to go") ;
	predicate stop_and_have_a_conversation <- new_predicate("stop and have a conversation") ;

	predicate wants_to_play_game <- new_predicate("wants to play game");
	
	string who_to_talk_to <- "who_to_talk_to";
	predicate talk_to_someone <- new_predicate(who_to_talk_to); 
	int acceptdrink <- rnd(1,100);
	bool delayOK<-true;
	int startDelay;
	list<string> answerPub<-["No I don't want a drink?","Yes I want a drink"];
	
	
    init {
    	write name+" adds desire wants to do something";
        do add_desire(wants_to_do_something); 
    }
    
            perceive when: (self.delayOK and self.delayOK) target: Gamer where (each.talking=false) in: talk_range {
        	if(!talking and delayOK)
        	{
       
        	do remove_intention(has_decided_where_to_go, true);	
        	do remove_desire(has_decided_where_to_go);	
        	do remove_belief(has_decided_where_to_go);
        	do remove_intention(wants_to_go_somewhere, true);
        	
	        focus id:who_to_talk_to var:name strength: 5;         
        }
    }
    
        rule belief: talk_to_someone new_desire: stop_and_have_a_conversation strength: 3.0; 
	    rule belief: has_decided_where_to_go new_desire: wants_to_go_somewhere strength: 2.0; 
	     
	  
		reflex countDelay when: !delayOK
	{
		if((time-startDelay)>localDelayTime)
		{
			
			delayOK<-true;
			talking<-false;
			busy<-false;
			willingToDrink <-rnd(1,100);
		}
	}
	
		
	int willingToSocializWithOtherGamer <- rnd(1,100);
	int willingToDrink <-rnd(1,100);
	
	list<string> answerGamer<-["Not feeling like playing with another human , sorry", "Hey are you game?"];
	
	
	int drunk<-0;
	int happy<-0;
	
	
	point targetPoint <- nil;					
	
	
		
		plan decideWhatToDo intention: wants_to_do_something when: !talking and delayOK {
		if(!busy)
		{
			
			if(willingToDrink>50){
				 write name+" tries to achive desire wants_to_do_something";
			    busy<-true;
				do remove_intention(wants_to_do_something, false); 
				write name+" add belief has_decided_where_to_go";
				do add_belief(has_decided_where_to_go);
				self.happy<-self.happy+2;
				targetPoint<- any_location_in(one_of(GamingArea));		
				write name+"goes to pub";
				
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
			}else {
				write name+" tries to achive desire wants_to_do_something";
			    busy<-true;
				do remove_intention(wants_to_do_something, false); 
				write name+" add belief has_decided_where_to_go";
				do add_belief(has_decided_where_to_go);
				self.drunk<-self.drunk+1;
				self.happy<-self.happy-5;
				targetPoint<- any_location_in(one_of(Pub));		
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
				
			}
			    
		
	}
	}
	
	
	
	plan initConversation intention: stop_and_have_a_conversation instantaneous: true {

	write name+"rule of sub-belief who_to_talk and talk_to_someone is evaluated ";	
	write name+" wants to achieve desire stop_and_have_a_conversation";
				
		    list<string> possible_people_to_talk_to <- get_beliefs_with_name(who_to_talk_to) collect (string(get_predicate(mental_state (each)).values["name_value"]));
			Gamer talkTo <- nil;
			list<Gamer> talkToList <- Gamer where (each.name=possible_people_to_talk_to[0]);	
			write name+"the list: "+talkToList;
			
			if(length(talkToList)>0)
			{
			talkTo<-talkToList[0];
			}
			
			if (talkTo!=nil)
			{
				
			ask talkTo {
				self.talking<-true;
				myself.talking<-true;	
				
				
				if (distance_to(myself,one_of(Pub))<8)
				{
					write "Ohh wow another drunk gamer like me!!!!";
					if(self.acceptdrink<acceptDrinkLimit)
					{
					self.happy<-self.happy-3;
					myself.happy<-myself.happy-3;
					self.drunk<-self.drunk-1;
					myself.drunk<-myself.drunk-1;
					}
					else{
					write self.name+" says"+answerPub[1];
					self.happy<-self.happy+3;
					myself.happy<-myself.happy+3;
					self.drunk<-self.drunk+1;
					myself.drunk<-myself.drunk+1;
					}
				}else{
					if(willingToSocializWithOtherGamer>50){
				   	self.happy<-self.happy+5;
				   	myself.happy<-myself.happy+5;
				   	write myself.name + " says " + myself.answerGamer[1];
				   }else{
				   		self.happy<-self.happy-5;
				   		write myself.name + " says " + myself.answerGamer[1];
				   }
					
				}
							
										
				   
				
					
				self.delayOK<-false;		
				self.startDelay<-time;
				self.localDelayTime<-globalDelayTime+30;
				do remove_intention(stop_and_have_a_conversation,true);
            	do remove_belief(new_predicate(who_to_talk_to, ["name_value"::myself.name]));
            						
				myself.delayOK<-false;		
				myself.startDelay<-time;
				myself.localDelayTime<-globalDelayTime;
				
			}
						
            	do remove_intention(stop_and_have_a_conversation, true);	           	
            	do remove_belief(new_predicate(who_to_talk_to, ["name_value"::talkTo.name]));
            	write name+" remove intention stop_and_have_a_conversation and subbelief who_to_talk_to ";
		}
				
	} 
			
	plan moveToTarget intention: wants_to_go_somewhere when: !talking and delayOK{
	
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At destination";
			self.targetPoint <- nil;
			self.busy<-false;
            do remove_belief(has_decided_where_to_go); 
            do remove_intention(wants_to_go_somewhere, true);	
            write name+" remove intention wants_to_go_somewhere and belief has_decided_where_to_go ";	
			}
			else{
				do goto target:targetPoint;
			}
	
	
	}
	
	aspect base {
		draw circle(1) color: #cyan depth:1;
	}
}




species ChillGuy skills: [fipa,moving] control:simple_bdi {
	
	bool ChillGuy <-true;
	bool isBad <- false;
	bool busy <- false;
	bool talking<-false;
	int localDelayTime;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	
	predicate wants_to_do_something <- new_predicate("wants to do something") ;
	predicate wants_to_go_somewhere <- new_predicate("wants to go somewhere") ;
	predicate has_decided_where_to_go <- new_predicate("has decided where to go") ;
	predicate stop_and_have_a_conversation <- new_predicate("stop and have a conversation") ;
	
	string who_to_talk_to <- "who_to_talk_to";
	predicate talk_to_someone <- new_predicate(who_to_talk_to); 
	
	bool delayOK<-true;
	int startDelay;
	
	
	// 0. Add desire that chillguy wants to do something.
    init {
    	write name+" adds desire wants to do something";
        do add_desire(wants_to_do_something); 
    }
    
    // 1. Perceive agents nearby
            perceive when: (self.delayOK and self.delayOK) target: ChillGuy where (each.talking=false) in: talk_range {
        	if(!talking and delayOK)
        	{
        		
        	//If desire or belief wants to go somewhere. Remove it 
        	do remove_intention(has_decided_where_to_go, true);	
        	do remove_desire(has_decided_where_to_go);	
        	do remove_belief(has_decided_where_to_go);
        	do remove_intention(wants_to_go_somewhere, true);
        	
        	//Add sub-belief to _who_to_talk to
	        focus id:who_to_talk_to var:name strength: 5;         
        }
    }
    
    // 2. Check rules, talk_to_someone should override 
        rule belief: talk_to_someone new_desire: stop_and_have_a_conversation strength: 3.0; 
	    rule belief: has_decided_where_to_go new_desire: wants_to_go_somewhere strength: 2.0; 
	
	
		reflex countDelay when: !delayOK
	{
		if((time-startDelay)>localDelayTime)
		{
			delayOK<-true;
			talking<-false;
			busy<-false;
		}
	}
	
		
	/* TRAITS */
	int generous;
	int acceptdrink<-rnd(1,100);
	int wantsToDance<-rnd(1,100);
	int startafight<-rnd(1,100);
	int fightwinorloose <-rnd(1,100);
	
	
	/* RULES */

	list<string> answerPub1<-["No I don't want a drink?","Yes I want a drink?"];
	list<string> answerStage1<-["No I don't want to dance?","Yes I want to dance"];
	string answerOutside1<-"None of your business!!!";
	
	list<string> answerChillGuy1 <- ["Hi! Thanks, it's a nice day today.","I will defend myself.","No I don't want to fight"];	
	list<string> askChillGuy1 <- ["Hello, good day to you sir","I want to fight you","I will fight you another day then"];
	
	/* ATTRIBUTES */
	int drunk<-0;
	int happy<-0;
	int money<-0;
	
	point targetPoint <- nil;					
	
	
		//Achieve desire wants_to_do_something		
		//Add belief has_decided_where_to_go		
		plan decideWhatToDo intention: wants_to_do_something when: !talking and delayOK {
		if(!busy)
		{
			write name+" tries to achive desire wants_to_do_something";
			
			int whereToGo <- rnd(0,40);
			int becomeBad <- rnd(0,40);
			
			if(whereToGo=0)
			{
				//Stage
				write name+"goes to stage";				//intention go_somewhere
				busy<-true;
				do remove_intention(wants_to_do_something, false); 
				write name+" add belief has_decided_where_to_go";
				do add_belief(has_decided_where_to_go);
				
				targetPoint<- any_location_in(one_of(Stage));		
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
				
			}
			
			else if(whereToGo=2)
			{
				//Pub
				write name+"goes to pub";
				busy<-true;
				do remove_intention(wants_to_do_something, false); 
				write name+" add belief has_decided_where_to_go";	
				do add_belief(has_decided_where_to_go);
				
				targetPoint<- any_location_in(one_of(Pub));	
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
			}
			
			else{
				do wander;
			}
					
					
			if(whereToGo=25){
				write name+"becomes bad";
				isBad<-true;
			}
					
						
			
		}
		
		
		
		
	}
	
	plan initConversation intention: stop_and_have_a_conversation instantaneous: true {

	write name+"rule of sub-belief who_to_talk and talk_to_someone is evaluated ";	
	write name+" wants to achieve desire stop_and_have_a_conversation";
				
		    list<string> possible_people_to_talk_to <- get_beliefs_with_name(who_to_talk_to) collect (string(get_predicate(mental_state (each)).values["name_value"]));
			ChillGuy talkTo <- nil;
			list<ChillGuy> talkToList <- ChillGuy where (each.name=possible_people_to_talk_to[0]);	
			write name+"the list: "+talkToList;
			
			if(length(talkToList)>0)
			{
			talkTo<-talkToList[0];
			}
			
			if (talkTo!=nil)
			{
				
			ask talkTo {
				self.talking<-true;
				myself.talking<-true;				
										
				string localAsk <- myself.isBad ? myself.askChillGuy1[1] : myself.askChillGuy1[0];

				write myself.name+" says" + localAsk;
				
				/* BAD */
				if(myself.isBad)
				{
					
						if(self.startafight>50)
						{
							write self.name+" says"+self.answerChillGuy1[1];
							
							if(myself.fightwinorloose>self.fightwinorloose)
							{
								//badguy wins
								write myself.name+" wins the fight";
								myself.fightwinorloose<-myself.fightwinorloose+5;
								myself.happy<-myself.happy+5;
								self.happy<-self.happy-5;
								
							}
							else{
								write self.name+" wins the fight";
								self.fightwinorloose<-myself.fightwinorloose+5;
								self.happy<-self.happy+5;
								myself.happy<-myself.happy-5;
							}
							
							
						}
						else{
							write self.name+" says"+self.answerChillGuy1[2];
							write myself.name+" says"+myself.askChillGuy1[2];							
						}
					
					//random so differente behaviour next time
					self.startafight<-rnd(1,100);
					myself.startafight<-rnd(1,100);
		
				}
				
				/* NOT BAD */
				else
				{
					
					
					write self.name+" says"+answerChillGuy1[0] ;
					self.happy<-self.happy+5;
					myself.happy<-myself.happy+5;

				}
					
				//MAKE DIFFERENT DELAYS SO THEY DON't START TALKING
				self.delayOK<-false;		
				self.startDelay<-time;
				self.localDelayTime<-globalDelayTime+30;
				do remove_intention(stop_and_have_a_conversation,true);
				//do remove_belief(talk_to_someone);
            	do remove_belief(new_predicate(who_to_talk_to, ["name_value"::myself.name]));
            						
				myself.delayOK<-false;		
				myself.startDelay<-time;
				myself.localDelayTime<-globalDelayTime;
				
			}
						
            	do remove_intention(stop_and_have_a_conversation, true);	           	
            	do remove_belief(new_predicate(who_to_talk_to, ["name_value"::talkTo.name]));
            	write name+" remove intention stop_and_have_a_conversation and subbelief who_to_talk_to ";
		}
				
	} 
			
	plan moveToTarget intention: wants_to_go_somewhere when: !talking and delayOK{
	
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At destination";
			self.targetPoint <- nil;
			self.busy<-false;
            do remove_belief(has_decided_where_to_go); 			//TA BORT BÅDE BELIEF 
            do remove_intention(wants_to_go_somewhere, true);	// OCH INTENTION
            write name+" remove intention wants_to_go_somewhere and belief has_decided_where_to_go ";
            						
			}
			else{
				do goto target:targetPoint;
			}
	
	
	}
	

	
	aspect base {
		draw circle(1) color: #green depth:1;
			
		
	}
	
}

species RockFan skills: [fipa,moving] control:simple_bdi {
	
	bool ChillGuy <-true;
	bool isBad <- false;
	bool busy <- false;
	bool talking<-false;
	int localDelayTime;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	
	predicate wants_to_do_something <- new_predicate("wants to do something") ;
	predicate wants_to_go_somewhere <- new_predicate("wants to go somewhere") ;
	predicate has_decided_where_to_go <- new_predicate("has decided where to go") ;
	predicate stop_and_have_a_conversation <- new_predicate("stop and have a conversation") ;
	
	string who_to_talk_to <- "who_to_talk_to";
	predicate talk_to_someone <- new_predicate(who_to_talk_to); 
	
	bool delayOK<-true;
	int startDelay;
	
	/* TRAITS */
	int generous;
	int acceptdrink<-rnd(1,100);
	int wantsToDance<-rnd(1,100);
	int fightwinorloose<-rnd(1,100);
	
	/* RULES for CHILLGUY */
	string askPub1<-"Do you want a drink?";
	string askStage1<-"Do you want to dance?";
	string askOutside1<-"Where are you going?";
	
	
	/* ATTRIBUTES */
	int drunk<-0 max:100;
	int happy<-0 max:100;
	int money;
	
	
	
	// 0. Add desire that RockFan wants to do something.
    init {
    	write name+" adds desire wants to do something";
        do add_desire(wants_to_do_something); 
    }
    
    // 1. Perceive agents nearby
            perceive when: (self.delayOK and self.delayOK) target: ChillGuy where (each.talking=false) in: talk_range {
        	if(!talking and delayOK)
        	{
        		
        	//If desire or belief wants to go somewhere. Remove it 
        	do remove_intention(has_decided_where_to_go, true);	
        	do remove_desire(has_decided_where_to_go);	
        	do remove_belief(has_decided_where_to_go);
        	do remove_intention(wants_to_go_somewhere, true);
        	
        	//Add sub-belief to _who_to_talk to
	        focus id:who_to_talk_to var:name strength: 5;         
        }
    }
    
    // 2. Check rules, talk_to_someone should override 
        rule belief: talk_to_someone new_desire: stop_and_have_a_conversation strength: 3.0; 
	    rule belief: has_decided_where_to_go new_desire: wants_to_go_somewhere strength: 2.0; 
	
	
		reflex countDelay when: !delayOK
	{
		if((time-startDelay)>localDelayTime)
		{
			delayOK<-true;
			talking<-false;
			busy<-false;
		}
	}
	
		
	
	
	point targetPoint <- nil;					
	
	
		//Achieve desire wants_to_do_something		
		//Add belief has_decided_where_to_go		
		plan decideWhatToDo intention: wants_to_do_something when: !talking and delayOK {
		if(!busy)
		{
			write name+" tries to achive desire wants_to_do_something";
			
			int whereToGo <- rnd(0,40);
			int becomeBad <- rnd(0,40);
			
			if(whereToGo=0)
			{
				//Stage
				write name+"goes to stage";				//intention go_somewhere
				busy<-true;
				do remove_intention(wants_to_do_something, false); 
				write name+" add belief has_decided_where_to_go";
				do add_belief(has_decided_where_to_go);
				
				targetPoint<- any_location_in(one_of(Stage));		
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
				
			}
			
			else if(whereToGo=2)
			{
				//Pub
				write name+"goes to pub";
				busy<-true;
				do remove_intention(wants_to_do_something, false); 
				write name+" add belief has_decided_where_to_go";	
				do add_belief(has_decided_where_to_go);
				
				targetPoint<- any_location_in(one_of(Pub));	
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
			}
			
			else{
				do wander;
			}
					
					
			if(whereToGo=25){
				write name+"becomes bad";
				isBad<-true;
			}
					
						
			
		}
		
		
		
		
	}
	
	plan initConversation intention: stop_and_have_a_conversation instantaneous: true {

	write name+"rule of sub-belief who_to_talk and talk_to_someone is evaluated ";	
	write name+" wants to achieve desire stop_and_have_a_conversation";
				
		    list<string> possible_people_to_talk_to <- get_beliefs_with_name(who_to_talk_to) collect (string(get_predicate(mental_state (each)).values["name_value"]));
			ChillGuy talkTo <- nil;
			list<ChillGuy> talkToList <- ChillGuy where (each.name=possible_people_to_talk_to[0]);	
			write name+"the list: "+talkToList;
			
			if(length(talkToList)>0)
			{
			talkTo<-talkToList[0];
			}
			
			if (talkTo!=nil)
			{
				
			ask talkTo {
				self.talking<-true;
				myself.talking<-true;				
				bool inPub<-false;
				bool inStage <- false;
				bool inOutside <- false;
				
				if (distance_to(myself,one_of(Pub))<8)
				{
					inPub<-true;
				}
												
				if (distance_to(myself,one_of(Stage))<8)
				{
					inStage<-true;
				}
				
				if(!inStage and !inPub)
				{
					inOutside<-true;
				}
						
				write myself.name+" says hello.";
				write self.name+" says hello back";
				string localAsk <- inStage ? myself.askStage1 : (inPub ? myself.askPub1 : myself.askOutside1);

				write myself.name+" says" + localAsk;
				
				/* PUB */
				if(inPub)
				{
					if(self.acceptdrink<acceptDrinkLimit)
					{
					//write self.name+" says"+answerPub1[0] +" "+self.acceptdrink + acceptDrinkLimit;
					self.happy<-self.happy-5;
					myself.happy<-myself.happy-5;
					self.drunk<-self.drunk-1;
					myself.drunk<-myself.drunk-1;
					}
					else{
					write self.name+" says"+answerPub1[1];
					self.happy<-self.happy+5;
					myself.happy<-myself.happy+5;
					self.drunk<-self.drunk+1;
					myself.drunk<-myself.drunk+1;
					}
				}
				
				/* STAGE */
				if(inStage)
				{
					if(self.wantsToDance<wantsToDanceLimit)
					{
					write self.name+" says"+answerStage1[0] ;
					self.happy<-self.happy-1;
					myself.happy<-myself.happy-1;
					}
					else{
					write self.name+" says"+answerStage1[1];
					self.happy<-self.happy+5;
					myself.happy<-myself.happy+5;
					}
				}

				/* OUTSIDE */
				if(inOutside)
				{
				write self.answerOutside1;
				}
				
				
				
				//MAKE DIFFERENT DELAYS SO THEY DON't START TALKING
				self.delayOK<-false;		
				self.startDelay<-time;
				self.localDelayTime<-globalDelayTime+30;
				
				do remove_intention(stop_and_have_a_conversation,true);
				//do remove_belief(talk_to_someone);
            	do remove_belief(new_predicate(who_to_talk_to, ["name_value"::myself.name]));
				
				
				myself.delayOK<-false;		
				myself.startDelay<-time;
				myself.localDelayTime<-globalDelayTime;
				
				
			}
						
            	do remove_intention(stop_and_have_a_conversation, true);	           	
            	do remove_belief(new_predicate(who_to_talk_to, ["name_value"::talkTo.name]));
            	write name+" remove intention stop_and_have_a_conversation and subbelief who_to_talk_to ";
		}
				
	} 
			
	plan moveToTarget intention: wants_to_go_somewhere when: !talking and delayOK{
	
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At destination";
			self.targetPoint <- nil;
			self.busy<-false;
            do remove_belief(has_decided_where_to_go); 			//TA BORT BÅDE BELIEF 
            do remove_intention(wants_to_go_somewhere, true);	// OCH INTENTION
            write name+" remove intention wants_to_go_somewhere and belief has_decided_where_to_go ";
            						
			}
			else{
				do goto target:targetPoint;
			}
	
	
	}
	

	
	aspect base {
		draw circle(1) color: #black depth:1;
			
		
	}
	
}



experiment run_simulation type: gui {
	
    
	parameter "Wants to dance limit" var: wantsToDanceLimit;
    parameter "Wants to drink limit" var: acceptDrinkLimit;
	

	output {
		
		
		  // monitor "Happy value" value: sumHappy;
		  // monitor "Drunk value" value: sumDrunk;
		   
		
		display my_display type:opengl {
			species Stage aspect:base;
			
			species ChillGuy aspect:base;	
			species RockFan aspect:base;	
			species Thief aspect:base;	
			species Police aspect:base;	
			species Journalist aspect:base;	
			species Gamer aspect:base;
			
			
			species Pub aspect:base;
			species ThiefArea aspect:base;
			species PoliceStation aspect:base;
			species PhotoArea aspect:base;
			species GamingArea aspect:base;
			
			
			}
			
			    display chart refresh: every(10 #cycles) {
        chart "Happiness" type: series style: spline {
        data "Happy value" value: sumHappy color: #green marker: false;
        data "Drunk valuen" value: sumDrunk color: #red marker: false;
        
        }
        
        }
        
       /* layout #split parameters: true navigator: false editors: false consoles: true ;	
		
		display "data_pie_chart" type: java2D synchronized: true
		{
			chart "ChillGuy Dance vs Not dance" type: pie style: ring background: # darkblue color: # lightgreen axes: # yellow title_font: 'Serif' title_font_size: 32.0 title_font_style: 'italic'
			tick_font: 'Monospaced' tick_font_size: 14 tick_font_style: 'bold' label_font: 'Arial' label_font_size: 32 label_font_style: 'bold' x_label: 'Nice Xlabel' y_label:
			'Nice Ylabel'
			{
				data "Chillguy wants to dance" value: ChillGuyWantsToDance color: # black;
				data "Chillguy doesn't want to dance" value: ChillGuyNotWantToDance color: # blue;
			}

		}*/
        
		
			
	}
}