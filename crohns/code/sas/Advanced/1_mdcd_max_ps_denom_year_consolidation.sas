/********************************************************************
* Job Name: 1_mdcd_max_ps_denom_year_consolidation.sas
* Job Desc: Job to identify Medicaid Patients to Use as Denominator
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab
********************************************************************
* Longer Desc:
* Create Medicaid Denominator File with demographic information
* to use when calculating rates  -- This file includes 100% Medicaid patients
* Current time frame is 2010-2019
*Final output file has 1 record per bene_id / msis_id state_cd wih the first start and stop date
(for entire period 2010-2019)
--IMPORTNAT NOTE::::::the 2014 version uses 2014 only
********************************************************************/
/*Useful resources for this program:
*https://www.resdac.org/cms-data/files/max-ps;
*https://support.sas.com/resources/papers/proceedings/proceedings/sugi29/260-29.pdf;
*https://www.lexjansen.com/wuss/2012/103.pdf;
;

/** ALERT!!!! - the job and settings in 0_setup_facts.sas must be set first
				if you don't run 0_ programs this program will not run **/


/*** start of section to set up locations/variables used in program
		- global vars, prefixing, libraries, datasets, variables ***/

/*** libname prefix alias assignments ***/
%global lwork ltemp shlib                    ;   
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

    /*** assign lets to libraries/datasets ***/
    %global mps2010 ; 
    %global mps2011 ;
    %global mps2012 ;
    %global mps2013 ;
    %global mps2014 ;
	%global mps2015 ;
	%global mps2016 ;
	%global mps2017 ;
	%global mps2018 ;
	%global mps2019 ;

    %let mps2010 = max2010.maxdata_ps_2010;
    %let mps2011 = max2011.maxdata_ps_2011;
    %let mps2012 = max2012.maxdata_ps_2012;
    %let mps2013 = max2013.maxdata_ps_2013;
    %let mps2014 = max2014.maxdata_ps_2014;
	%let mps2015 = max2015.maxdata_ps_2015;
	%let mps2016 = tafr16.demog_elig_base;
	%let mps2017 = tafr17.demog_elig_base;
	%let mps2018 = tafr18.demog_elig_base;
	%let mps2019 = tafr19.demog_elig_base;


    %global short_term_ds_mps_2010 ;
    %global short_term_ds_mps_2011 ;
    %global short_term_ds_mps_2012 ;
    %global short_term_ds_mps_2013 ;
    %global short_term_ds_mps_2014 ;
	%global short_term_ds_mps_2015 ;
	%global short_term_ds_mps_2016 ;
	%global short_term_ds_mps_2017 ;
	%global short_term_ds_mps_2018 ;
	%global short_term_ds_mps_2019 ;
    %global out_ds_all_elig        ;
    %global out_ds_fst_elig        ;

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_psd_;  /*** prefix to identify temp data
                                          leave the trailing underscore ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/
									/***MAX is for Medicaid MAX files***/

    %let short_term_ds_mps_2010 = &lwork..&temp_ds_pfx.elig2010;
    %let short_term_ds_mps_2011 = &lwork..&temp_ds_pfx.elig2011;
    %let short_term_ds_mps_2012 = &lwork..&temp_ds_pfx.elig2012;
    %let short_term_ds_mps_2013 = &lwork..&temp_ds_pfx.elig2013;
    %let short_term_ds_mps_2014 = &lwork..&temp_ds_pfx.elig2014;
	%let short_term_ds_mps_2015 = &lwork..&temp_ds_pfx.elig2015;
	%let short_term_ds_mps_2016 = &lwork..&temp_ds_pfx.elig2016;
	%let short_term_ds_mps_2017 = &lwork..&temp_ds_pfx.elig2017;
	%let short_term_ds_mps_2018 = &lwork..&temp_ds_pfx.elig2018;
	%let short_term_ds_mps_2019 = &lwork..&temp_ds_pfx.elig2019;
    %let out_ds_all_elig        = &lwork..&proj_ds_pfx.elig_2010_19;
    %let out_ds_fst_elig        = &lwork..&temp_ds_pfx.fst_elig_2010_19;

/*** start of section - OUTPUT DS NAMES---this is name of PERMANENT dataset ***/
/**OTHER PROGRAMS THAT RELY ON THIS PROGRAM WILL USE THIS DATASET NAME!!!!***/
%let outds_2010_2019 = &shlib..&proj_ds_pfx.DENOM_2010_19 ;

