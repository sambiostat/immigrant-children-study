**************************************************;
**Script:CILS_ALL_ZJC;
**Author:Jinchun Zhang(samanthazhangjinchun@gmail.com);
**Description: This is the complete scripts for CILS data analyze, including some draft or wrong analyze methods. ;
**				For script used for the final analyze, please refer the script at the same folder named: 'CILS_ZJC';
**Latest Updated 2015/08/10;
*************************************************;
****JUN 11****;
options fmtsearch=(tmp1.formats);
proc contents data=TMP2.cils VARNUM;run;
proc print data=tmp2.cils (obs=10); run;
data Girl;
	set tmp2.cils;
	if v18=2; 
	keep CASEID V18 V19 V21a V36 V41 V78 V85 V86a V86b V86c V60 V61 V260 V261;
run;
proc contents data=Girl; run;
proc freq data=Girl; table V78; run;
proc print data=Girl;
	where V85=1 and V86a=. and V86b=. and V86C=.;
run;
*creat the new dataset for only girls felt descrimation or NO*;
data GirlV85;
	set Girl;
	if V85 ^= . ;
run;
proc corr data=GirlV85 noprob; var v60 v61 v260 v261 v85 v86a v86b v86c; run;
proc freq data=GirlV85;table V19 V21a V36 V41 V78 V85 V86a V86b V86c V60 V61 V260 V261; run;
*=====================================================================;
********Jun 12*********************;
data GirlV85Y;
	set GirlV85;
	if V85 =1;
run;
proc freq data=GirlV85Y;	table V60 v61 v260 v261 V19 V36 V41 V78 v21a; run;

**Model 1: find which variable is quasi-complete seperate the dependent variables**;
proc logistic data=GirlV85Y;
	class V85 V19 V21a V36 V41 V78;
	model V410=V85 V19 V21a V36 V41 V78
			/ selection=stepwise
                     slentry=0.3
                     slstay=0.35 ;
	run;
***NOTE: in Model 1, V60, V61, V260, V261 are all quasi-complete seperation by variable V78**;
**Model 2**;
proc logistic data=GirlV85Y;
	class V85 V19 V21a V36 V41 V78;
	model V410=V85 V19 V21a V36 V41 V78;
run;
*======================Jun 15& Jun16===========================================;
***Data Tranformation To the data we need for further analysis*****;
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
run;
Data New;
	set GirlV85;
	if V36^=. and V41 ^=. then V36_41 =0.5*(V36+V41);
	if V36 =. and V41 ^=. then V36_41 =V41;
	if V36 ^= . and V41 =. then V36_41 =V36;
	if V36 = . and V41 =. then V36_41 = .;
	if v60 in(1,2,3) then v60new=1;
	if v60=4 then v60new=2;
	if v60=5 then v60new=3;
	if v61 in(1,2,3)then v61new=1;
	if v61=4 then v61new=2;
	if v61=5 then v61new=3;
	if v260 in (1,2,3) then v260new=1;
	if v260=4 then v260new=2;
	if v260=5 then v260new=3;
	if v261 in(1,2,3) then v261new=1;
	if v261=4 then v261new=2;
	if V261=5 then v261new=3;
	if V78 = 0 then V78new=0; *American*;
	if V78 in (2,8,9,16) then V78new=1; *Black*;
	if V78 in (3,4,5,6,7,10, 11,12,19, 20,21, 50,51) then V78new=2; *Hispanic*;
	if v78 in (22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47) then V78new=3; *Asian*;
	if V78 in (15,17,18,52) then V78new=4; *Other,don't include White(1,13,14)*;
	if V21a = 0 then V21anew=0; *American*;
	if V21a in (6,7,8,11,16,17,20,21,23,73)then V21anew=1; *White*;
	if V21a in (59,64,76,77,82,83,84,88,103)then V21anew=2; *Black*;
	if V21a in (74,78,80,87,89,90,91,92,93,94,95,97,99,100,101,102,104,105,106,107,109)then V21anew=3; *Hispanic*;
	if V21a in (27,28,29,31,32,34,37,39,41,44,45,46,48,49,50,51,52,54)then V21anew=4; *Asian*;
	keep CASEID V61new V60new V261new V260new V19 V21anew V36_41 V78new V85 V86a V86b V86c;
	attrib V78new format=Nationf.;
	format V36_41 V36_41f.;
	format V21anew Nationf.;
	format v60new v61new v260new v261new outcomef.;
	label V36_41 = 'Average parents educational level';
	label v60new='Highest Education Level by Asipration at time one';
	label v61new='Highest Education Level by Expectation at time one';
	label V260new='Highest Education Level by Asipration at time two';
	label v261new='Highest Education Level by Expectation at time two';
	label V78new= 'How girl identify herself';
	label V21anew= 'Which area the respondent were born';
