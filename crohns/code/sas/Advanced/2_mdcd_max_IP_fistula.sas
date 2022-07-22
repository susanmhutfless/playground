/********************************************************************
* Job Name: 2_mdcd_max_IP_fistula.sas
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
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

	%global def_proj_src_ds_prefix;
	%let    def_proj_src_ds_prefix = max;

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.fistula_ip_2010_2015;

%let  pat_idb            = bene_id  msis_id state_cd         ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global diag_pfx diag_cd_min diag_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 9                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;


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

%global age;
%global clm_beg_dt clm_end_dt clm_dob;
%global clm_drg ;
%let  age                = age           ;
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = el_dob        ;

/*** end of section   - global vars ***/
%global vars_to_keep_ip_op 	vars_to_keep_ip vars_to_keep_op;
%global vars_to_drop_ip_op  vars_to_drop_ip	vars_to_drop_op;

%let vars_to_keep_ip_op = &pat_id
                          &clm_beg_dt
                          &diag_pfx.: 
						  /*&plc_of_srvc_cd*/
                          ;

%let vars_to_keep_ip    = ;
%let vars_to_keep_op    = ;

%let vars_to_drop_ip    = ;
%let vars_to_drop_op    = ;

%global year_1 year_2 year_3 year_4 year_5 year_6;
%let year_1 =2010;
%let year_2 =2011;
%let year_3 =2012;
%let year_4 =2013;
%let year_5 =2014;
%let year_6 =2015;




/*** this section is related to IP - inpatient claims ***/
/*   identify fistula use based on DX code in inpatient setting                   */

%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );

     data        &view_lib..&prefix.data_fist_&ctype._&year.    /
          view = &view_lib..&prefix.data_fist_&ctype._&year.    ;
          set &src_lib_prefix.&year..&prefix.data_&ctype._&year  (keep= &vars_to_keep_ip_op);
          where substr(&diag_pfx.1,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.2,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.3,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.4,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.5,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.6,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.7,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.8,1,4) in ( &main_diag4_criteria ) or
                substr(&diag_pfx.9,1,4) in ( &main_diag4_criteria );
		&plc_of_srvc_cd=21; /*need to set this specifically to hospital for inpatient*/
		
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
run;
%mend;

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = &year_1                  ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = &year_2                  ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = &year_3                  ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = &year_4                  ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = &year_5                  ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

				 
     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = &year_6                  ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );


data &final_sub_ds;
set
&view_lib..&def_proj_src_ds_prefix.data_fist_ip_2010    (in=a)
&view_lib..&def_proj_src_ds_prefix.data_fist_ip_2011    (in=b)
&view_lib..&def_proj_src_ds_prefix.data_fist_ip_2012    (in=c)
&view_lib..&def_proj_src_ds_prefix.data_fist_ip_2013    (in=d)
&view_lib..&def_proj_src_ds_prefix.data_fist_ip_2014    (in=e)
&view_lib..&def_proj_src_ds_prefix.data_fist_ip_2015    (in=f)
;
run;