/*identify variables for program*/
%global pat_id                               ;
%global src_den_dob     ;
%global src_state_cd    ;
%global src_dod         ;
%global src_sex_cd      ;
%global src_race_eth_cd ;
%global src_el_mo_cnt   ;
%global src_res_county  ;
%global src_res_zip     ;
%global src_ss_el       ;
%global src_max_el      ;
%global src_race_pfx    ;
%global src_el_day_pfx  ;
%global den_zip			;
%global den_county		;

*vars need to change in taf to do max and taf:
max					taf
el_dob				birth_dt
el_dod  			death_dt
el_sex_cd			sex_cd
el_race_ethncy_cd 	race_ethncy_cd
el_elgblty_mo_cnt	no equivalent mdcd_enrlmt_days_yr is closest
el_rsdnc_cnty_cd_ltst bene_cnty_cd	
el_rsdnc_zip_cd_ltst bene_zip_cd
el_ss_elgblty_cd_ltst state_spec_elgblty_grp_cd_ltst
el_max_elgblty_cd_ltst no equivalent closest is elgblty_grp_cd_ltst
race_code_ 			no equivalent in taf, there is an expanded race cd: race_ethncty_exp_cd
el_days_el_cnt_		mdcd_enrlmt_days_
;
						/*on right hand side are variables in our source datasets*/
%let  pat_idb            = bene_Id msis_id state_cd           ;*same in taf;
%let  pat_id             = &pat_idb          ;
%let  src_den_dob        = el_dob                 ;*birth_dt in taf;
%let  src_state_cd       = state_cd               ;*same in taf;
%let  src_den_dod        = el_dod                 ;*death_dt in taf;
%let  src_sex_cd         = el_sex_cd              ;*sex_cd in taf;
%let  src_race_eth_cd    = el_race_ethncy_cd      ;*race_ethncty_cd in taf;
%let  src_el_mo_cnt      = el_elgblty_mo_cnt      ;*mdcd_enrlmt_days_yr in closest in taf ;
%let  src_res_county     = el_rsdnc_cnty_cd_ltst  ;*bene)cnty_cd;
%let  src_res_zip        = el_rsdnc_zip_cd_ltst   ;*bene_zip_cd;
%let  src_ss_el          = el_ss_elgblty_cd_ltst  ;*state_spec_elgblty_grp_cd_ltst;
%let  src_max_el         = el_max_elgblty_cd_ltst ;*elgblty_grp_cd_ltst in taf is closest;
%let  src_race_pfx       = race_code_             ;*no equivalent in taf, there is an expanded race cd: race_ethncty_exp_cd;
%let  src_el_day_pfx     = el_days_el_cnt_        ;*mdcd_enrlmt_days_;

%let  den_zip            = den_zip       ;
%let  den_county         = den_county    ;
%let start_yr        = start_yr        ;
%let elig_month_flag = elig_month_flag ;
%let elig_start_dt   = elig_start_dt   ;
%let nvar_el_days    = elig_days_10_19 ;*elig_days_10_15 with max, 19 when use taf;
%let elig_end_flag   = elig_end_flag   ;
%let end_yr	         = end_yr       ;
%let elig_end_dt     = elig_end_dt     ;
%let fup_medicaid    = fup_medicaid    ;

/*rather than using keep = in program can set up the keep,drop here below our variables %lets*/
%global src_denom_keep_vars src_denom_keep_vars_taf;
%let    src_denom_keep_vars = &pat_id
                              &src_den_dob
                              &src_den_dod
                              &src_sex_cd
                              &src_race_eth_cd
                              &src_el_mo_cnt
							  &src_state_cd:
                              &src_res_county:
                              &src_res_zip:
                              &src_ss_el:
                              &src_max_el:
                              &src_race_pfx.:
                              &src_el_day_pfx.:
                              ;

/*** end of section   - global vars ***/