run;
**************************USE THE DATASET NEW FOR FURTHER ANALYSIS***********************;
***Descriptive Analysis ***;
proc means data=new NMISS N; run;
proc freq data=new; table V85 V86a V86b V86c; ; *v19 v21anew V61new V60new V261new V260new V36_41 V78new; run;
proc univariate data=new; 	var v21anew V61new V60new V261new V260new V36_41 V78new;run;
options nogstyle;
proc univariate data=new noprint;    histogram V61 V60 / normal;run;
***Check the correlations***;
proc corr data=new noprob; var V61new V60new V261new V260new V19 V21anew V36_41 V78new V85 V86a V86b V86c; run;
data temp;set new(keep=V61 V60 V260 V261);
	V60_260=V60-v260;
	V61_261=V61-V261;
	keep V60_260 V61_261;
run;
proc freq dat=temp;run;
***Check the difference trend from time point one to two***;
proc format;
	value VTrendf
	-1 = '(-1) The expectation is higher at the first time point and the aspiration is higher or the same at the second time point'
	0='(0) The expectation or aspiration are always higher at both time points'
	1 = '(1) The aspiration is higher at the first time point and the expectation is higher or the same at the second time point';
run;
Data temp;
	set new;
	if V61_60 > 0 and V261_260 =< 0 then VTrend =-1;
	if V61_60 ^=. and V261_260^=. and V61_60 * V261_260 > 0 then VTrend = 0;
	if V61_60 =0 and V261_260=0 then VTrend = 0;
	if V61_60 < 0 and V261_260 >= 0 then VTrend = 1;
	keep V61_60 V261_260 VTrend;
	format VTrend VTrendf.;
run;
proc freq data=temp;run;
proc format;
	value Binf
	-1='(-1)The expectation is lower than the aspiration'
	0='(0)The expectation equals to the aspiration'
	1='(1)The expectation is higher than the aspiration';
run;
data temp;
	set new;
	if V61_60 >0 then V61_60Bin=1;
	if V61_60 =0 then V61_60Bin=0;
	if V61_60^=. and V61_60 <0 then V61_60Bin=-1;
	if V261_260 >0 then V261_260Bin=1;
	if V261_260 =0 then V261_260Bin=0;
	if V261_260^=. and V261_260 <0 then V261_260Bin=-1;
	keep CASEID V261_260Bin V61_60Bin;
	format V61_60Bin V261_260Bin Binf.;
run; 
proc freq data=temp; 	table V61_60Bin * V261_260Bin; run;
***************Jun 16**************;
proc gplot data=longform; plot EducationExpectation*Time = V85;quit;
proc means data=new; where V85=2; var V261_260 V61_60; run;
***************************Jun 17*********************;
******** use dataset NEW for modelling*************;
*****Logistics Model Without Repeat Measurements***;
***Method One, two stages modelling****;
proc freq data=new; tables (V19 V21anew V36_41 V85 V61new V261new)*V78new/nopercent norow  ; run;
proc corr data=new ;
var V61new V261new V85 V78new V19 V21anew V36_41;
run;

proc logistic data=new desc;
class  V19 V21anew V36_41 V78new V85;
model V61new = V85;*V19 V21anew V36_41 V78new;
run;
**************For obs felt descrimination before*********;
data temp; set new; where V85=1; run;
proc logistic data=temp desc;
	class V19 V21anew V36_41 V78new V86a V86b V86c;
	model V261new =  V19 V21anew V36_41 V78new V86a V86b V86c;
