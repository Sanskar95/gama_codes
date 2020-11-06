/**
* Name: mymodel
* Based on the internal empty template. 
* Author: Sanskar95
* Tags: 
*/




model mymodel

/* Insert your model definition here */

global{
	int number_of_information_centers <- 1;
	int number_of_festival_guests <- 10; 	
	int number_of_food_festival_shops <- 2;
	int number_of_drinking_festival_shops <- 2;
	
	 
	
	
	init{
		create information_center number: number_of_information_centers;
		create festival_guests number: number_of_festival_guests;
		create food_festival_shops number: number_of_food_festival_shops;
		create drinking_festival_shops number: number_of_drinking_festival_shops;
		create Security number: 1;
	}
}

species information_center{
	init {
    location <- {1,1};
    }
    
	int range<-3;
	
	
	reflex communicate when: !empty(festival_guests at_distance range ){
		ask festival_guests at_distance range{
			if(self.thirstMetric<0){
				self.targetPoint <-drinking_festival_shops[rnd(1)].location;
			}else if(self.hungerMetric < 0){
				self.targetPoint <-food_festival_shops[rnd(1)].location;
			}
		}
	}
	
	reflex checkForBadGuest
	{
		ask festival_guests at_distance range
		{
			if(self.isBad)
			{
				festival_guests badGuest <- self;
				ask Security
				{
					if(!(self.targets contains badGuest))
					{
						self.targets <+ badGuest;
						write 'InfoCenter found a bad guest (' + badGuest.name + '), sending poilice after it';	
					}
				}
			}
		}
	}
	
	aspect base {
		draw cube(3) at: location color: #blue;
	}
}
	

species festival_guests skills: [moving]{

	list<drinking_festival_shops> drink_guestBrain;
	list<food_festival_shops> food_guestBrain;
	int range <-2;
	bool isBad <- flip(0.2);
	int thirstMetric <-50;
	int hungerMetric <-50;
	point informationCenterLocation <- (point(4,5));
	float distance <- 0.0;
	bool useBrain <- flip(0.5);
	// list to store all visisted shops info
	
	point targetPoint <- nil;
	

	reflex beIdle when: targetPoint = nil{
		if(useBrain){
			if(thirstMetric >0 or hungerMetric>0 ){
			do wander;	
			thirstMetric <- thirstMetric-rnd(5);
			hungerMetric <- hungerMetric-rnd(5);
		}else{
			if(thirstMetric<0){
				if(empty(drink_guestBrain)){
					targetPoint <- {1,1};
					distance <- distance + location distance_to targetPoint;
				}else{
					int size <- length(drink_guestBrain);
					targetPoint <- drink_guestBrain[rnd(size-1)].location;
					distance <- distance + location distance_to targetPoint;
					
				}
			} else{
				if(empty(food_guestBrain)){
					targetPoint <- {1,1};
					distance <- distance + location distance_to targetPoint;
				}else{
					int size <- length(food_guestBrain);
					targetPoint <- food_guestBrain[rnd(size-1)].location;
					distance <- distance + location distance_to targetPoint;
				}
			}
//			write name+" Distance" + distance;
		}
		}else{
			if(thirstMetric >0 or hungerMetric>0 ){
			do wander;	
			thirstMetric <- thirstMetric-rnd(5);
			hungerMetric <- hungerMetric-rnd(1);
		}else{
			targetPoint <- {1,1};
			distance <- distance + location distance_to targetPoint;
		}
//		write name+" Distance" + distance;
		}
		
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex communicateToOtherGuest when: !empty(festival_guests at_distance range ){
		ask festival_guests at_distance range{
			if(self.hungerMetric<0){
							loop building over: myself.food_guestBrain {
								if(!(self.food_guestBrain contains building)){
									self.targetPoint<- building.location;
									self.food_guestBrain<- self.food_guestBrain+building;
								}
                          }
//                          write self.name+ " The food_guestBrain is:" + self.food_guestBrain;
			} else if(self.thirstMetric<0){
				loop building over: myself.drink_guestBrain {
								if(!(self.drink_guestBrain contains building)){
									self.targetPoint<- building.location;
									self.drink_guestBrain<- self.drink_guestBrain+building;
								}
                          }
//                           write self.name+ " The drink_guestBrain is:" + self.drink_guestBrain;
			}
		}
	}

	aspect base
	{
		if(useBrain){
			if(isBad) {
			color <- #purple;
		}
		else {
			color <- #yellow;
		}
		}else{
			if(isBad) {
			color <- #grey;
		}
		else {
			color <- #green;
		}
		}
		
		draw sphere(1) at: location color: color;
	}
}


species food_festival_shops{

    
	int range <- 1;
	reflex replenish when: !empty(festival_guests at_distance range){
		ask festival_guests at_distance range{
			self.hungerMetric<- 50;
			add item:myself to: self.food_guestBrain at: 0;
			self.food_guestBrain <- remove_duplicates(self.food_guestBrain);
			self.targetPoint <- nil;
			
		}
	}

	aspect base {
		draw pyramid(3) at: location color: #green;
	}
}

species drinking_festival_shops{
	int range <- 1;
	reflex replenish when: !empty(festival_guests at_distance range){
		ask festival_guests at_distance range{
			self.thirstMetric<- 50;
			add item:myself to: self.drink_guestBrain at: 0;
			self.drink_guestBrain <- remove_duplicates(self.drink_guestBrain);
			self.targetPoint <- nil;
		}
	}

	aspect base {
		draw pyramid(3) at: location color: #gold;
	}
}

species Security skills:[moving]
{
	list<festival_guests> targets;
	aspect default
	{
		draw sphere(1) at: location color: #black;
	}
	
	reflex catchBadGuest when: length(targets) > 0
	{
		//this is needed in case the guest dies before robocop catches them
		if(dead(targets[0]))
		{
			targets >- first(targets);
		}
		else
		{
			do goto target:(targets[0].location);
		}
	}
	
	reflex badGuestCaught when: length(targets) > 0 and !dead(targets[0]) and location distance_to(targets[0].location) < 0.2
	{
		ask targets[0]
		{
			write name + ': killed by security!';
			do die;
		}
		targets >- first(targets);
	}
}


experiment my_experiment type: gui {
	
	
	output {
display map type: opengl{

	species information_center aspect: base;
	species food_festival_shops aspect: base;
	species drinking_festival_shops aspect: base;
	
	species festival_guests aspect: base;
	species Security ;
	
	

	}
	}
	}