/*** START section - Read in Person Summary (PS) for Eligibility ***/
/*** START section - PS for Elig ***/
%macro year(tmp_ds_in  =,
            tmp_ds_out =,
            tmp_year   =,
            tmp_ren_min=,
            tmp_ren_max=
            );
	data &tmp_ds_out (keep= _all_); length &den_county 5.;
	    set &tmp_ds_in  (keep= &src_denom_keep_vars  );
	        den_year_&tmp_year         = 1 ;
	        rename &src_den_dob        = den_dob              ;
	        rename &src_den_dod        = den_dod              ;
	        rename &src_race_pfx.1     - &src_race_pfx.5      =
	                den_race_1         - den_race_5;
	        rename &src_sex_cd         = den_gender           ;
	        rename &src_race_eth_cd    = den_race_eth_cd      ;
					*format &src_race_eth_cd         $race_eth. ;
	        rename &src_el_day_pfx.1   - &src_el_day_pfx.12   =
	               mdcd_enrlmt_days_&tmp_ren_min               -
	               mdcd_enrlmt_days_&tmp_ren_max               ;
	        el_elgblty_mo_cnt_&tmp_year 	 = &src_el_mo_cnt       ;
			den_state_cd_&tmp_year 			 = &src_state_cd        ;
			den_state_cd    				 = &src_state_cd	    ;
	        el_rsdnc_cnty_cd_ltst_&tmp_year  = &src_res_county      ;
	        el_rsdnc_zip_cd_ltst_&tmp_year 	 = &src_res_zip         ;	 
	        el_ss_elgblty_cd_ltst_&tmp_year  = &src_ss_el  			;
	        el_max_elgblty_cd_ltst_&tmp_year = &src_max_el			;
			               &den_zip          = &src_res_zip;
             			   &den_county       = &src_res_county*1;
	run;
	/* some duplicates (less than 100 per year when use MSIS & BENE)
			thousands of duplicates when use BENE only because many
			rows have MSIS but do NOT have BENE
	   --no easy way to tell which is the correct row for MSIS/BENE so sorting nodupkey **/
	proc sort data=&tmp_ds_out  nodupkey;
	by &pat_id;
	run;
%mend;


%year(tmp_ds_in  = &mps2010,
      tmp_ds_out = &short_term_ds_mps_2010,
      tmp_year   = 2010,
      tmp_ren_min= 1,
      tmp_ren_max= 12);
/*we need to relabel each month for the entire study period
	  to assess month on month eligiblity--so 1st month year is relabeled to 13
	  for the 2nd calendar year of the study period*/
%year(tmp_ds_in  = &mps2011,
      tmp_ds_out = &short_term_ds_mps_2011,
      tmp_year   = 2011,
      tmp_ren_min= 13,
      tmp_ren_max= 24);

%year(tmp_ds_in  = &mps2012,
      tmp_ds_out = &short_term_ds_mps_2012,
      tmp_year   = 2012,
      tmp_ren_min= 25,
      tmp_ren_max= 36);

%year(tmp_ds_in  = &mps2013,
      tmp_ds_out = &short_term_ds_mps_2013,
      tmp_year   = 2013,
      tmp_ren_min= 37,
      tmp_ren_max= 48);

%year(tmp_ds_in  = &mps2014,
      tmp_ds_out = &short_term_ds_mps_2014,
      tmp_year   = 2014,
      tmp_ren_min= 49,
      tmp_ren_max= 60);

%year(tmp_ds_in  = &mps2015,
      tmp_ds_out = &short_term_ds_mps_2015,
      tmp_year   = 2015,
      tmp_ren_min= 61,
      tmp_ren_max= 72);

*TAF files use slightly different variables than MAX--rename;
						/*on right hand side are variables in our source datasets*/
%let  pat_idb            = bene_Id msis_id state_cd           ;*same in taf;
%let  pat_id             = &pat_idb          ;
%let  src_den_dob        = birth_dt                 ;*birth_dt in taf;
%let  src_state_cd       = state_cd               ;*same in taf;
%let  src_den_dod        = death_dt                 ;*death_dt in taf;
%let  src_sex_cd         = sex_cd              ;*sex_cd in taf;
%let  src_race_eth_cd    = race_ethncty_cd      ;*race_ethncty_cd in taf;
*%let  src_el_mo_cnt      = mdcd_enrlmt_days_yr      ;*mdcd_enrlmt_days_yr is closest in taf ;
%let  src_res_county     = bene_cnty_cd  ;*bene_cnty_cd;
%let  src_res_zip        = bene_zip_cd  ;*bene_zip_cd;
%let  src_ss_el          = state_spec_elgblty_grp_cd_ltst  ;*state_spec_elgblty_grp_cd_ltst;
%let  src_max_el         = elgblty_grp_cd_ltst ;*elgblty_grp_cd_ltst in taf is closest;
*%let  src_race_pfx       = race_code_             ;*no equivalent in taf, there is an expanded race cd: race_ethncty_exp_cd;
%let  src_el_day_pfx     = mdcd_enrlmt_days_        ;*mdcd_enrlmt_days_;