run;
****Method Two, one step modelling***;
data FULL; set new;
	if V85 = 2 then 
		do; 
			V86a=2;
			V86b=2;
			V86c=2;
		end;

run;
proc means data=full NMISS N;
run;
proc logistic data=full desc covout outest=out;
class  V19 V21anew V36_41 V78new V85 V86a V86b V86c;
model V261new =V19 V21anew V36_41 V78new V86a V86b V86c ;
run;
proc logistic data=full desc ;
class  V19 V21anew V36_41 V78new V85 V86a V86b V86c;
model V61new V261new =V78new V85 V78new*V85 V19 V21anew V36_41  ;
run;

***********JUN 23*************;
**Bivariate Association**;
proc freq data=new;
 tables v78new* V19 / chisq ;*measures;
* plots=(freqplot(twoway=groupvertical scale=percent));
run;

*********JUN24******************************;
*********Use Dataset FULL, Longitudinal Analysis including V85 and V85*V78 new plus other covariates*****************;
******Data Transformation, wide form to long form***;
proc transpose data=full out=long;
	by caseid;
	copy V19 V21anew V36_41 V78new V85 V86a V86b V86c;
	var V61new V261new;
run;
data long;set long (rename=(col1=EducationExpectation));
	if _NAME_= 'v61new' then time=1;
	if _NAME_= 'v261new' then time=2;
	drop _NAME_ _LABEL_;
run;
data long; set long;
	retain V85old V19old V21anewold V36_41old V78newold V86aold V86bold V86cold;
	by caseid;
	if first.caseid then 
		do;  
			V85old=V85;
			V19old=V19 ;
			V21anewold=V21anew;
			V36_41old=V36_41;
			V78newold=V78new;
			V86aold=V86a;
			V86bold=V86b;
			V86cold=V86c;
		end;
	else 
		do;
			v85=v85old;
			V19=V19old;
			V21anew=V21anewold;
			V36_41=V36_41old;
			V78new=V78newold;
			V86a=V86aold;
			V86b=V86bold;
			V86c=V86cold;
		end;
	keep caseid V85 V86a V86b V86c V19 V21anew V36_41 V78new  time educationexpectation;
run;
proc print data=long(obs=20);run;
*proc MIXED data=long;
*	class time V85 V19 V21anew V78new  V36_41;
*	model educationexpectation = V85 V78new V78new*V85 V19 V21anew V36_41/noint solution covb;
*	repeated time/subject=caseid type=AR(1) ; *type=VC, CS, TOEP, AR(1) or UN;
*run;
***For categoical outcome, cannot use MIXED model, its or linear;
proc GLIMMIX data=long method=laplace noitprint noclprint;
	class time V85 V19 V21anew V78new  V36_41;
	*step one only intercept*;
	*model educationexpectation (desc) =  / s dist=multinomial link=cumlogit oddsratio (DIFF=LAST LABEL);
	*random intercept / subject=caseid;
	*step two, add level-1 variable time**;
	*model educationexpectation (desc) = time/ s dist=multinomial link=cumlogit oddsratio (DIFF=LAST LABEL);
	*random intercept / subject=caseid;
	*Step Three, add random slope to levl one variable*;
	*model educationexpectation (desc) = time/ s dist=multinomial link=cumlogit oddsratio (DIFF=LAST LABEL);
	*random intercept time/ subject=caseid;
	*Step Four, add level 2 variable to mdoel;
	model educationexpectation (desc) = time V85/ s dist=multinomial link=cumlogit oddsratio (DIFF=LAST LABEL);
	random intercept time/ subject=caseid;
	covtest/WALD;
run;
**Full Model*;
ods graphics on;
***************Final Model*****************;
*******************************************;
*******************************************;
*******************************************;
***************Final Model*****************;
proc GLIMMIX  data=long method=LAPLACE noitprint noclprint;
	class educationexpectation time V85 V19 V21anew V78new V36_41;
	model educationexpectation(desc)= V85 time V78new V19 V36_41 V78new*V85/ s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;

