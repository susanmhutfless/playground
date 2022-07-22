/********************************************************************
* Job Name: 2_mdcd_taf_IP_TPN.sas
* Job Desc: Identify parenteral nutrition use in Inpatient (not IBD specific)
* COPYRIGHT (c) 2019 2020 2021 Johns Hopkins University - HutflessLab
********************************************************************/

/** alert - the job and settings in 0_setup_facts.sas must be set first **/

/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;   /** libname prefix **/
%global pat_idb clm_id                       ;
%global pat_id                               ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_tpn_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										    ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = taf_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.tpn_ip_2014_2019;

%let  pat_idb            = bene_id  state_cd msis_id         ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

/*this variable relies on diag codes only*/
%global diag_pfx diag_cd_min diag_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;

%let  diag_pfx           = dgns_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 12                 ;
%let  proc_pfx           = prcdr_cd_         ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 6                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;*not on taf inp; *HOSP_TYPE_CD is closest;


%global tpn_09_criteria_4 
		tpn_10_criteria 
		tpn_cpt_criteria     ;

/*need to use substr4 for 9 here!*/
%let  tpn_09_criteria_4   = '9915'						;

%let  tpn_10_criteria   = '3E0336Z' '3E0436Z' '3E0536Z' '3E0636Z';

%let  tpn_cpt_criteria =    'B4220' 'B4222' 'B4224' 'B4164' 'B4168'
							'B4172' 'B4176' 'B4178' 'B4180' 'B4185'
							'B4187' 'B4189' 'B4193' 'B4197' 'B4199' 
							'B4216' 'B4220' 'B4222' 'B4224' 'B5000'
							'B5100' 'B5200' 'B9004' 'B9006'			 ;

/**  **/
%global flag_tpn  ;
%let    flag_tpn          = tpn  ;

%global clm_beg_dt clm_end_dt			 ;
%global clm_drg 						 ;
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_drg            = clm_drg_cd    ;


/*** end of section   - global vars ***/


%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = taf;


/*** this section is related to IP - inpatient claims ***/
/*   get inpatient tpn in hospital                   */


%macro ibdyear(serveryear=, ibdyear=);
		data    &ibdyear;
		          set &serveryear 
									(keep= &pat_id &proc_pfx.:
                          &clm_beg_dt
						  &clm_end_dt);
          where &proc_pfx.1 in (  &tpn_10_criteria ) or
                &proc_pfx.2 in (  &tpn_10_criteria ) or
                &proc_pfx.3 in (  &tpn_10_criteria ) or
                &proc_pfx.4 in (  &tpn_10_criteria ) or
                &proc_pfx.5 in (  &tpn_10_criteria ) or
                &proc_pfx.6 in (  &tpn_10_criteria ) or
				substr(&proc_pfx.1,1,4) in ( &tpn_09_criteria_4 ) or
                substr(&proc_pfx.2,1,4) in ( &tpn_09_criteria_4 ) or
                substr(&proc_pfx.3,1,4) in ( &tpn_09_criteria_4 ) or
                substr(&proc_pfx.4,1,4) in ( &tpn_09_criteria_4 ) or
                substr(&proc_pfx.5,1,4) in ( &tpn_09_criteria_4 ) or
                substr(&proc_pfx.6,1,4) in ( &tpn_09_criteria_4 ) or
				&proc_pfx.1 in ( &tpn_cpt_criteria ) or
                &proc_pfx.2 in ( &tpn_cpt_criteria ) or
                &proc_pfx.3 in ( &tpn_cpt_criteria ) or
                &proc_pfx.4 in ( &tpn_cpt_criteria ) or
                &proc_pfx.5 in ( &tpn_cpt_criteria ) or
                &proc_pfx.6 in ( &tpn_cpt_criteria );
     run;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=tpn_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=tpn_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=tpn_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=tpn_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=tpn_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=tpn_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=tpn_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=tpn_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=tpn_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=tpn_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=tpn_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=tpn_ip_20&NN._12);
data tpn_ip_20&NN.;
set tpn_ip_20&NN._01 - tpn_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=tpn_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=tpn_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=tpn_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=tpn_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=tpn_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=tpn_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=tpn_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=tpn_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=tpn_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=tpn_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=tpn_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=tpn_ip_20&NN._12);
data tpn_ip_20&NN.;
set tpn_ip_20&NN._01 - tpn_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=tpn_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=tpn_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=tpn_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=tpn_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=tpn_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=tpn_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=tpn_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=tpn_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=tpn_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=tpn_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=tpn_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=tpn_ip_20&NN._12);
data tpn_ip_20&NN.;
set tpn_ip_20&NN._01 - tpn_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=tpn_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=tpn_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=tpn_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=tpn_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=tpn_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=tpn_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=tpn_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=tpn_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=tpn_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=tpn_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=tpn_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=tpn_ip_20&NN._12);
data tpn_ip_20&NN.;
set tpn_ip_20&NN._01 - tpn_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=tpn_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=tpn_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=tpn_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=tpn_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=tpn_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=tpn_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=tpn_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=tpn_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=tpn_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=tpn_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=tpn_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=tpn_ip_20&NN._12);
data tpn_ip_20&NN.;
set tpn_ip_20&NN._01 - tpn_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=tpn_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=tpn_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=tpn_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=tpn_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=tpn_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=tpn_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=tpn_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=tpn_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=tpn_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=tpn_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=tpn_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=tpn_ip_20&NN._12);
data tpn_ip_20&NN.;
set tpn_ip_20&NN._01 - tpn_ip_20&NN._12;
yr_num=20&NN.;
run;

proc sort data=tpn_ip_2014; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ip_2015; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ip_2016; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ip_2017; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ip_2018; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ip_2019; by &pat_idb &clm_beg_dt ; run;

data  &temp_ds_pfx.temp_tpn_ipop (keep= &pat_id &flag_tpn.:);
    set
     tpn_ip_2014
	 tpn_ip_2015
	 tpn_ip_2016
	 tpn_ip_2017
	 tpn_ip_2018
	 tpn_ip_2019
    ;
&flag_tpn=1;
rename &clm_beg_dt = &flag_tpn._dt;
run;

proc sort data= &temp_ds_pfx.temp_tpn_ipop nodupkey
out=&shlib..&proj_ds_pfx.tpn_ip_2014_2019;
by &pat_id &flag_tpn._dt;
run;



%macro SKIP ;
/*count number of IBD hospitalizations from inpatient--this is for a check
	for final need to take into accunt study-specific 1st date*/
*need to make bene_msis_st_id for this to run;
%macro counts (in=, date=, date_first=, date_last=, out=, flagin=, count=);
/*there should be no duplicates when this proc sort is run
    --if duplicates are deleted there is a problem above*/
proc sort data=&in nodupkey;
by &pat_id &date ;
run;

data &out (keep = &pat_id &count &date_first &date_last);
set &in ;
by &pat_id &date;
where &flagin=1;

if first.&pat_id then do; &count = 0; &date_first=&date; end; &count + 1;
if last.&pat_id then do; &date_last=&date; end;
if last.&pat_id then output;
run;

proc freq data= &out ;
table &count;
run;
%field_numbers(inds=&out , vartochk= &count);
%mend;

%counts(in=&shlib..&proj_ds_pfx.tpn_ip_2010_2015,
		out=ibd_hosp_ip_cnt , 
		date= tpn_ip_hosp_dt, 
		date_first=tpn_ip_hosp_dt_first,
		date_last=tpn_ip_hosp_dt_last,
		flagin=tpn_ip_hosp , count=tpn_ip_hosp_count );