%let    src_denom_keep_vars_taf = &pat_id
                              &src_den_dob
                              &src_den_dod
                              &src_sex_cd
                              &src_race_eth_cd
                              /*&src_el_mo_cnt*/ mdcd_enrlmt_days_yr
							  &src_state_cd:
                              &src_res_county:
                              &src_res_zip:
                              &src_ss_el:
                              &src_max_el:
                              /*&src_race_pfx.:*/
                              &src_el_day_pfx.:
                              ;

%macro year_taf(tmp_ds_in  =,
            tmp_ds_out =,
            tmp_year   =,
            tmp_ren_min=,
            tmp_ren_max=
            );
	data &tmp_ds_out (keep= _all_); length &den_county 5.;
	    set &tmp_ds_in  (keep= &src_denom_keep_vars_taf  );
	        den_year_&tmp_year         = 1 ;
	        rename &src_den_dob        = den_dob              ;
	        rename &src_den_dod        = den_dod              ;
	        *rename &src_race_pfx.1     - &src_race_pfx.5      =
	                den_race_1         - den_race_5;
	        rename &src_sex_cd         = den_gender           ;
	        rename &src_race_eth_cd    = den_race_eth_cd      ;
					*format &src_race_eth_cd         $race_eth. ;
	        rename &src_el_day_pfx.01   - &src_el_day_pfx.12   =
	               mdcd_enrlmt_days_&tmp_ren_min               -
	               mdcd_enrlmt_days_&tmp_ren_max               ;
			den_state_cd_&tmp_year 			 = &src_state_cd        ;
			den_state_cd    				 = &src_state_cd	    ;
	        el_rsdnc_cnty_cd_ltst_&tmp_year  = &src_res_county      ;
	        el_rsdnc_zip_cd_ltst_&tmp_year 	 = &src_res_zip         ;	 
	        el_ss_elgblty_cd_ltst_&tmp_year  = &src_ss_el  			;
	        el_max_elgblty_cd_ltst_&tmp_year = &src_max_el			;
			               den_zip_taf          = &src_res_zip;
             			   &den_county       = &src_res_county*1;
	run;
	/* some duplicates (less than 100 per year when use MSIS & BENE)
			thousands of duplicates when use BENE only because many
			rows have MSIS but do NOT have BENE
	   --no easy way to tell which is the correct row for MSIS/BENE so sorting nodupkey **/
	proc sort data=&tmp_ds_out  nodupkey;
	by &pat_id;
	run;
%mend;

%year_taf(tmp_ds_in  = &mps2016,
      tmp_ds_out = &short_term_ds_mps_2016,
      tmp_year   = 2016,
      tmp_ren_min= 73,
      tmp_ren_max= 84);
/*we need to relabel each month for the entire study period
	  to assess month on month eligiblity--so 1st month year is relabeled to 13
	  for the 2nd calendar year of the study period*/
%year_taf(tmp_ds_in  = &mps2017,
      tmp_ds_out = &short_term_ds_mps_2017,
      tmp_year   = 2017,
      tmp_ren_min= 85,
      tmp_ren_max= 96);

%year_taf(tmp_ds_in  = &mps2018,
      tmp_ds_out = &short_term_ds_mps_2018,
      tmp_year   = 2018,
      tmp_ren_min= 97,
      tmp_ren_max= 108);

%year_taf(tmp_ds_in  = &mps2019,
      tmp_ds_out = &short_term_ds_mps_2019,
      tmp_year   = 2019,
      tmp_ren_min= 109,
      tmp_ren_max= 120);



/*we are using update instead of merge because we want to fill in
	  fixed variables (sex, race, DOB, DOD)
	  for those who had missing info in 1 year but not another
	  -for the eligibility update: fills in the LAST value that is not missing 
	  		(if eligible 2010-2015 will be 2015 value)
	  background info: https://communities.sas.com/t5/SAS-Procedures/difference-between-merge-set-and-update/td-p/154648*/
