/**
* Name: Deplacementdevelos
* Based on the internal empty template. 
* Author: nathancoisne
* Tags: 
*/


model Deplacementdevelos

/* 
 * This model generates pollution measures from the last quarter of trips generated by 'travel agents'. Pollution data are extracted from a hourly pollution model from AtmoSud (date: 27/05/2021)
 * These measures will be compared to predicted measures
 * 
 */

global {
		
	file bound <- shape_file("../includes/Marseille/boundary_Marseille.shp");
		  	
	bool workers <- false; // une seule population en 'true' à la fois pour le stockage des mesures par type d'agent
    bool students <- true;
    bool leisures <- false;
    
    bool measure_NO2 <- true;
    bool measure_O3 <- true;
    bool measure_PM10 <- true;
    bool measure_PM25 <- true;
        
    geometry shape <- envelope(bound);
    
    // coordonees des rasters de pollution
    float min_x <- 889462.50000;
    float min_y <- 6236287.50000;
    float max_x <- 905062.50000;
    float max_y <- 6254412.50000;
    
    int compteur_ID <- 0;
   	
    init{ 
  		   	
		// mise en mémoire du cube de pollution NO2, O3, PM10, PM25 (24 rasters horaires)
		list<matrix<float>> NO2_rasters;
		list<matrix<float>> O3_rasters;
		list<matrix<float>> PM10_rasters;
		list<matrix<float>> PM25_rasters;
		
		if measure_NO2 {
			// raster heure 0 manquant pour la journée du 27
			matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
			NO2_rasters << pollution_raster_float;
			
			loop i from: 1 to: 23{
				
				string path_grid;
				if (i < 10){
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_NO2_202105270' + i + '_202105270' + i + '.tif';
				}
				else{
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_NO2_20210527' + i + '_20210527' + i + '.tif';
				}
				
				matrix my_data <- grid_file(path_grid) as_matrix({624, 725});
		        
		        matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
					
				loop j from: 0 to: 623{
					loop k from: 0 to: 724{
						
						pollution_raster_float[j, k] <- float (my_data[j, k] get("grid_value"));
						
					}
				}
				write ('raster NO2 ' + i + ' chargé');
				write('max: ' + max(pollution_raster_float));
				
				NO2_rasters << pollution_raster_float;
			}
		}
		
		if measure_O3 {
			
			matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
			O3_rasters << pollution_raster_float;
			
			loop i from: 1 to: 23{
				
				string path_grid;
				if (i < 10){
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_O3_202105270' + i + '_202105270' + i + '.tif';
				}
				else{
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_O3_20210527' + i + '_20210527' + i + '.tif';
				}
				
				matrix my_data <- grid_file(path_grid) as_matrix({624, 725});
		        
		        matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
					
				loop j from: 0 to: 623{
					loop k from: 0 to: 724{
						
						pollution_raster_float[j, k] <- float (my_data[j, k] get("grid_value"));
						
					}
				}
				write ('raster O3 ' + i + ' chargé');
				write('max: ' + max(pollution_raster_float));
				
				O3_rasters << pollution_raster_float;
			}
		}
		
		if measure_PM10 {
			
			matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
			PM10_rasters << pollution_raster_float;
			
			loop i from: 1 to: 23{
				
				string path_grid;
				if (i < 10){
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_PM10_202105270' + i + '_202105270' + i + '.tif';
				}
				else{
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_PM10_20210527' + i + '_20210527' + i + '.tif';
				}
				
				matrix my_data <- grid_file(path_grid) as_matrix({624, 725});
		        
		        matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
					
				loop j from: 0 to: 623{
					loop k from: 0 to: 724{
						
						pollution_raster_float[j, k] <- float (my_data[j, k] get("grid_value"));
						
					}
				}
				write ('raster PM10 ' + i + ' chargé');
				write('max: ' + max(pollution_raster_float));
				
				PM10_rasters << pollution_raster_float;
			}
		}
		
		if measure_PM25 {
			
			matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
			PM25_rasters << pollution_raster_float;
			
			loop i from: 1 to: 23{
				
				string path_grid;
				if (i < 10){
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_PM25_202105270' + i + '_202105270' + i + '.tif';
				}
				else{
					path_grid <- '../includes/Marseille/pollution_model/raster_dep13_PM25_20210527' + i + '_20210527' + i + '.tif';
				}
				
				matrix my_data <- grid_file(path_grid) as_matrix({624, 725});
		        
		        matrix<float> pollution_raster_float <- 0.0 as_matrix({624, 725});
					
				loop j from: 0 to: 623{
					loop k from: 0 to: 724{
						
						pollution_raster_float[j, k] <- float (my_data[j, k] get("grid_value"));
						
					}
				}
				write ('raster PM25 ' + i + ' chargé');
				write('max: ' + max(pollution_raster_float));
				
				PM25_rasters << pollution_raster_float;
			}
		}
		
		
		// generation des donnees de pollution pour chaque type d'agent
		
		if workers{
	    	write("generating workers measures");
	    		    	
	    	create measure from: shape_file("../results/Marseille/worker/aller_worker/positions_aller_worker.shp") with: [time_of_measure::(read("time")), name_of_agent::(read('agent'))]{
	    		
	    		int worker_number <- int((((name_of_agent split_with '[')[1]) split_with ']')[0]);
	    		write(worker_number);
				if (worker_number <= 3000){do die;} 

	    		ID <- compteur_ID;
		    	compteur_ID <- compteur_ID + 1;
		    			    					    
			    geometry CRS_2154 <- location CRS_transform("EPSG:2154");
			    
			    list<string> coord <- string(CRS_2154) split_with ",";
			    
			    latitude <- float(coord[1]);
			    longitude <- float((coord[0] split_with "{")[0]);
							
			    int cell_x <- int((longitude - min_x) / 25);
			    int cell_y <- int((max_y - latitude) / 25);
			    		    				    		
			    // obtention de la concentration de polluant : interpolation linéaire entre les deux rasters horaires qui 'encadrent' l'heure de mesure
			    
				   	
				int hour_before_measure <- time_of_measure.hour;
				int hour_after_measure <- hour_before_measure + 1;
					
				int min_measure <- time_of_measure.minute;
				int sec_measure <- time_of_measure.second;
					
				if measure_NO2 {	
				NO2_concentration <- NO2_rasters[hour_before_measure][cell_x,cell_y] + 
											  (NO2_rasters[hour_after_measure][cell_x,cell_y] - NO2_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_O3 {	
				O3_concentration <- O3_rasters[hour_before_measure][cell_x,cell_y] + 
											  (O3_rasters[hour_after_measure][cell_x,cell_y] - O3_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM10 {	
				PM10_concentration <- PM10_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM10_rasters[hour_after_measure][cell_x,cell_y] - PM10_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM25 {	
				PM25_concentration <- PM25_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM25_rasters[hour_after_measure][cell_x,cell_y] - PM25_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
				  
				}
				
				save [ID, name_of_agent, longitude, latitude, time_of_measure, NO2_concentration, O3_concentration, PM10_concentration, PM25_concentration] 
	    				to: "../results/Marseille/worker/workers_measures_to_predict.csv" type:"csv" rewrite: false;
	    	}
	    	
	    	ask measure{do die;}
	    	
	    	create measure from: shape_file("../results/Marseille/worker/retour_worker/positions_retour_worker.shp") with: [time_of_measure::(read("time")), name_of_agent::(read('agent'))]{
	    		
	    		int worker_number <- int((((name_of_agent split_with '[')[1]) split_with ']')[0]);
	    		write(worker_number);
				if (worker_number <= 3000){do die;} 

	    		ID <- compteur_ID;
		    	compteur_ID <- compteur_ID + 1;
		    			    					    
			    geometry CRS_2154 <- location CRS_transform("EPSG:2154");
			    
			    list<string> coord <- string(CRS_2154) split_with ",";
			    
			    latitude <- float(coord[1]);
			    longitude <- float((coord[0] split_with "{")[0]);
							
			    int cell_x <- int((longitude - min_x) / 25);
			    int cell_y <- int((max_y - latitude) / 25);
			    		    				    		
			    // obtention de la concentration de polluant : interpolation linéaire entre les deux rasters horaires qui 'encadrent' l'heure de mesure
			    
				   	
				int hour_before_measure <- time_of_measure.hour;
				int hour_after_measure <- hour_before_measure + 1;
					
				int min_measure <- time_of_measure.minute;
				int sec_measure <- time_of_measure.second;
					
				if measure_NO2 {	
				NO2_concentration <- NO2_rasters[hour_before_measure][cell_x,cell_y] + 
											  (NO2_rasters[hour_after_measure][cell_x,cell_y] - NO2_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_O3 {	
				O3_concentration <- O3_rasters[hour_before_measure][cell_x,cell_y] + 
											  (O3_rasters[hour_after_measure][cell_x,cell_y] - O3_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM10 {	
				PM10_concentration <- PM10_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM10_rasters[hour_after_measure][cell_x,cell_y] - PM10_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM25 {	
				PM25_concentration <- PM25_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM25_rasters[hour_after_measure][cell_x,cell_y] - PM25_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				save [ID, name_of_agent, longitude, latitude, time_of_measure, NO2_concentration, O3_concentration, PM10_concentration, PM25_concentration] 
	    				to: "../results/Marseille/worker/workers_measures_to_predict.csv" type:"csv" rewrite: false;
	    	}
	    	ask measure{do die;}
	    	
	    		
	    }	    	
	    
    	   		
    	if students{
	    	write("generating students measures");
	    		    	
	    	create measure from: shape_file("../results/Marseille/student/aller_student/positions_aller_student.shp") with: [time_of_measure::(read("time")), name_of_agent::(read('agent'))]{
	    		
	    		int student_number <- int((((name_of_agent split_with '[')[1]) split_with ']')[0]);
	    		write(student_number);
				if (student_number <= 1800){do die;} 
				
	    		ID <- compteur_ID;
		    	compteur_ID <- compteur_ID + 1;
		    			    					    
			    geometry CRS_2154 <- location CRS_transform("EPSG:2154");
			    
			    list<string> coord <- string(CRS_2154) split_with ",";
			    
			    latitude <- float(coord[1]);
			    longitude <- float((coord[0] split_with "{")[0]);
							
			    int cell_x <- int((longitude - min_x) / 25);
			    int cell_y <- int((max_y - latitude) / 25);
			    		    				    		
			    // obtention de la concentration de polluant : interpolation linéaire entre les deux rasters horaires qui 'encadrent' l'heure de mesure
			    
				   	
				int hour_before_measure <- time_of_measure.hour;
				int hour_after_measure <- hour_before_measure + 1;
					
				int min_measure <- time_of_measure.minute;
				int sec_measure <- time_of_measure.second;
					
				if measure_NO2 {	
				NO2_concentration <- NO2_rasters[hour_before_measure][cell_x,cell_y] + 
											  (NO2_rasters[hour_after_measure][cell_x,cell_y] - NO2_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_O3 {	
				O3_concentration <- O3_rasters[hour_before_measure][cell_x,cell_y] + 
											  (O3_rasters[hour_after_measure][cell_x,cell_y] - O3_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM10 {	
				PM10_concentration <- PM10_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM10_rasters[hour_after_measure][cell_x,cell_y] - PM10_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM25 {	
				PM25_concentration <- PM25_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM25_rasters[hour_after_measure][cell_x,cell_y] - PM25_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
				  
				}
				
				save [ID, name_of_agent, longitude, latitude, time_of_measure, NO2_concentration, O3_concentration, PM10_concentration, PM25_concentration] 
	    				to: "../results/Marseille/student/students_measures_to_predict.csv" type:"csv" rewrite: false;
	    	}
	    	
	    	ask measure{do die;}
	    	
	    	create measure from: shape_file("../results/Marseille/student/retour_student/positions_retour_student.shp") with: [time_of_measure::(read("time")), name_of_agent::(read('agent'))]{
	    			    		
	    		int student_number <- int((((name_of_agent split_with '[')[1]) split_with ']')[0]);
	    		write(student_number);
				if (student_number <= 1800){do die;} 
	    		
	    		ID <- compteur_ID;
		    	compteur_ID <- compteur_ID + 1;
		    			    					    
			    geometry CRS_2154 <- location CRS_transform("EPSG:2154");
			    
			    list<string> coord <- string(CRS_2154) split_with ",";
			    
			    latitude <- float(coord[1]);
			    longitude <- float((coord[0] split_with "{")[0]);
							
			    int cell_x <- int((longitude - min_x) / 25);
			    int cell_y <- int((max_y - latitude) / 25);
			    		    				    		
			    // obtention de la concentration de polluant : interpolation linéaire entre les deux rasters horaires qui 'encadrent' l'heure de mesure
			    
				   	
				int hour_before_measure <- time_of_measure.hour;
				int hour_after_measure <- hour_before_measure + 1;
					
				int min_measure <- time_of_measure.minute;
				int sec_measure <- time_of_measure.second;
					
				if measure_NO2 {	
				NO2_concentration <- NO2_rasters[hour_before_measure][cell_x,cell_y] + 
											  (NO2_rasters[hour_after_measure][cell_x,cell_y] - NO2_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_O3 {	
				O3_concentration <- O3_rasters[hour_before_measure][cell_x,cell_y] + 
											  (O3_rasters[hour_after_measure][cell_x,cell_y] - O3_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM10 {	
				PM10_concentration <- PM10_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM10_rasters[hour_after_measure][cell_x,cell_y] - PM10_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM25 {	
				PM25_concentration <- PM25_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM25_rasters[hour_after_measure][cell_x,cell_y] - PM25_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				save [ID, name_of_agent, longitude, latitude, time_of_measure, NO2_concentration, O3_concentration, PM10_concentration, PM25_concentration] 
	    				to: "../results/Marseille/student/students_measures_to_predict.csv" type:"csv" rewrite: false;
	    	}
	    	ask measure{do die;}
	    		
	    }
	    
	    if leisures{
	    	write("generating leisures measures");
	    		    	
	    	create measure from: shape_file("../results/Marseille/leisure/aller_leisure/positions_aller_leisure.shp") with: [time_of_measure::(read("time")), name_of_agent::(read('agent'))]{
	    		
	    		int leisure_number <- int((((name_of_agent split_with '[')[1]) split_with ']')[0]);
	    		write(leisure_number);
				if (leisure_number <= 6200){do die;}

	    		ID <- compteur_ID;
		    	compteur_ID <- compteur_ID + 1;
		    			    					    
			    geometry CRS_2154 <- location CRS_transform("EPSG:2154");
			    
			    list<string> coord <- string(CRS_2154) split_with ",";
			    
			    latitude <- float(coord[1]);
			    longitude <- float((coord[0] split_with "{")[0]);
							
			    int cell_x <- int((longitude - min_x) / 25);
			    int cell_y <- int((max_y - latitude) / 25);
			    		    				    		
			    // obtention de la concentration de polluant : interpolation linéaire entre les deux rasters horaires qui 'encadrent' l'heure de mesure
			    
				   	
				int hour_before_measure <- time_of_measure.hour;
				int hour_after_measure <- hour_before_measure + 1;
					
				int min_measure <- time_of_measure.minute;
				int sec_measure <- time_of_measure.second;
					
				if measure_NO2 {	
				NO2_concentration <- NO2_rasters[hour_before_measure][cell_x,cell_y] + 
											  (NO2_rasters[hour_after_measure][cell_x,cell_y] - NO2_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_O3 {	
				O3_concentration <- O3_rasters[hour_before_measure][cell_x,cell_y] + 
											  (O3_rasters[hour_after_measure][cell_x,cell_y] - O3_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM10 {	
				PM10_concentration <- PM10_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM10_rasters[hour_after_measure][cell_x,cell_y] - PM10_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM25 {	
				PM25_concentration <- PM25_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM25_rasters[hour_after_measure][cell_x,cell_y] - PM25_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
				  
				}
				
				save [ID, name_of_agent, longitude, latitude, time_of_measure, NO2_concentration, O3_concentration, PM10_concentration, PM25_concentration] 
	    				to: "../results/Marseille/leisure/leisures_measures_to_predict.csv" type:"csv" rewrite: false;
	    	}
	    	
	    	ask measure{do die;}
	    	
	    	create measure from: shape_file("../results/Marseille/leisure/retour_leisure/positions_retour_leisure.shp") with: [time_of_measure::(read("time")), name_of_agent::(read('agent'))]{
	    		
	    		int leisure_number <- int((((name_of_agent split_with '[')[1]) split_with ']')[0]);
	    		write(leisure_number);
				if (leisure_number <= 6200){do die;}
	    		
	    		ID <- compteur_ID;
		    	compteur_ID <- compteur_ID + 1;
		    			    					    
			    geometry CRS_2154 <- location CRS_transform("EPSG:2154");
			    
			    list<string> coord <- string(CRS_2154) split_with ",";
			    
			    latitude <- float(coord[1]);
			    longitude <- float((coord[0] split_with "{")[0]);
							
			    int cell_x <- int((longitude - min_x) / 25);
			    int cell_y <- int((max_y - latitude) / 25);
			    		    				    		
			    // obtention de la concentration de polluant : interpolation linéaire entre les deux rasters horaires qui 'encadrent' l'heure de mesure
			    
				   	
				int hour_before_measure <- time_of_measure.hour;
				int hour_after_measure <- hour_before_measure + 1;
					
				int min_measure <- time_of_measure.minute;
				int sec_measure <- time_of_measure.second;
					
				if measure_NO2 {	
				NO2_concentration <- NO2_rasters[hour_before_measure][cell_x,cell_y] + 
											  (NO2_rasters[hour_after_measure][cell_x,cell_y] - NO2_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_O3 {	
				O3_concentration <- O3_rasters[hour_before_measure][cell_x,cell_y] + 
											  (O3_rasters[hour_after_measure][cell_x,cell_y] - O3_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM10 {	
				PM10_concentration <- PM10_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM10_rasters[hour_after_measure][cell_x,cell_y] - PM10_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				if measure_PM25 {	
				PM25_concentration <- PM25_rasters[hour_before_measure][cell_x,cell_y] + 
											  (PM25_rasters[hour_after_measure][cell_x,cell_y] - PM25_rasters[hour_before_measure][cell_x,cell_y]) * (min_measure * 60 + sec_measure) / 3600;
											  
				}
				
				save [ID, name_of_agent, longitude, latitude, time_of_measure, NO2_concentration, O3_concentration, PM10_concentration, PM25_concentration] 
	    				to: "../results/Marseille/leisure/leisures_measures_to_predict.csv" type:"csv" rewrite: false;
	    	}
	    	ask measure{do die;}
	    		
	    }		    	
    }          
}

species measure {
	int ID;
	string name_of_agent;
	float longitude min: min_x max: max_x - 0.1;
	float latitude min: min_y max: max_y - 0.1;
	date time_of_measure;
	float NO2_concentration;
	float O3_concentration;
	float PM10_concentration;
	float PM25_concentration;
}

experiment bike_traffic type: gui {

}