/********************************************************************
* Job Name: 3_crohns_max_taf_rate_merge_CD_w_eligibility_prep.sas
* Job Desc: Job to identify Crohns/UC/IBD Medicaid Patients
by combining the info from the Medicaid denominator (all Medicaid,
IBD hospitalizations and IBD outpatient encounters).
Final dataset is 1 record per person ready for exclusions to
make a study-specific cohort--it includes all MBSF data--no need to go back 
	to medicare eligibility for any study
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab
********************************************************************
* Longer Desc:
* Create Crohns Disease & Ulcerative Colitis (=All IBD) Cohort
********************************************************************/


/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;   /** libname prefix **/
%global pat_idb clm_id                       ;
%global pat_id                               ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

%let  pat_idb            = bene_id  state_cd msis_id           ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;


    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

/** required data - denominator info for 100% of Medicaid patients **/
%global in_ds_denom           ;
%let in_ds_denom         = &shlib..max_denom_2010_19;*this includes max and taf data, all medicaid;

%global flag_cd flag_uc  flag_ibd flag_cd_prop;
%let flag_cd             = cd ;
%let flag_uc             = uc ;
%let flag_ibd            = ibd;
%let flag_cd_prop        = cd_prop;

%global age; /*need generic here because used in IP and OP--this program makes cd_first_age which is var for analysis*/
%global clm_beg_dt clm_end_dt clm_state;
%let  age                = age           ;
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_state          = state_cd      ; 

/*** end of section   - global vars ***/

/*** start of section - OUTPUT permanent dataset ready for inclusion/exclusion analysis ***/
/***this is a 1 record per person file***/
%let outds = &shlib..&proj_ds_pfx.cd_cohort_2010_19 ; *labeling max even though it is all mdcd now;  
/*** end of section   - OUTPUT DS NAMES ***/


/*** start section - IBD cohort prep and merge of IP OP ***/
/*** start section - IBD cohort prep and merge of IP OP ***/
/*** start section - IBD cohort prep and merge of IP OP ***/

%global tmp_job_pfx;
%let    tmp_job_pfx = tmp_rmg_; /** prefix used to quickly* identify
                                    data this job works with
                                    leave the trailing underscore
									*rmg stands for rate merge**/

%global temp_ds_all_clms  ;
%let    temp_ds_all_clms  = &lwork..&tmp_job_pfx.cd2      ;
%global temp_ds_cd_cnt    ;
%global temp_ds_uc_cnt    ;
%global temp_ds_ibd_cnt   ;
%let    temp_ds_cd_cnt    = &lwork..&tmp_job_pfx.cd       ;
%let    temp_ds_uc_cnt    = &lwork..&tmp_job_pfx.uc       ;
%let    temp_ds_ibd_cnt   = &lwork..&tmp_job_pfx.ibd      ;
%global temp_ds_cduc      ;
%let    temp_ds_cduc      = &lwork..&tmp_job_pfx.cduc     ;
%global temp_ds_cd_last   ;
%let    temp_ds_cd_last   = &lwork..&tmp_job_pfx.cd_last  ;
%global temp_ds_cd_first  ;
%let    temp_ds_cd_first  = &lwork..&tmp_job_pfx.cd_first ;
%global temp_ds_uc_last   ;
%let    temp_ds_uc_last   = &lwork..&tmp_job_pfx.uc_last  ;
%global temp_ds_uc_first  ;
%let    temp_ds_uc_first  = &lwork..&tmp_job_pfx.uc_first ;
%global temp_ds_cohort    ;
%let    temp_ds_cohort    = &lwork..&tmp_job_pfx.cd_cohort;
%global temp_ds_denom     ;
%let    temp_ds_denom     = &lwork..&tmp_job_pfx.tmp_denom;


/* merge inpatient and outpatient diagnoses together--then count cd claims **/
data &temp_ds_all_clms (drop = el_dob birth_dt plc_of_srvc_cd pos_cd);
    set
        &shlib..max_cd_ot_2010_15 (in=opmax)
        &shlib..max_cd_ip_2010_15 ( in=ipmax)
		&shlib..taf_cd_ot_2014_19 ( in=optaf)
        &shlib..taf_cd_ip_2014_19 ( in=iptaf)
    ;

/*round age up to 2 digits*/
    age_round=round(&age);
    drop age;
    rename age_round = &age;

if &clm_beg_dt =. then &clm_beg_dt = &clm_end_dt;
if &clm_end_dt =. then &clm_end_dt = &clm_beg_dt;

