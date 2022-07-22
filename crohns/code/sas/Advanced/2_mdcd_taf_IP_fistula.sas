/********************************************************************
* Job Name: 2_mdcd_taf_IP_fistula.sas
* Job Desc: Identify fistula use in Inpatient (not IBD specific)
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
    %let    temp_ds_pfx = tmp_fist_;  /*** prefix to identify temp data
                                          leave the trailing underscore ***/
										/*fist is for fistula inpatient*/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = taf_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

	%global def_proj_src_ds_prefix;
	%let    def_proj_src_ds_prefix = taf;

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.fistula_ip_2014_2019;

%let  pat_idb            = bene_id  msis_id state_cd         ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;
%let  clm_beg_dt         = srvc_bgn_dt   ;

%let  diag_pfx           = dgns_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 12                 ;
%let  proc_pfx           = prcdr_cd_         ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 6                 ;
%let plc_of_srvc_cd		 = HOSP_TYPE_CD		;

/** these are vars to hold diag criteria for fistula **/
%global main_diag4_criteria    ;
%global fist_intest_09_diag_crit	fist_intest_10_diag_crit      
		fist_peri_09_diag_crit		fist_peri_10_diag_crit
		fist_rectvag_09_diag_crit	fist_rectvag_10_diag_crit;
		
%let  fist_intest_09_diag_crit   = '56981' '5961' '5374'; *56981 is intestinal fistula; *5374 is stomach or duodenum; *5961 is Intestinovesical fistula;
%let  fist_intest_10_diag_crit   = 'K632'  'N321' 'K316'; *need to use with substr4;

%let  fist_peri_09_diag_crit	 = '5651'				; *566 abscess of anal and recta regions;
%let  fist_peri_10_diag_crit	 = 'K603' 'K604' 'K605'	; *abscess: K610, K611, K613'; *K614 is sphincter abscess; *k615 is Supralevator abscess;

%let  fist_rectvag_09_diag_crit	 = '6191'	;
%let  fist_rectvag_10_diag_crit	 = 'N822' 'N823' 'N824'	;
*using substring for main diag ctiteria;
%let  main_diag4_criteria   = '5698' '5961' '5374' 'K632' &fist_intest_10_diag_crit      
		&fist_peri_09_diag_crit		&fist_peri_10_diag_crit
		&fist_rectvag_09_diag_crit	&fist_rectvag_10_diag_crit;

/** fistula flag**/
%global flag_fist     ;%let flag_fist          = fistula   ;


%macro ibdyear(serveryear=, ibdyear=);
		data    &ibdyear;
		          set &serveryear 
						(keep= &pat_idb   &clm_beg_dt 
								&diag_pfx.: &plc_of_srvc_cd);
		     where substr(&diag_pfx.1,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.2,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.3,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.4,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.5,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.6,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.7,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.8,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.9,1,4) in ( &main_diag4_criteria ) or
				substr(&diag_pfx.10,1,4) in ( &main_diag4_criteria ) or
				substr(&diag_pfx.11,1,4) in ( &main_diag4_criteria ) or
				substr(&diag_pfx.12,1,4) in ( &main_diag4_criteria )		;
array dx(&diag_cd_max.) &diag_pfx.1 - &diag_pfx.&diag_cd_max.;
  do i=1 to &diag_cd_max.;
    if dx(i) in (&fist_intest_09_diag_crit)
    then do;
        &flag_fist           =1;
        &flag_fist._dt       =srvc_bgn_dt;
        &flag_fist._plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
    if substr(dx(i),1,4) in (&fist_intest_10_diag_crit 
							 &fist_peri_09_diag_crit		&fist_peri_10_diag_crit
							 &fist_rectvag_09_diag_crit		&fist_rectvag_10_diag_crit)
    then do;
        &flag_fist           =1;
        &flag_fist._dt       =srvc_bgn_dt;
        &flag_fist._plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
	if dx(i) in (&fist_intest_09_diag_crit)
    then do;
        fistula_intest           =1;
        fistula_intest_dt       =srvc_bgn_dt;
        fistula_intest_plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
    if substr(dx(i),1,4) in (&fist_intest_10_diag_crit)
    then do;
        fistula_intest           =1;
        fistula_intest_dt       =srvc_bgn_dt;
        fistula_intest_plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
	if substr(dx(i),1,4) in (&fist_peri_09_diag_crit &fist_peri_10_diag_crit)
    then do;
        fistula_perianal           =1;
        fistula_perianal_dt       =srvc_bgn_dt;
        fistula_peri_plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
		if substr(dx(i),1,4) in (&fist_rectvag_09_diag_crit &fist_rectvag_10_diag_crit)
    then do;
        fistula_rectvag           =1;
        fistula_rectvag_dt       =srvc_bgn_dt;
        fistula_rectvag_plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
end;
format &flag_fist._dt fistula_intest_dt fistula_perianal_dt fistula_rectvag_dt date9.;
drop &diag_pfx.: i ;
if &flag_fist ne 1 then delete;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=fist_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=fist_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=fist_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=fist_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=fist_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=fist_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=fist_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=fist_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=fist_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=fist_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=fist_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=fist_ip_20&NN._12);
data fist_ip_20&NN.;
set fist_ip_20&NN._01 - fist_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=fist_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=fist_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=fist_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=fist_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=fist_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=fist_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=fist_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=fist_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=fist_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=fist_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=fist_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=fist_ip_20&NN._12);
data fist_ip_20&NN.;
set fist_ip_20&NN._01 - fist_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=fist_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=fist_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=fist_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=fist_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=fist_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=fist_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=fist_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=fist_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=fist_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=fist_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=fist_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=fist_ip_20&NN._12);
data fist_ip_20&NN.;
set fist_ip_20&NN._01 - fist_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=fist_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=fist_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=fist_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=fist_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=fist_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=fist_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=fist_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=fist_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=fist_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=fist_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=fist_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=fist_ip_20&NN._12);
data fist_ip_20&NN.;
set fist_ip_20&NN._01 - fist_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=fist_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=fist_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=fist_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=fist_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=fist_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=fist_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=fist_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=fist_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=fist_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=fist_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=fist_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=fist_ip_20&NN._12);
data fist_ip_20&NN.;
set fist_ip_20&NN._01 - fist_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=fist_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=fist_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=fist_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=fist_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=fist_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=fist_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=fist_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=fist_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=fist_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=fist_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=fist_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=fist_ip_20&NN._12);
data fist_ip_20&NN.;
set fist_ip_20&NN._01 - fist_ip_20&NN._12;
yr_num=20&NN.;
run;

*make 1 per year then set by year and save for final;
data  ds_fist_ip;
    set
     fist_ip_2014
	 fist_ip_2015
	 fist_ip_2016
	 fist_ip_2017
	 fist_ip_2018
	 fist_ip_2019
    ;
    drop &diag_pfx.: ;
run;

proc sort data= ds_fist_ip  nodupkey out = &final_sub_ds;
by &pat_idb fistula_dt fistula_intest_dt fistula_perianal_dt fistula_rectvag_dt;
run;
*shu172sl.taf_fistula_ip_2014_19;

proc freq data=&final_sub_ds; 
table fistula fistula_intest fistula_perianal fistula_rectvag;
run;
