/********************************************************************
* Job Name: 2_mdcd_taf_IP_IBDHosp.sas
* Job Desc: Identify all IBD-related hospitalizations (inpatient setting only)
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
    %let    temp_ds_pfx = tmp_hosp_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										  hosp stands for ibd surgery  ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = taf_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.ibdhosp_ip_2014_2019;

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


/** these are mvars to hold diag criteria for substance **/
%global main_diag_criteria    ;

/** three digit criteria to allow for broader
    diag identification before group specific
    values are targeted **/
%global cd_diag_criteria;
%global uc_diag_criteria;
%let  main_diag_criteria = '555' '556' 'K50' 'K51'    ;
%let  cd_diag_criteria   = '555' 'K50'                ;
%let  uc_diag_criteria   = '556' 'K51'                ;

%global flag_ip_cd flag_ip_uc flag_ip_ibd;
%let flag_cd             = cd_ip_hosp ;
%let flag_uc             = uc_ip_hosp ;
%let flag_ibd            = ibd_ip_hosp ;

%global age;
%global clm_beg_dt clm_end_dt clm_dob;
%global clm_drg ;
%let  age                = age           ;
%let  clm_beg_dt         = srvc_bgn_dt   ; *change to clm admsn?;
%let  clm_end_dt         = srvc_end_dt   ; *change to discharge?;
%let  clm_drg            = drg_cd    ;
%let  clm_dob            = birth_dt        ;

/*** end of section   - global vars ***/


%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = taf;


/*** this section is related to IP - inpatient claims ***/
/*   get inpatient IBD hospitalizations                   */


%macro ibdyear(serveryear=, ibdyear=);
		data    ibd_ip_1;
		          set &serveryear 
						(keep= &pat_idb   &clm_dob 
								 &clm_beg_dt &clm_end_dt
								&diag_pfx.:  );
		          where substr(&diag_pfx.1,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.2,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.3,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.4,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.5,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.6,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.7,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.8,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.9,1,3) in ( &main_diag_criteria ) or
						substr(&diag_pfx.10,1,3) in ( &main_diag_criteria ) or
						substr(&diag_pfx.11,1,3) in ( &main_diag_criteria ) or
						substr(&diag_pfx.12,1,3) in ( &main_diag_criteria )   ;
			run;

data ibd_ip_2;
set
ibd_ip_1;
	if substr(&diag_pfx.1,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.2,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.3,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.4,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.5,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.6,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.7,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.8,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.9,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.10,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.11,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.12,1,3) in ( &cd_diag_criteria ) 
		   then do;
   &flag_cd=1;
   &flag_cd._dt = &clm_beg_dt;
   end;

if substr(&diag_pfx.1,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.2,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.3,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.4,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.5,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.6,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.7,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.8,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.9,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.10,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.11,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.12,1,3) in ( &uc_diag_criteria ) 
		   then do;
   &flag_uc=1;
   &flag_uc._dt = &clm_beg_dt;
   end;
   if &flag_uc=1 or &flag_cd=1;
run;

proc sort data= ibd_ip_2  nodupkey
           out= &ibdyear;
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=ibd_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=ibd_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=ibd_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=ibd_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=ibd_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=ibd_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=ibd_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=ibd_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=ibd_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=ibd_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=ibd_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=ibd_ip_20&NN._12);
data ibd_ip_20&NN.;
set ibd_ip_20&NN._01 - ibd_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=ibd_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=ibd_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=ibd_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=ibd_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=ibd_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=ibd_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=ibd_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=ibd_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=ibd_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=ibd_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=ibd_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=ibd_ip_20&NN._12);
data ibd_ip_20&NN.;
set ibd_ip_20&NN._01 - ibd_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=ibd_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=ibd_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=ibd_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=ibd_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=ibd_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=ibd_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=ibd_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=ibd_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=ibd_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=ibd_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=ibd_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=ibd_ip_20&NN._12);
data ibd_ip_20&NN.;
set ibd_ip_20&NN._01 - ibd_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=ibd_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=ibd_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=ibd_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=ibd_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=ibd_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=ibd_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=ibd_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=ibd_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=ibd_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=ibd_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=ibd_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=ibd_ip_20&NN._12);
data ibd_ip_20&NN.;
set ibd_ip_20&NN._01 - ibd_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=ibd_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=ibd_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=ibd_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=ibd_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=ibd_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=ibd_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=ibd_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=ibd_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=ibd_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=ibd_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=ibd_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=ibd_ip_20&NN._12);
data ibd_ip_20&NN.;
set ibd_ip_20&NN._01 - ibd_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=ibd_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=ibd_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=ibd_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=ibd_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=ibd_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=ibd_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=ibd_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=ibd_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=ibd_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=ibd_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=ibd_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=ibd_ip_20&NN._12);
data ibd_ip_20&NN.;
set ibd_ip_20&NN._01 - ibd_ip_20&NN._12;
yr_num=20&NN.;
run;

proc sort data=ibd_ip_2014; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ip_2015; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ip_2016; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ip_2017; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ip_2018; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ip_2019; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;

data  &lwork..&temp_ds_pfx.tmp_all_grps
 (keep=  &pat_idb &clm_beg_dt
            &flag_cd:
            &flag_uc:
            &flag_ibd: );
    merge
     ibd_ip_2014
	 ibd_ip_2015
	 ibd_ip_2016
	 ibd_ip_2017
	 ibd_ip_2018
	 ibd_ip_2019
    ;
    by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
&flag_ibd =0;

if &flag_cd=1 or &flag_uc=1 then do;
    &flag_ibd = 1; 
	&flag_ibd._dt = &clm_beg_dt;
end;
run;

proc sort data= &lwork..&temp_ds_pfx.tmp_all_grps nodupkey
out=&shlib..&proj_ds_pfx.ibdhosp_ip_2014_2019;			/*final dataset*/
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
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

%counts(in=&shlib..&proj_ds_pfx.ibdhosp_ip_2010_2015,
		out=ibd_hosp_ip_cnt , 
		date= ibd_ip_hosp_dt, 
		date_first=ibd_ip_hosp_dt_first,
		date_last=ibd_ip_hosp_dt_last,
		flagin=ibd_ip_hosp , count=ibd_ip_hosp_count );