/** manually identified those with srvc begin date<2010 that were likely data entry errors **/
if &clm_beg_dt ='01apr2000'd then &clm_beg_dt ='01apr2010'd;
if &clm_beg_dt ='24oct2002'd then &clm_beg_dt ='24oct2012'd;

/**delete those in 2009 (before 2010) and greater than 2019**/
if &clm_beg_dt < '01jan2010'd then delete;
if &clm_beg_dt > '31dec2019'd then delete;

/**if begining date is later than end date, set to same**/
if &clm_beg_dt > &clm_end_dt then &clm_beg_dt = &clm_end_dt;

/*rename vars that differ in max and taf*/
if el_dob ne . then do; dob=el_dob; end;
if birth_dt ne . then do; dob=birth_dt; end;
label yr_num='year of claim--not specific to any anchor';
if yr_num=. then do; yr_num=year(&clm_end_dt);end;
if yr_num=. then do; yr_num=year(&clm_beg_dt);end;
if pos_cd ne ' ' then do; plc_srvc_cd=pos_cd; end;
if plc_of_srvc_cd ne ' ' then do; plc_srvc_cd=plc_of_srvc_cd; end;
if age=. then do;
	age=&clm_beg_dt-dob;
end;
if age=. then do;
	age=&clm_end_dt-dob;
end;
format dob date9.;
/*clean up missing identifiers make common 1 so can dedupe by id*/
if bene_id = . and msis_id=' ' then delete;
*make var that combines identifiers for first. counting;
bene_msis_st_id=catx('|',bene_id,msis_id, state_cd);
run;
proc print data=&temp_ds_all_clms (obs=10);
*where age=.;
run;
proc freq data=&temp_ds_all_clms; where dob=.;
table yr_num;
run;

proc means nmiss data=&temp_ds_all_clms;
run;

/* count unique days with cd (=crohn's disease) and  uc (=ulcerative colitis) */
proc sort data=&temp_ds_all_clms  nodupkey;
by bene_msis_st_id &pat_id &clm_beg_dt &flag_cd &flag_uc;
run;


/** gets pat by date ttl uc cd for prep on ibd **/
proc summary data= &temp_ds_all_clms nway;
class bene_msis_st_id &pat_id &clm_beg_dt;
var &flag_cd;
var &flag_uc;
output out= &temp_ds_ibd_cnt (drop=_type_ _freq_)
    sum(&flag_cd)=&flag_cd._count
    sum(&flag_uc)=&flag_uc._count
    ;
run;

/** some have counts=2 (more than 1 row on same day), set back to 1
    & make indicator for IBD **/
data &temp_ds_ibd_cnt;
 set &temp_ds_ibd_cnt;
    if &flag_cd._count ge 2 then &flag_cd._count = 1;
    if &flag_uc._count ge 2 then &flag_uc._count = 1;
    &flag_ibd._count=0;
    if &flag_cd._count = 1 or
       &flag_uc._count = 1 then do;
       &flag_ibd._count=1;
    end;
run;

%macro counts (flagfileout=, flagin=, flagout=);
/*there should be no duplicates when this proc sort is run
    --if duplicates are deleted there is a problem above*/
proc sort data=&temp_ds_ibd_cnt nodupkey;
by bene_msis_st_id &clm_beg_dt ;
run;

data &flagfileout (keep = &pat_id bene_msis_st_id &flagout);
set &temp_ds_ibd_cnt ;
by bene_msis_st_id &clm_beg_dt;
where &flagin=1;

if first.bene_msis_st_id then &flagout = 0; &flagout + 1;
if last.bene_msis_st_id then output;
run;

proc freq data= &flagfileout ;
table &flagout;
run;
*%field_numbers(inds=&flagfileout , vartochk= &flagout);
%mend;

%counts(flagfileout=&temp_ds_cd_cnt , flagin=&flag_cd._count , flagout=&flag_cd._count2 );
%counts(flagfileout=&temp_ds_uc_cnt , flagin=&flag_uc._count , flagout=&flag_uc._count2 );
%counts(flagfileout=&temp_ds_ibd_cnt, flagin=&flag_ibd._count, flagout=&flag_ibd._count2);


data &temp_ds_cduc (keep=&pat_id bene_msis_st_id
                        &flag_cd._count2
                        &flag_uc._count2
                        &flag_cd_prop
                        &flag_ibd._count2
                        );