data &out_ds_all_elig;
  update
  &short_term_ds_mps_2010
  &short_term_ds_mps_2011
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2012
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2013
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2014
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2015
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2016
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2017
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2018
  ;
  by &pat_id;
run;

data &out_ds_all_elig;
  update
  &out_ds_all_elig
  &short_term_ds_mps_2019
  ;
  by &pat_id;
run;

data &out_ds_all_elig._applied;
set   &out_ds_all_elig
  ;
  by &pat_id;
*format el_max_elgblty_cd_ltst   $elig.     ;  
label el_max_elgblty_cd_ltst ='Most recent (=last year) eligibility code using the MAX eligibility indicator ';
label el_max_elgblty_cd_ltst_2010 ='2010 eligibility code using the MAX eligibility indicator ';
label el_ss_elgblty_cd_ltst  ='Most recent (=last year) eligibility code using the state specific eligibility indicator';
label el_ss_elgblty_cd_ltst_2010  ='2010 eligibility code using the state specific eligibility indicator';

label el_rsdnc_cnty_cd_ltst = 'Most recent (=last year) county code ';
label el_rsdnc_cnty_cd_ltst_2010 = '2010 county code ';
label &den_county = 'Most recent (=last year) county code ';
label den_state_cd = 'Most recent (=last year) state code ';
label den_zip = 'Most recent (=last year) ZIP code ';
label den_zip_taf = 'Most recent (=last year) ZIP code TAF ';
label den_state_cd_2010='state in 2010';
label den_year_2010='in medicaid person summary file in 2010 (no eligibility requirement applied)';
label den_year_2011='in medicaid person summary file in 2011 (no eligibility requirement applied)';
label den_year_2012='in medicaid person summary file in 2012 (no eligibility requirement applied)';
label den_year_2013='in medicaid person summary file in 2013 (no eligibility requirement applied)';
label den_year_2014='in medicaid person summary file in 2014 (no eligibility requirement applied)';
label den_year_2015='in medicaid person summary file in 2015 (no eligibility requirement applied)';
label den_year_2016='in medicaid person summary file in 2016 (no eligibility requirement applied)';
label den_year_2017='in medicaid person summary file in 2017 (no eligibility requirement applied)';
label den_year_2018='in medicaid person summary file in 2018 (no eligibility requirement applied)';
label den_year_2019='in medicaid person summary file in 2019 (no eligibility requirement applied)';

/*create age for each person on midpoint of year and set first date ever eligible for Medicaid*/
    if den_year_2010=1 then do;
        den_age_2010=intck("years",(den_dob),  "01jul2010"d  );
    end;
    if den_year_2011=1 then do;
        den_age_2011=intck("years",(den_dob),  "01jul2011"d  );
    end;
    if den_year_2012=1 then do;
        den_age_2012=intck("years",(den_dob),  "01jul2012"d  );
    end;
    if den_year_2013=1 then do;
        den_age_2013=intck("years",(den_dob),  "01jul2013"d  );
    end;
    if den_year_2014=1 then do;
        den_age_2014=intck("years",(den_dob),  "01jul2014"d  );
    end;
	if den_year_2015=1 then do;
        den_age_2015=intck("years",(den_dob),  "01jul2015"d  );
    end;	
	if den_year_2016=1 then do;
        den_age_2016=intck("years",(den_dob),  "01jul2016"d  );
    end;
		if den_year_2017=1 then do;
        den_age_2017=intck("years",(den_dob),  "01jul2017"d  );
    end;
		if den_year_2018=1 then do;
        den_age_2018=intck("years",(den_dob),  "01jul2018"d  );
    end;
		if den_year_2019=1 then do;
        den_age_2019=intck("years",(den_dob),  "01jul2019"d  );
    end;
label den_age_2010='age on July 1 of year (no eligibility requirement applied)';
    den_age_first  =min(of den_age_2010,
                   den_age_2011,
                   den_age_2012,
                   den_age_2013,
				   den_age_2014,
                   den_age_2015,
				   den_age_2016,
				   den_age_2017,
				   den_age_2018,
				   den_age_2019	);
label den_age_first='first midpoint age (on July 1) in Medicaid PS file (no eligibility requirement applied)';
run;
proc means nmiss data=&out_ds_all_elig._applied; var den_age_first; run;

proc sort data= &out_ds_all_elig._applied nodupkey
           out= &out_ds_all_elig._applied ;
