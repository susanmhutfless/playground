/********************************************************************
* Job Name: 2_mdcd_taf_OP_crohns_cohort.sas
* Job Desc: Input for Outpatient Claims to identify
        all cases of Crohn's disease in Medicaid
final file is to make an IBD cohort only--not for research
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
%let  ds_all_ip          = &shlib..&proj_ds_pfx.cd_ot_2014_19;

%let  diag_pfx           = dgns_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 2                 ;
%let  proc_pfx           = prcdr_cd_         ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 6                 ;
%let  plc_of_srvc_cd     = pos_cd   ;

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
%let  clm_dob            = birth_dt        ;

/*** end of section   - global vars ***/

%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = taf;

%macro ibdyear(serveryear=, ibdyear=);
		data    ibd_ot_1;
		          set &serveryear 
						(keep= &pat_idb   &clm_dob 
								&clm_beg_dt &clm_end_dt
								&diag_pfx.: &plc_of_srvc_cd );
		          where substr(&diag_pfx.1,1,3) in ( &main_diag_criteria ) or
		                substr(&diag_pfx.2,1,3) in ( &main_diag_criteria )   ;
		                &flag_cd=0;
		                &flag_uc=0;
		     run;

			 
		data ibd_ot_2;
		set
		ibd_ot_1;
		age=(&clm_beg_dt - &clm_dob)/365.25;
		if substr(&diag_pfx.1,1,3) in ( &cd_diag_criteria ) or
		   substr(&diag_pfx.2,1,3) in ( &cd_diag_criteria ) 
		   then do;
		   &flag_cd=1;
		   end;

		if substr(&diag_pfx.1,1,3) in ( &uc_diag_criteria ) or
		   substr(&diag_pfx.2,1,3) in ( &uc_diag_criteria ) 
		   then do;
		   &flag_uc=1;
		   end;
		if &flag_uc=1 or &flag_cd=1;
		run;

		proc sort data= ibd_ot_2  nodupkey
		           out= &ibdyear;
		by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
		run;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..other_services_header_01, ibdyear=ibd_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_header_02, ibdyear=ibd_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_header_03, ibdyear=ibd_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_header_04, ibdyear=ibd_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_header_05, ibdyear=ibd_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_header_06, ibdyear=ibd_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_header_07, ibdyear=ibd_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_header_08, ibdyear=ibd_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_header_09, ibdyear=ibd_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_header_10, ibdyear=ibd_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_header_11, ibdyear=ibd_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_header_12, ibdyear=ibd_ot_20&NN._12);
data ibd_ot_20&NN.;
set ibd_ot_20&NN._01 - ibd_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..other_services_header_01, ibdyear=ibd_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_header_02, ibdyear=ibd_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_header_03, ibdyear=ibd_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_header_04, ibdyear=ibd_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_header_05, ibdyear=ibd_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_header_06, ibdyear=ibd_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_header_07, ibdyear=ibd_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_header_08, ibdyear=ibd_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_header_09, ibdyear=ibd_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_header_10, ibdyear=ibd_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_header_11, ibdyear=ibd_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_header_12, ibdyear=ibd_ot_20&NN._12);
data ibd_ot_20&NN.;
set ibd_ot_20&NN._01 - ibd_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..other_services_header_01, ibdyear=ibd_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_header_02, ibdyear=ibd_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_header_03, ibdyear=ibd_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_header_04, ibdyear=ibd_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_header_05, ibdyear=ibd_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_header_06, ibdyear=ibd_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_header_07, ibdyear=ibd_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_header_08, ibdyear=ibd_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_header_09, ibdyear=ibd_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_header_10, ibdyear=ibd_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_header_11, ibdyear=ibd_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_header_12, ibdyear=ibd_ot_20&NN._12);
data ibd_ot_20&NN.;
set ibd_ot_20&NN._01 - ibd_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..other_services_header_01, ibdyear=ibd_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_header_02, ibdyear=ibd_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_header_03, ibdyear=ibd_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_header_04, ibdyear=ibd_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_header_05, ibdyear=ibd_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_header_06, ibdyear=ibd_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_header_07, ibdyear=ibd_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_header_08, ibdyear=ibd_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_header_09, ibdyear=ibd_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_header_10, ibdyear=ibd_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_header_11, ibdyear=ibd_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_header_12, ibdyear=ibd_ot_20&NN._12);
data ibd_ot_20&NN.;
set ibd_ot_20&NN._01 - ibd_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..other_services_header_01, ibdyear=ibd_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_header_02, ibdyear=ibd_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_header_03, ibdyear=ibd_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_header_04, ibdyear=ibd_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_header_05, ibdyear=ibd_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_header_06, ibdyear=ibd_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_header_07, ibdyear=ibd_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_header_08, ibdyear=ibd_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_header_09, ibdyear=ibd_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_header_10, ibdyear=ibd_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_header_11, ibdyear=ibd_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_header_12, ibdyear=ibd_ot_20&NN._12);
data ibd_ot_20&NN.;
set ibd_ot_20&NN._01 - ibd_ot_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..other_services_header_01, ibdyear=ibd_ot_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_header_02, ibdyear=ibd_ot_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_header_03, ibdyear=ibd_ot_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_header_04, ibdyear=ibd_ot_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_header_05, ibdyear=ibd_ot_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_header_06, ibdyear=ibd_ot_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_header_07, ibdyear=ibd_ot_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_header_08, ibdyear=ibd_ot_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_header_09, ibdyear=ibd_ot_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_header_10, ibdyear=ibd_ot_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_header_11, ibdyear=ibd_ot_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_header_12, ibdyear=ibd_ot_20&NN._12);
data ibd_ot_20&NN.;
set ibd_ot_20&NN._01 - ibd_ot_20&NN._12;
yr_num=20&NN.;
run;

proc sort data=ibd_ot_2014; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ot_2015; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ot_2016; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ot_2017; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ot_2018; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;
proc sort data=ibd_ot_2019; by &pat_idb &clm_beg_dt &flag_cd &flag_uc; run;


*make 1 per year then merge by year and save for final;
data  &ds_all_ip;
    merge
     ibd_ot_2014
	 ibd_ot_2015
	 ibd_ot_2016
	 ibd_ot_2017
	 ibd_ot_2018
	 ibd_ot_2019
    ;
    by &pat_idb &clm_beg_dt &flag_cd &flag_uc;

	if &clm_end_dt < &clm_beg_dt then do;
       		&clm_end_dt = &clm_beg_dt;
    end;
    &flag_ibd =0;
	    if &flag_cd=1 or &flag_uc=1 then do;
	    &flag_ibd = 1;
    end;

    /*** after this step due to sort - fields diag and proc **/
    /*** are no longer significant for this immediate proj because we keep IBD rows only  **/
    drop &diag_pfx.: ;
run;

proc sort data= &ds_all_ip  nodupkey;
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;
*shu172sl.taf_cd_ot_2014_19;
proc freq data=shu172sl.taf_cd_ot_2014_19; 
table cd uc;
run;