merge
&temp_ds_uc_cnt
&temp_ds_cd_cnt
&temp_ds_ibd_cnt
;
by bene_msis_st_id;
if &flag_cd._count2  =. then &flag_cd._count2=0;
if &flag_uc._count2  =. then &flag_uc._count2=0;
if &flag_ibd._count2 =. then &flag_ibd._count2=0;
&flag_cd_prop       = &flag_cd._count2 / &flag_ibd._count2;
run;

proc means data=&temp_ds_cduc  n mean median p25 p75 min max;
var
&flag_cd_prop
&flag_cd._count2
&flag_uc._count2
&flag_ibd._count2
;
run;

/**
    Keep info about the first & last encounters for CD and UC
    for eligibility & general checks first vs last encounter **/

proc sort data=&temp_ds_all_clms;
by bene_msis_st_id &clm_end_dt;
run;

%macro firstlast (out=, firstlast=, flag=, date=, prefix=);
data &out
             (keep = &pat_id bene_msis_st_id
                     &prefix:
                      );
set
&temp_ds_all_clms   ;
by bene_msis_st_id;
where &flag=1;
if &firstlast..bene_msis_st_id;
    &prefix=1;
    &prefix._dt              = &date; format &prefix._dt date9.;
    *&prefix._elgblty_cd_max  = el_max_elgblty_cd_ltst;
    *&prefix._elgblty_cd_ss   = el_ss_elgblty_cd_ltst;
    *&prefix._gender          =&clm_gender;
    *&prefix._race            =&clm_race;
    &prefix._age             =&age;
    &prefix._yr	             =yr_num;
    &prefix._plc_of_srvc_cd  =plc_srvc_cd;
    &prefix._clm_state       =&clm_state;
	if &firstlast..bene_msis_st_id then output;
run;

proc sort data=&temp_ds_cd_last;
by bene_msis_st_id;
run;

%mend;

%firstlast (out=&temp_ds_cd_last , firstlast=last , flag=&flag_cd, date=&clm_end_dt, prefix=cd_last );
%firstlast (out=&temp_ds_cd_first, firstlast=first, flag=&flag_cd, date=&clm_beg_dt, prefix=cd_first);
%firstlast (out=&temp_ds_uc_last , firstlast=last , flag=&flag_uc, date=&clm_end_dt, prefix=uc_last );
%firstlast (out=&temp_ds_uc_first, firstlast=first, flag=&flag_uc, date=&clm_beg_dt, prefix=uc_first);

*merge first, last and counts together;
proc sort data=&temp_ds_cduc;
by bene_msis_st_id;
run;

data &temp_ds_cohort (drop =
                             cd_first
                             cd_last
                             uc_first
                             uc_last);
merge
&temp_ds_cduc
&temp_ds_cd_last
&temp_ds_uc_last
&temp_ds_cd_first
&temp_ds_uc_first
;
by bene_msis_st_id;
    cd_fup       =intck("years", cd_first_dt, cd_last_dt  );
    *https://www.resdac.org/sites/resdac.umn.edu/files/Place%20of%20Service%20Code%20Table.txt;
    *inpatient=21;
    *&clm_gender  = cd_first_gender;
    *&clm_race    = cd_first_race  ;
    rename cd_count2 = cd_count;
    rename uc_count2 = uc_count;
    rename ibd_count2= ibd_count;
    label cd_count         ='number of unique dates with a CD encounter';
    label cd_first_clm_state='state where received medicaid benefit for first CD date';
    label cd_first_plc_of_srvc_cd='place of service for first CD date';
    label cd_fup           ='time between last date with a CD code and first date with a CD code in years, no accounting for gaps in coverage';
    label cd_first_dt      ='first date of CD diagnosis in medicaid data, not the incident date';
    *label cd_first_gender  = 'gender for first CD date';
    *label cd_first_race    = 'race ethnicity code for first CD date';
    label cd_first_age     ='age at first encounter for CD';
    label cd_first_yr      ='calendar year of first encounter for CD';
    *label cd_first_elgblty_cd_max ='eligibility code for Medicaid for first CD encounter from MAX eligiblity (el_max_elgblty_cd_ltst)';
    *label cd_first_elgblty_cd_ss  ='eligibility code for Medicaid for first CD encounter from Social Security eligibility (el_ss_elgblty_cd_ltst)';