by &pat_id;
run; *there should be no duplicates after running --there is a problem above is there are duplicates;
/*this dataset has all of the eligibility flags, the next section "first eligible" will
create a dataset with a smaller set of variables and variables related to a requirement with 15 days of eligibility*/

/*** END section - Read in Person Summary (PS) for Eligibility ***/
/*** END section - PS for Elig ***/
/*** END section - PS for Elig ***/


/*** Start of section to identify beginning and end of eligibility
		and how many days eligible in between

this section makes our permanent dataset that will be used by
most other studies that involve medicaid patients
***/

data &outds_2010_2019 (keep= &pat_id
					   den_:
					   el_max_elgblty: 
					   el_ss_elgblty:
					   el_rsdnc_cnty:
					   &fup_medicaid
                       &start_yr
                       &elig_start_dt
                       &nvar_el_days
                       &elig_end_flag
                       &end_yr
                       &elig_end_dt
                       &elig_month_flag
                       drop= n i  done:);
  set &out_ds_all_elig._applied ;

  /*sum days eligible for medicaid not accounting for 15 day eligiblity requirement*/
&nvar_el_days =sum(of mdcd_enrlmt_days_1 - mdcd_enrlmt_days_120);
label &nvar_el_days = 'Sum of days eligible Jan2010-Dec2019 NOT accounting for first and last month 15 days eligibility requirement';

/*identify first month eligible for Medicaid based on 1st month with at least 15 days eligible*/
  array MONTHS (120) mdcd_enrlmt_days_1 - mdcd_enrlmt_days_120;
  do n=1 to 120;
    if MONTHS(n) ge 15 then do;
      &elig_month_flag = n;
          label &elig_month_flag ='month between jan 2010 and dec 2019 with first eligibility in Medicaid (first month with >=15 days eligible)';
      leave; /*leave means that one there is a month that meets the 15 day eligiblity criteria then leave the macro--this is the first month*/
    end;
  end;

/*create first year eligible for medicaid*/
  if 1  <= &elig_month_flag <= 12  then do; &start_yr=2010; end;
  if 13 <= &elig_month_flag <= 24  then do; &start_yr=2011; end;
  if 25 <= &elig_month_flag <= 36  then do; &start_yr=2012; end;
  if 37 <= &elig_month_flag <= 48  then do; &start_yr=2013; end;
  if 49 <= &elig_month_flag <= 60  then do; &start_yr=2014; end;
  if 61 <= &elig_month_flag <= 72  then do; &start_yr=2015; end;
  if 73 <= &elig_month_flag <= 84  then do; &start_yr=2016; end;
  if 85 <= &elig_month_flag <= 96  then do; &start_yr=2017; end;
  if 97 <= &elig_month_flag <= 108  then do; &start_yr=2018; end;
  if 109 <= &elig_month_flag <= 120  then do; &start_yr=2019; end;
label &start_yr='first year eligible for Medicaid (month with at least 15 days eligible)';

