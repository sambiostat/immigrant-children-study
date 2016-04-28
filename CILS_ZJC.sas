**Created at 7/2;
**Latest Update at 7/27 ;
**CILS Analysis based on KAREN's suggestion***;
options fmtsearch=(tmp1.formats);
data V85;
	set tmp2.cils;
	if v18=2;
	if V85 ^=.; 
	keep CASEID V18 V19 V21a V36 V41 V78 V85 V86a V86b V86c V60 V61 V260 V261;
run;

proc format;
	value Nationf
		0='(0) America'
		1='(1) Black'
		2='(2) Hispanic'
		3='(3) Asian'
		4='(4) Other';
	value V36_41f
		1='(1) Elementary school or less'
		1.5='(1.5)One is elementary school or less and another is middle school or less'
		2='(2)Middle school or less'
		2.5='(2.5)One is middle school or less and other is some high school'
		3='(3) Some high school'
		3.5='(3.5)One is some high school and another is high school graduate'
		4='(4) High school graduate'
		4.5='(4.5)One is high school graduate and another is some college/university'
		5='(5) Some college/university'
		5.5='(5.5)One is some college/university and another is college graduate or more'
		6='(6) College graduate or more';
	value outcomef
		1='(1) Less than college'
		2='(2) Finish college'
		3='(3) Finish a graduate degree';
	value agefff
		1='(1) early adolescence'
		2='(2) middle adolescence'
		3='(3) late adolescence'
		;	
	value pefff 
		1='(1) some school'
		2='(2) high school graduate'
		3='(3) college graduate'
		;
run;
*Recategory V261 V61 to avoid small values in some groups;
*Combine parents' education levels into V36_41 to address missing values problems;
Data New;
	set V85;
	if V36^=. and V41 ^=. then V36_41 =0.5*(V36+V41);
	if V36 =. and V41 ^=. then V36_41 =V41;
	if V36 ^= . and V41 =. then V36_41 =V36;
	if V36 = . and V41 =. then V36_41 = .;
	if v61 in(1,2,3)then v61new=1;
	if v61=4 then v61new=2;
	if v61=5 then v61new=3;
	if v261 in(1,2,3) then v261new=1;
	if v261=4 then v261new=2;
	if V261=5 then v261new=3;
	if V78 = 0 then V78new=0; *American*;
	if V78 in (2,8,9,16) then V78new=1; *Black*;
	if V78 in (3,4,5,6,7,10, 11,12,19, 20,21, 50,51) then V78new=2; *Hispanic*;
	if v78 in (22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47) then V78new=3; *Asian*;
	if V78 in (15,17,18,52) then V78new=4; *Other,don't include White(1,13,14)*;
	keep CASEID V61new V261new V19 V36_41 V78new V85 ;
	attrib V78new format=Nationf.;
	format V36_41 V36_41f.;
	format v60new v61new v260new v261new outcomef.;
	label V36_41 = 'Average parents educational level';
	label v61new='Highest Education Level by Expectation at time one';
	label v261new='Highest Education Level by Expectation at time two';
	label V78new= 'How girl identify herself';
run;
*Collapse age and ParentEdu to avoid small values in some groups;
*Only keep caseid V261new V61new V78new V85 age ParentEdu ;
data collapsed; set new;
if V19=12 or v19=13 then age=1;
if (v19=14 or v19=15) then age=2;
if v19=16 or v19=17 then age = 3;
if 0<v36_41<4 then ParentEdu=1;
if 3.5<v36_41<6 then ParentEdu=2;
if v36_41=6 then ParentEdu=3;
format ParentEdu pefff. ;
format age agefff.;
keep caseid V261new V61new V78new V85 age ParentEdu;
run;
proc print data=collapsed(obs=20);run;

***Univariate Analysis***;
ods rtf file='H:\JULY15.rtf';
proc means data=collapsed nmiss n; run;
title 'frequency table';
proc freq data=collapsed;
	tables (V261new V61new  V85 age ParentEdu)*V78new/nopercent norow nocum;
run;
***Bivariate Analysis***;
proc corr data=collapsed;
	var V261new V61new V78new V85 age ParentEdu;
run;
title 'Chisqure Test';
proc freq data=collapsed;
	tables  V261new*( V78new V85 age ParentEdu) V61new*(V78new V85 age ParentEdu)
			V85*(V78new age ParentEdu) V78new*(age ParentEdu)  ParentEdu*age/chisq norow nopercent nocol nocum;
run;
proc transpose data=collapsed out=long;
	by caseid;
	copy  V78new V85 age ParentEdu ;
	var V61new V261new;
run;
data long;set long (rename=(col1=EducationExpectation));
	if _NAME_= 'v61new' then time=1;
	if _NAME_= 'v261new' then time=2;
	drop _NAME_ _LABEL_;
run;
data long; set long;
	retain V85old ageold  peold V78newold ;
	by caseid;
	if first.caseid then 
		do;  
			V85old=V85;
			ageold=age ;
			peold=parentedu;
			V78newold=V78new;
		end;
	else 
		do;
			v85=v85old;
			age=ageold;
			parentedu=peold;
			V78new=V78newold;
		end;
	keep caseid V78new V85 age ParentEdu time educationexpectation;
run;
title 'MODLE1';
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85/ s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
TITLE 'MODEL2';
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME / s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
TITLE 'MODEL3';
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME V78new/ s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
TITLE 'MODEL4';
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME V85*Time/ s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
TITLE 'MODEL5';
ods select FitStatistics CovParms Covtests;
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME V78new age ParentEdu/ s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
TITLE 'MODEL6';
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME V78new age ParentEdu V78new*V85/ s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
TITLE 'MODEL7';
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME V78new age ParentEdu  age*ParentEdu / s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
TITLE 'MODEL8';
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME V78new age ParentEdu  ParentEdu*V78new / s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;
ods rtf close;