ibd_first_dt =min(cd_first_dt, uc_first_dt);
ibd_last_dt  =max(cd_last_dt , uc_last_dt);
    label cd_last_dt       ='Date of last CD encounter';
    label uc_last_dt       ='Date of last UC encounter';
    label ibd_last_dt      ='Date of last IBD encounter';
    label ibd_first_dt     ='Date of first IBD encounter';
    label cd_prop          ='proportion of all IBD encounters that were for CD';
  if 0<cd_first_age <  18 then cd_first_age_lt18 =1;
     else cd_first_age_lt18 =0;
    label cd_first_age_lt18 ='Age first CD less than 18 years old';
  if cd_first_age >= 65 then cd_first_age_gt65 =1;
     else cd_first_age_gt65 =0;
    label cd_first_age_gt65 ='Age first CD greater than or equal to 65 years old';
/*make a new variable for gender;
  if cd_first_gender in('M','F') then cd_gender=cd_first_gender;
  if uc_first_gender in('M','F') then cd_gender=uc_first_gender;
  if cd_gender = ' ' then do;
    if cd_last_gender in('M','F') then cd_gender=cd_last_gender;
    if uc_last_gender in('M','F') then cd_gender=uc_last_gender;
  end;
    label cd_gender='indicator of gender from IBD cohort (gender is for CD and UC patients';
    format cd_first_elgblty_cd_max  $elig.     ;
    format cd_first_plc_of_srvc_cd  plcsrvc.   ;*/
run;
*do checks of first vs last;

proc freq data=&temp_ds_cohort;
table cd_first_clm_state*cd_last_clm_state
      /*cd_first_gender*cd_last_gender
      cd_gender*/ cd_first_plc_of_srvc_cd
		cd_first_yr ;
run;

proc sort data=&temp_ds_cohort;
by bene_msis_st_id ;
run;

proc sort data=&temp_ds_cohort
           out=&temp_ds_cohort      nodupkey;
by bene_msis_st_id;
run;

/*** END section - IBD cohort prep and merge of IP OP ***/
/*** END section - IBD cohort prep and merge of IP OP ***/
/*** END section - IBD cohort prep and merge of IP OP ***/


/*** START section - PS merge w IBD patients for Denom Elig ***/
/*** START section - PS merge w IBD patients for Denom Elig ***/

*need to link to medicaid enrollment file (shu172.maxdata_ps_2014) to assess eligibility for medicaid;
*https://www.resdac.org/cms-data/files/max-ps;
*https://support.sas.com/resources/papers/proceedings/proceedings/sugi29/260-29.pdf;
*https://www.lexjansen.com/wuss/2012/103.pdf;
*goal: make 1 file that has 1 record per bene_ id 
wih the first Medicaid start and stop date (for entire period 2010-2019);

/* calculate fup---use the medicaid eligibility */
/* calculate time before first CD code and time
   from first CD code to end of elgibility      */
/* can calculate first and last CD dates too as
   a secondary item to examine                  */
/*there should be no duplicates if--if there are, there is a problem*/

proc sort data=&in_ds_denom  NODUPKEY out=&temp_ds_denom ;
by &pat_id;
run;