/*create first date eligible for medicaid*/
  /*everyone is imputed to eligibility on the first day of the month with at least 15 days eligible*/
  if &elig_month_flag in(1 ,13,25,37,49,61,73,85,97,109) then do;  &elig_start_dt = mdy(1 , 1, &start_yr); end;
  if &elig_month_flag in(2 ,14,26,38,50,62,74,86,98,110) then do;  &elig_start_dt = mdy(2 , 1, &start_yr); end;
  if &elig_month_flag in(3 ,15,27,39,51,63,75,87,99,111) then do;  &elig_start_dt = mdy(3 , 1, &start_yr); end;
  if &elig_month_flag in(4 ,16,28,40,52,64,76,88,100,112) then do;  &elig_start_dt = mdy(4 , 1, &start_yr); end;
  if &elig_month_flag in(5 ,17,29,41,53,65,77,89,101,113) then do;  &elig_start_dt = mdy(5 , 1, &start_yr); end;
  if &elig_month_flag in(6 ,18,30,42,54,66,78,90,102,114) then do;  &elig_start_dt = mdy(6 , 1, &start_yr); end;
  if &elig_month_flag in(7 ,19,31,43,55,67,79,91,103,115) then do;  &elig_start_dt = mdy(7 , 1, &start_yr); end;
  if &elig_month_flag in(8 ,20,32,44,56,68,80,92,104,116) then do;  &elig_start_dt = mdy(8 , 1, &start_yr); end;
  if &elig_month_flag in(9 ,21,33,45,57,69,81,93,105,117) then do;  &elig_start_dt = mdy(9 , 1, &start_yr); end;
  if &elig_month_flag in(10,22,34,46,58,70,82,94,106,118) then do;  &elig_start_dt = mdy(10, 1, &start_yr); end;
  if &elig_month_flag in(11,23,35,47,59,71,83,95,107,119) then do;  &elig_start_dt = mdy(11, 1, &start_yr); end;
  if &elig_month_flag in(12,24,36,48,60,72,84,96,108,120) then do;  &elig_start_dt = mdy(12, 1, &start_yr); end;
  format &elig_start_dt date9.;
  label &elig_start_dt ='first date of Medicaid coverage 2010-2019 (require >=15 days eligible in month), date imputed to 1st for all';

  /*create last month, year, date eligible for medicaid allowing a 3 month gap
  		-set last date of month to last day in that month*/
  do i=1 to 120; /* until (done) */
    if i > &elig_month_flag and MONTHS(i) < 15 then do;
      if MONTHS(i) < 15 then done1 = 1; else done1 = 0;
          if i >= 2 and MONTHS(i-1) < 15 then done2 =1; else done2 =0;
          if i >= 3 and MONTHS(i-2) < 15 then done3 =1; else done3 =0;
          if done1 =1 and done2 =1 and done3 =1 then &elig_end_flag = i-3;
          if done1 + done2 + done3 = 3 then leave;
          label &elig_end_flag ='month between jan 2010 and dec 2019 with last eligibility in Medicaid (last month with >=15 days eligible (allow 3 month gap)';
    end;
  end;
  if 1  <= &elig_end_flag <= 12  then do; &end_yr =2010; end;
  if 13 <= &elig_end_flag <= 24  then do; &end_yr =2011; end;
  if 25 <= &elig_end_flag <= 36  then do; &end_yr =2012; end;
  if 37 <= &elig_end_flag <= 48  then do; &end_yr =2013; end;
  if 49 <= &elig_end_flag <= 60  then do; &end_yr =2014; end;
  if 61 <= &elig_end_flag <= 72  then do; &end_yr =2015; end;
  if 73 <= &elig_end_flag <= 84  then do; &end_yr =2016; end;
  if 85 <= &elig_end_flag <= 96  then do; &end_yr =2017; end;
  if 97 <= &elig_end_flag <= 108  then do; &end_yr =2018; end;
  if 109 <= &elig_end_flag <= 120  then do; &end_yr =2019; end;
label &end_yr='last year eligible for Medicaid (month with at least 15 days eligible)';
  if &elig_end_flag in(1 ,13,25,37,49,61,73,85,97,109) then do;  &elig_end_dt = mdy(1 ,31, &end_yr); end;
  if &elig_end_flag in(2 ,14,26,38,50,62,74,86,98,110) then do;  &elig_end_dt = mdy(2 ,28, &end_yr); end;
  if &elig_end_flag in(3 ,15,27,39,51,63,75,87,99,111) then do;  &elig_end_dt = mdy(3 ,31, &end_yr); end;
  if &elig_end_flag in(4 ,16,28,40,52,64,76,88,100,112) then do;  &elig_end_dt = mdy(4 ,30, &end_yr); end;
  if &elig_end_flag in(5 ,17,29,41,53,65,77,89,101,113) then do;  &elig_end_dt = mdy(5 ,31, &end_yr); end;
  if &elig_end_flag in(6 ,18,30,42,54,66,78,90,102,114) then do;  &elig_end_dt = mdy(6 ,30, &end_yr); end;
  if &elig_end_flag in(7 ,19,31,43,55,67,79,91,103,115) then do;  &elig_end_dt = mdy(7 ,31, &end_yr); end;
  if &elig_end_flag in(8 ,20,32,44,56,68,80,92,104,116) then do;  &elig_end_dt = mdy(8 ,31, &end_yr); end;
  if &elig_end_flag in(9 ,21,33,45,57,69,81,93,105,117) then do;  &elig_end_dt = mdy(9 ,30, &end_yr); end;
  if &elig_end_flag in(10,22,34,46,58,70,82,94,106,118) then do;  &elig_end_dt = mdy(10,31, &end_yr); end;
  if &elig_end_flag in(11,23,35,47,59,71,83,95,107,119) then do;  &elig_end_dt = mdy(11,30, &end_yr); end;
  if &elig_end_flag in(12,24,36,48,60,72,84,96,108,120) then do;  &elig_end_dt = mdy(12,31, &end_yr); end;
 format &elig_end_dt  date9.;
 label &elig_end_dt ='last date of Medicaid coverage 2010-2019 (>=15 days in month), date imputed to last day of month for all';