proc nlmixed data=long qpoints=100;
	parms B0=0 B1=0 B2=0 B3=0 B4=0 B5=0 B6=0 SD=1 THRES1=1 THRES2=1; 
	Z = B0 + B1*V85 + B2*V78new + B3*V85*V78new +B4*V36_41+ B5*V19+ B6*V21anew +B7*time + U;
	if (educationexpectation=1) then p=1/(1+EXP(-(0-z)));
	else if (educationexpectation=2) then p=(1/(1+exp(-(THRES1-Z))))- (1/(1 + exp(-(0-Z))));
	else if (educationexpectation=3) then P=(1/(1+exp(-(THRES1+THRES2-Z)))) - (1/(1 + EXP(-(THRES1-Z)))); 
	LL = LOG(P);
	MODEL educationexpectation ~ GENERAL(LL);
	RANDOM U~NORMAL(0,SD*SD) SUBJECT=caseid;
	ESTIMATE 'Threshold2' THRES1;
	ESTIMATE 'Threshold3' THRES1 + THRES2;
RUN; 
*******************JULY 08*****************;
*************COLLAPSE age and parents education level Then model again******************;
proc print data=new(obs=20);run;
proc freq data=new; tables v78new; run;
proc format;
	value agefff
	1='(1) early adolescence'
	2='(2) middle adolescence'
	3='(3) late adolescence';
	;
	value pefff 
	1='(1) some school'
	2='(2) high school graduate'
	3='(3) college graduate'
	;
run;
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
proc print data=new;where caseid =619;run;
proc print data=collapsed;where age=.;run;
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
proc sort data=long;
   by Estimate;
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

*********************Analysis by Karen's Suggestion*****************;
****1)Proc glimmix but delete the data has missing at time 2****;
data test; set collapsed;
where V261new ^=.;
run;
proc transpose data=test out=test;
	by caseid;
	copy  V78new V85 age ParentEdu ;
	var V61new V261new;
run;
data test;set test (rename=(col1=EducationExpectation));
	if _NAME_= 'v61new' then time=1;
	if _NAME_= 'v261new' then time=2;
	drop _NAME_ _LABEL_;
run;
data test; set test;
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
proc GLIMMIX  data=test method=LAPLACE noitprint noclprint;
	class V78new V85 age ParentEdu time educationexpectation caseid;
	model educationexpectation(desc)= V85 TIME V78new age ParentEdu / s dist=multinomial link=cumlogit oddsratio;* (DIFF=LAST LABEL);
	random intercept/subject=caseid;
	covtest/WALD;
run;

****2)ancova analysis**************;
*****. It tests a different hypothesis, which is concerning the equivalence of the time 2 values across classes of VP after adjusting 
for the time 1 value and the other 4 covariates.  There would be no "TIME" variable and no random statement. 
You will need to recode your dataset to one observation per ID. Your model statement would be as below and you would look at the type 3 p-value for VP.
model time2=time1 v1 v2 v3 v4 vp;;
proc GLIMMIX data=collapsed ;
class  AGE ParentEdu V78new V85;
model V261new(desc)=V61new age V78new ParentEdu V85/ s dist=multinomial link=cumlogit;
run;
 
title1 'Model1';
proc logistic data=long desc;
class  AGE ParentEdu time V78new V85;
model educationexpectation=  V85;
run;

title1 'Model2';
proc logistic data=long desc;
class  AGE ParentEdu time V78new V85;
model educationexpectation= V85 time;
run;

title1 'Model3';
proc logistic data=long desc;
class  AGE ParentEdu time V78new V85;
model educationexpectation= V85 time AGE ParentEdu V78new ;
run;

title1 'Model4';
proc logistic data=long desc;
class  AGE ParentEdu time V78new V85;
model educationexpectation= V85 time AGE ParentEdu  V78new*V85;
run;

title1 'Model5';
proc logistic data=long desc;
class  AGE ParentEdu time V78new V85;
model educationexpectation= V85 time AGE ParentEdu  V78new*ParentEdu;
run;

title1 'Model6';
proc logistic data=long desc;
class  AGE ParentEdu time V78new V85;
model educationexpectation= V85 time AGE ParentEdu  AGE*ParentEdu;
run;
ods rtf close;