proc sort data=&temp_ds_cohort   NODUPKEY out=&temp_ds_cohort ;
by &pat_id;
run;
/** this dataset is IBD patients only **/
data &lwork..&tmp_job_pfx.cd_enc_2010_19   ;
  merge
  &temp_ds_cohort           (in=a)
  &temp_ds_denom            (in=b)
  ;
  by &pat_id;
  if a;
  on_denom=0;
  if a and b then do;
  	on_denom=1;
  	label on_denom='indicator that IBD patient linked to denom file';
  end;
  fup_b4_CD    =(cd_first_dt - elig_start_dt)/365.25; label fup_b4_cd    ='time between first Medicaid eligibility and CD diagnosis';
  fup_after_CD =(elig_end_dt - cd_first_dt  )/365.25; label fup_after_cd ='time between last medicaid eligibility (90d gap) and CD diagnosis';
  /* 444 missing all eligibility info */
  if elig_start_dt=. and elig_end_dt=. then do;
      fup_b4_cd=0; fup_after_cd=0;
  end;
    if cd_count>=1 then do;
        if cd_first_dt <="01jul2010"d <=elig_end_dt then do;
			cd_prev_year_2010=1; cd_prev_age_2010=intck("years",(den_dob),  "01jul2010"d  );
		end;
	end;
    if cd_count>=1 then do;
        if cd_first_dt <="01jul2011"d <=elig_end_dt then do;
			cd_prev_year_2011=1; cd_prev_age_2011=intck("years",(den_dob),  "01jul2011"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2012"d <=elig_end_dt then do;
			cd_prev_year_2012=1; cd_prev_age_2012=intck("years",(den_dob),  "01jul2012"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2013"d <=elig_end_dt then do;
			cd_prev_year_2013=1; cd_prev_age_2013=intck("years",(den_dob),  "01jul2013"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2014"d <=elig_end_dt then do;
			cd_prev_year_2014=1; cd_prev_age_2014=intck("years",(den_dob),  "01jul2014"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2015"d <=elig_end_dt then do;
			cd_prev_year_2015=1; cd_prev_age_2015=intck("years",(den_dob),  "01jul2015"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2016"d <=elig_end_dt then do;
			cd_prev_year_2016=1; cd_prev_age_2016=intck("years",(den_dob),  "01jul2016"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2017"d <=elig_end_dt then do;
			cd_prev_year_2017=1; cd_prev_age_2017=intck("years",(den_dob),  "01jul2017"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2018"d <=elig_end_dt then do;
			cd_prev_year_2018=1; cd_prev_age_2018=intck("years",(den_dob),  "01jul2018"d  );
		end;
	end;
	if cd_count>=1 then do;
        if cd_first_dt <="01jul2019"d <=elig_end_dt then do;
			cd_prev_year_2019=1; cd_prev_age_2019=intck("years",(den_dob),  "01jul2019"d  );
		end;
	end;
        label cd_prev_year_2010 = "indicator that person had Crohn on July 1 2010 (Prevalent)";
		label cd_prev_age_2010 = "age of person with Crohn on July 1 2010 (Prevalent)";
        label cd_prev_year_2011 = "indicator that person had Crohn on July 1 2011 (Prevalent)";
        label cd_prev_year_2012 = "indicator that person had Crohn on July 1 2012 (Prevalent)";
        label cd_prev_year_2013 = "indicator that person had Crohn on July 1 2013 (Prevalent)";
        label cd_prev_year_2014 = "indicator that person had Crohn on July 1 2014 (Prevalent)";
        /*identify incidence crohn disease for year calculations*/
        if "01jan2010"d <=cd_first_dt <="31dec2010"d then cd_inc_year_2010=1;
        if "01jan2011"d <=cd_first_dt <="31dec2011"d then cd_inc_year_2011=1;
        if "01jan2012"d <=cd_first_dt <="31dec2012"d then cd_inc_year_2012=1;
        if "01jan2013"d <=cd_first_dt <="31dec2013"d then cd_inc_year_2013=1;
        if "01jan2014"d <=cd_first_dt <="31dec2014"d then cd_inc_year_2014=1;
		if "01jan2015"d <=cd_first_dt <="31dec2015"d then cd_inc_year_2015=1;
		if "01jan2016"d <=cd_first_dt <="31dec2016"d then cd_inc_year_2016=1;
		if "01jan2017"d <=cd_first_dt <="31dec2017"d then cd_inc_year_2017=1;
		if "01jan2018"d <=cd_first_dt <="31dec2018"d then cd_inc_year_2018=1;
		if "01jan2019"d <=cd_first_dt <="31dec2019"d then cd_inc_year_2019=1;
        label cd_inc_year_2010 ="indicator that person had first Crohn dx in 2010 (Incident)";
        label cd_inc_year_2011 ="indicator that person had first Crohn dx in 2011 (Incident)";
        label cd_inc_year_2012 ="indicator that person had first Crohn dx in 2012 (Incident)";
        label cd_inc_year_2013 ="indicator that person had first Crohn dx in 2013 (Incident)";
        label cd_inc_year_2014 ="indicator that person had first Crohn dx in 2014 (Incident)";
run;

/*fill in missing denom info with CD info to minimize CD exclusions*/
data  &outds (drop= cd_dob) ;
 set &lwork..&tmp_job_pfx.cd_enc_2010_19;
 if cd_gender=' ' then do;
     if den_gender in('M','F') then cd_gender=den_gender;
 end;
 den_gender=cd_gender;
 cd_dob=cd_first_dt-(cd_first_age*365.25);
 if den_dob = . then den_dob=cd_dob;
 if den_age_first = . then den_age_first=cd_first_age;
run;

/* this permanent dataset includes all IBD info and denom info*/
/* no age restrictions, no number CD/IBD encounters restrictions, no fup restrictions
        --make these restrictions in each cohort*/
proc means nmiss data= &outds ;
run;

proc freq data= &outds ;
table cd_count;
run;

/*** performing clean up of tables that are no longer needed ***
proc datasets lib=&lwork noprint;
delete  &tmp_job_pfx.:;
quit;
run;