/*create month and date for those eligible through the end of the time period*/
  if &elig_start_dt ne . and &elig_end_dt=. and &nvar_el_days  ne . then do;
    &elig_end_flag = 120;
    &elig_end_dt = mdy(12, 31, 2019);
  end;

  /* if end date is less than the start date set them to be equal */
  if &elig_end_dt < &elig_start_dt then &elig_end_dt = &elig_start_dt;
/*calculate medicaid followup in days taking into account our start and end dates*/
 &fup_medicaid = &elig_end_dt - &elig_start_dt ;
label &fup_medicaid = 'Sum of days eligible Jan2010-Dec2019 ACCOUNTING for first and last month with 15 days eligibility requirement';

    /* identify which years patient contributed
       to denominator based on
       eligibility on midpoint */
    if elig_start_dt <="01jul2010"d <=elig_end_dt then den_year2010 =1;
    if elig_start_dt <="01jul2011"d <=elig_end_dt then den_year2011 =1;
    if elig_start_dt <="01jul2012"d <=elig_end_dt then den_year2012 =1;
    if elig_start_dt <="01jul2013"d <=elig_end_dt then den_year2013 =1;
    if elig_start_dt <="01jul2014"d <=elig_end_dt then den_year2014 =1;
	if elig_start_dt <="01jul2015"d <=elig_end_dt then den_year2015 =1;
	if elig_start_dt <="01jul2016"d <=elig_end_dt then den_year2016 =1;
	if elig_start_dt <="01jul2017"d <=elig_end_dt then den_year2017 =1;
	if elig_start_dt <="01jul2018"d <=elig_end_dt then den_year2018 =1;
	if elig_start_dt <="01jul2019"d <=elig_end_dt then den_year2019 =1;

    label den_year2010  = "indicator that person was Medicaid eligible on July 1 2010";
    label den_year2011  = "indicator that person was Medicaid eligible on July 1 2011";
    label den_year2012  = "indicator that person was Medicaid eligible on July 1 2012";
    label den_year2013  = "indicator that person was Medicaid eligible on July 1 2013";
    label den_year2014  = "indicator that person was Medicaid eligible on July 1 2014";
	label den_year2015  = "indicator that person was Medicaid eligible on July 1 2015";
	label den_year2016  = "indicator that person was Medicaid eligible on July 1 2016";
	label den_year2017  = "indicator that person was Medicaid eligible on July 1 2017";
	label den_year2018  = "indicator that person was Medicaid eligible on July 1 2018";
	label den_year2019  = "indicator that person was Medicaid eligible on July 1 2019";

/*drop records with missing bene_id*/
  if bene_id=. and msis_id=' ' then delete;
run;

proc freq data=&outds_2010_2019;
table den_year2010*end_yr end_yr den_year: end_yr fup_medicaid; run;
*large number have medicaid claims but are not medicaid eligible
	-these are easy to distinguish because their fup_medicaid is missing;
*201,105,592;

/*** quick audits on denom data ***/
*%field_freq(inds=  &outds_2010_2019 , vartochk= den_gender);





********************************move below to step 4!!!!!**************************;
/** drop those with insufficient follow-up/eligiblity in denom file:
    den_elig_pop ne 1 means that person did not have a
    single month with eligibility days of at least 15 **/

  /* drop those who never have a single month that meets the
     15 day eligibility criteria  (some of them have
     days > 15 but it's spread out over multiple months *
  if &elig_month_flag =. then delete;
    drop el_max_elgblty_cd_ltst_2:;
    drop el_rsdnc_zip_cd_ltst_2:;
    drop el_ss_elgfblty_cd_ltst_2:;
	drop &den_zip_pfx.: &den_county_pfx.:;
    drop el_days:;
    drop el_elgblty_mo_cnt:;
    drop den_race_2 - den_race_5;
  /*** clean up of data - temp - created in lwork space ***/
/*** using the temp prefix ***
proc datasets lib=&lwork. noprint ;
delete &temp_ds_pfx.:;
quit;
run;
