/********************************************************************
* Job Name: 2_mdcd_taf_OP_TPN.sas
* Job Desc: Identify parenteral nutrition use in Outpatient (not IBD specific)
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
%let    final_sub_ds = &shlib..&proj_ds_pfx.tpn_ot_2014_2019;

%let  pat_idb            = bene_id  state_cd msis_id         ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global proc_pfx clm_beg_dt	clm_end_dt        ;
%let  proc_pfx           = line_prcdr_cd       ;
*%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;
%let  clm_beg_dt         = line_srvc_bgn_dt  	 ;
%let  clm_end_dt         = line_srvc_end_dt   ;


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


/*** end of section   - global vars ***/


%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = taf;


/*** this section is related to ot - inpatient claims ***/
/*   get inpatient tpn in hospital                   */


%macro ibdyear(serveryear=, ibdyear=);
		data    &ibdyear;
		          set &serveryear 
						(keep= &pat_id &proc_pfx.
                          &clm_beg_dt
						  &clm_end_dt);
         where &proc_pfx in (  &tpn_10_criteria ) or
		   substr(&proc_pfx,1,4) in ( &tpn_09_criteria_4 ) or
		   &proc_pfx in ( &tpn_cpt_criteria );
     run;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=tpn_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=tpn_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=tpn_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=tpn_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=tpn_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=tpn_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=tpn_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=tpn_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=tpn_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=tpn_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=tpn_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=tpn_ot_20&NN._12);
data tpn_ot_20&NN.;
set tpn_ot_20&NN._01 - tpn_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=tpn_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=tpn_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=tpn_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=tpn_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=tpn_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=tpn_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=tpn_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=tpn_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=tpn_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=tpn_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=tpn_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=tpn_ot_20&NN._12);
data tpn_ot_20&NN.;
set tpn_ot_20&NN._01 - tpn_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=tpn_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=tpn_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=tpn_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=tpn_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=tpn_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=tpn_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=tpn_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=tpn_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=tpn_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=tpn_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=tpn_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=tpn_ot_20&NN._12);
data tpn_ot_20&NN.;
set tpn_ot_20&NN._01 - tpn_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=tpn_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=tpn_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=tpn_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=tpn_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=tpn_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=tpn_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=tpn_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=tpn_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=tpn_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=tpn_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=tpn_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=tpn_ot_20&NN._12);
data tpn_ot_20&NN.;
set tpn_ot_20&NN._01 - tpn_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=tpn_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=tpn_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=tpn_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=tpn_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=tpn_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=tpn_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=tpn_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=tpn_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=tpn_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=tpn_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=tpn_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=tpn_ot_20&NN._12);
data tpn_ot_20&NN.;
set tpn_ot_20&NN._01 - tpn_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=tpn_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=tpn_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=tpn_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=tpn_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=tpn_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=tpn_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=tpn_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=tpn_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=tpn_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=tpn_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=tpn_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=tpn_ot_20&NN._12);
data tpn_ot_20&NN.;
set tpn_ot_20&NN._01 - tpn_ot_20&NN._12;
yr_num=20&NN.;
run;

proc sort data=tpn_ot_2014; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ot_2015; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ot_2016; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ot_2017; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ot_2018; by &pat_idb &clm_beg_dt ; run;
proc sort data=tpn_ot_2019; by &pat_idb &clm_beg_dt ; run;

data  &temp_ds_pfx.temp_tpn_otop (keep= &pat_id &flag_tpn.:);
    set
     tpn_ot_2014
	 tpn_ot_2015
	 tpn_ot_2016
	 tpn_ot_2017
	 tpn_ot_2018
	 tpn_ot_2019
    ;
&flag_tpn=1;
rename &clm_beg_dt = &flag_tpn._dt;
run;

proc sort data= &temp_ds_pfx.temp_tpn_otop nodupkey
out=&shlib..&proj_ds_pfx.tpn_ot_2014_2019;
by &pat_id &flag_tpn._dt;
run;

proc freq data=&shlib..&proj_ds_pfx.tpn_ot_2014_2019; table &flag_tpn; run;


/*
%macro SKot ;
/*count number of IBD hospitalizations from inpatient--this is for a check
	for final need to take into accunt study-specific 1st date*
*need to make bene_msis_st_id for this to run;
%macro counts (in=, date=, date_first=, date_last=, out=, flagin=, count=);
/*there should be no duplicates when this proc sort is run
    --if duplicates are deleted there is a problem above*
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

%counts(in=&shlib..&proj_ds_pfx.tpn_ot_2010_2015,
		out=ibd_hosp_ot_cnt , 
		date= tpn_ot_hosp_dt, 
		date_first=tpn_ot_hosp_dt_first,
		date_last=tpn_ot_hosp_dt_last,
		flagin=tpn_ot_hosp , count=tpn_ot_hosp_count );
