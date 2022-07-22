/********************************************************************
* Job Name: 2_mdcd_taf_IP_crohns_cohort.sas
* Job Desc: Input for Inpatient Claims to identify
        all cases of Crohn's disease in Medicaid
	final dataset is IBD hospitalizations only--can't use for studies
	other than to identify IBD cohort or hospitalization outcome
* COPYRIGHT (c) 2019 2020 2021 Johns Hopkins University - HutflessLab
********************************************************************/


/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;   /** libname prefix **/
%global pat_idb clm_id                       ;
%global pat_id                               ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

%let  pat_idb            = bene_Id state_cd msis_id          ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global diag_pfx diag_cd_min diag_cd_max ;
%global proc_pfx proc_cd_min proc_cd_max ;
%global plc_of_srvc_cd                   ;

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_mip_;  /*** prefix to identify temp data
                                          leave the trailing underscore ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = taf_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/
%global ds_all_prefix                    ;
%let  ds_all_prefix      = ;
%let  ds_all_ip          = &shlib..&proj_ds_pfx.cd_ip_2014_19;

%let  diag_pfx           = dgns_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 12                 ;
%let  proc_pfx           = prcdr_cd_         ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 6                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;*not on taf inp; *HOSP_TYPE_CD is closest;

%global main_diag_criteria;
%global cd_diag_criteria;
%global uc_diag_criteria;
%let  main_diag_criteria = '555' '556' 'K50' 'K51'    ;
%let  cd_diag_criteria   = '555' 'K50'                ;
%let  uc_diag_criteria   = '556' 'K51'                ;

%global flag_cd flag_uc flag_ibd;
%let flag_cd             = cd ;
%let flag_uc             = uc ;
%let flag_ibd            = ibd ;

%global age;		/*using generic age here--in step3 we will assign to cd_first/last age*/
%global clm_beg_dt clm_end_dt clm_dob clm_pymt_dt;
%global clm_drg ;
%let  age                = age           ; 
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  CLM_ADMSN_DT		 = 	ADMSN_DT ;
%let  clm_pymt_dt        = pymt_dt       ; *not on taf;
%let  clm_drg            = drg_cd  		  ;
%let  clm_dob            = birth_dt        ;
%let  sex_cd			 = sex_cd			; *not on claim in taf;
%let  race_eth_cd		 = el_race_ethncy_cd ; *not on claim in taf;
%let eth_cd				 = ethnicity_cd;	*not on claim in taf;

/*** end of section   - global vars ***/

%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = taf;

%macro ibdyear(serveryear=, ibdyear=);
		data    ibd_ip_1;
		          set &serveryear 
						(keep= &pat_idb   &clm_dob 
								&CLM_ADMSN_DT &clm_beg_dt &clm_end_dt
								&diag_pfx.: &proc_pfx.: );
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
		                &flag_cd=0;
		                &flag_uc=0;
		     run;

			 
		data ibd_ip_2;
		set
		ibd_ip_1;
		age=(&clm_beg_dt - &clm_dob)/365.25;
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


*make 1 per year then merge by year and save for final;
data  &ds_all_ip;
    merge
     ibd_ip_2014
	 ibd_ip_2015
	 ibd_ip_2016
	 ibd_ip_2017
	 ibd_ip_2018
	 ibd_ip_2019
    ;
    by &pat_idb &clm_beg_dt &flag_cd &flag_uc;

    &plc_of_srvc_cd =21;  /* 21=inpatient hospital */

    &flag_ibd =0;

    if &flag_cd=1 or &flag_uc=1 then do;
    &flag_ibd = 1;
    end;

    /*** after this step due to sort - fields diag and proc **/
    /*** are no longer significant for this immediate proj because we keep IBD rows only  **/
    drop &diag_pfx.: ;
    drop &proc_pfx.: ;
run;

proc sort data= &ds_all_ip  nodupkey;
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;
*shu172sl.taf_cd_ip_2014_19;
