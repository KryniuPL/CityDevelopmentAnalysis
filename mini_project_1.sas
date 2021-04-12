/*import data*/
proc import 
	datafile='C:\Users\dragak01\GIT\CityDevelopmentAnalysis\data.xlsx'
	dbms=xlsx
	out=work.imported
	replace;
run;

/*drop idle columns and change values of columns to 0 and 1
change type of 'target' to numeric*/
data work_data;
	set imported(keep=city_development_index gender education_level target);
	if city_development_index < 0.9 then city_development_index = 0;
	else city_development_index = 1;
	if gender = 'Male' then gender = 0;
	else gender = 1;
	if education_level in ('', 'Primary School', 'High School') then education_level = 0;
	else education_level = 1;
run;
 
data work_data_formatted;
	set work_data;
	target1 = input(target, best8.);
	keep city_development_index gender education_level target1;
	rename target1=target;
run;

/*proc freq and generated tables*/
proc freq data=work_data_formatted order=formatted;
	tables _all_/relrisk chisq measures cmh;
run;

proc freq data=work_data_formatted order=formatted;
	tables city_development_index*gender*education_level*target/relrisk chisq measures cmh;
run;

/*proc logistic -  all variables used*/
ods graphics on;
proc logistic data=work_data_formatted plots(only)=roc;
	class city_development_index gender education_level;
	model target=city_development_index gender education_level/aggregate scale=none lackfit
	rsq;
	output out=out predicted=p;
run;
ods graphics off;

/*proc logistic and proc genmod*/
ods graphics on;
proc genmod data=work_data_formatted;
	class city_development_index gender education_level;
	model target=city_development_index gender education_level/dist=bin
	link=logit;	
run;
ods graphics off;

ods graphics on;
proc genmod data=work_data_formatted desc;
	class city_development_index gender education_level;
	model target=city_development_index gender education_level/dist=bin
	link=logit;	
run;
ods graphics off;
