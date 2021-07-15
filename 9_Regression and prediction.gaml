/**
* Name: Deplacementdevelos
* Based on the internal empty template. 
* Author: nathancoisne
* Tags: 
*/


model Deplacementdevelos

/* 
 * This model generates a regression between the pollution level given by "Synthetc measures from agents' travels" and the environment indicators generated in "Measures' environment"
 * 
 */

global {
		
	bool workers <- false;
    bool students <- true;
    bool leisures <- false;
	
	file measures_workers_csv;
    file measures_students_csv;
    file measures_leisures_csv;

	file environment_workers_csv;
    file environment_students_csv;
    file environment_leisures_csv;
    
    file measures_to_predict_workers_csv;
    file measures_to_predict_students_csv;
    file measures_to_predict_leisures_csv;

	file environment_for_prediction_workers_csv;
    file environment_for_prediction_students_csv;
    file environment_for_prediction_leisures_csv;

    init{ 

       	//matrice de régression routes largeur: DATE, longueur de route 0-4, 4-6, 6-8, 8-max, NO2
    	//matrice de régression routes voies: DATE, voies 1, 2, 3, 4, 5, 6, NO2
    	//matrice de régression bâtiments: DATE, buildings_volume, NO2
		//matrice de régression végétation: DATE, bois, foret, haie, NO2
    	    	
    	if(students){
    		measures_students_csv <- csv_file("../results/Marseille/student/students_measures.csv",true); //mesures faites par 1800 agents student
    		environment_students_csv <- csv_file("../results/Marseille/student/students_measures_environment.csv",true);
    		
    		create measure from: measures_students_csv;
    		create environment from: environment_students_csv;
    		    		
    		list<float> pollution_NO2 ;
    		list<float> ind_date;
    		
    		loop m over: measure {
    			pollution_NO2 << m.NO2_concentration;
    			string time_m <- (((m.time_of_measure split_with "'(")[1]) split_with ")'")[0];
    			ind_date << float(date(time_m));
    		}
    	    		
    		//création de la matrice de régression routes voies
    		list<float> ind_voies_1;
    		list<float> ind_voies_2;
    		list<float> ind_voies_3;
    		list<float> ind_voies_4;
    		list<float> ind_voies_5;
    		list<float> ind_voies_6;
    		
    		loop env over: environment {
    			ind_voies_1 << env.voie_1;
    			ind_voies_2 << env.voie_2;
    			ind_voies_3 << env.voie_3;
    			ind_voies_4 << env.voie_4;
    			ind_voies_5 << env.voie_5;
    			ind_voies_6 << env.voie_6;
    		}
    		
    		matrix routes_voies_regression <- matrix(ind_date, ind_voies_1, ind_voies_2, ind_voies_3, ind_voies_4, ind_voies_5, ind_voies_6, pollution_NO2);
    		      		
    		regression NO2_voies_student <- build(routes_voies_regression);
    		write("regression generee. debut de la prediction des trajets restants");
    		
    		// prediction des trajets non réalisés à partir de l'environnement de ces trajets
    		
    		measures_to_predict_students_csv <- csv_file("../results/Marseille/student/students_measures_to_predict.csv",true);
    		environment_for_prediction_students_csv <- csv_file("../results/Marseille/student/students_environment_for_prediction.csv",true);
    		
    		create measure from: measures_to_predict_students_csv; // mesures à prédire pour les agents student restants
    		create environment from: environment_for_prediction_students_csv;
    		
    		loop env over: environment {
    			measure associated_measure <- measure[int(env)];
    			string time_m <- (((associated_measure.time_of_measure split_with "'(")[1]) split_with ")'")[0];
    			float predict_date <- float(date(time_m));
    			measure[int(env)].predicted_NO2_concentration <- predict(NO2_voies_student, [predict_date, env.voie_1, env.voie_2, env.voie_3, env.voie_4, env.voie_5, env.voie_6]);
    		}
    		
    		ask measure{
			
				save [ID, name_of_agent, longitude, latitude, time_of_measure, NO2_concentration, predicted_NO2_concentration, O3_concentration, PM10_concentration, PM25_concentration] 
	    				to: "../results/Marseille/student/students_measures_predicted.csv" type:"csv" rewrite: false;
	    				
	    	} 		   	
		}
	}

}

species measure {
	int ID;
	string name_of_agent;
	float longitude;
	float latitude;
	string time_of_measure;
	float NO2_concentration;
	float O3_concentration;
	float PM10_concentration;
	float PM25_concentration;
	
	float predicted_NO2_concentration;
	float predicted_O3_concentration;
	float predicted_PM10_concentration;
	float predicted_PM25_concentration;
}

species environment{ // flotants correspondant à l'environnement dans un disque de 50m de rayon centré sur la mesure
	int ID; // ID égal à celui de la mesure
	string name_of_agent;
	float longitude;
	float latitude;
	
	float road_0_4_width; // longueur de route dans le disque ayant comme attribut : largeur <= 4 
	float road_4_6_width; // longueur de route dans le disque ayant comme attribut : 4 < largeur <= 6 
	float road_6_8_width; // longueur de route dans le disque ayant comme attribut : 6 < largeur <= 8 
	float road_8_max_width; // longueur de route dans le disque ayant comme attribut : 8 < largeur
	float voie_1;
	float voie_2;
	float voie_3;
	float voie_4;
	float voie_5;
	float voie_6;
	float buildings_volume;
	float distance_to_main_road;
	float bois; //surface de bois dans le disque
	float foret;
	float haie;
}

species position_travel {
	
}
experiment regression_prediction type: gui {
	output{
    	display city_display type: opengl{
    		species measure;
    	}
    	
    }
}