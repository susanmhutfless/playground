/********************************************************************
* Job Name: 2_mdcd_max_IP_crohns_cohort.sas
* Job Desc: Input for Inpatient Claims to identify
        all cases of Crohn's disease in Medicaid
	final dataset is IBD hospitalizations only--can't use for studies
	other than to identify IBD cohort
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab
********************************************************************/

/** alert - Read 0_ files first
    alert - the job and settings in 0_ . sas files must be set first **/


/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;   /** libname prefix **/
%global pat_idb clm_id                       ;
%global pat_id                               ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

%let  pat_idb            = bene_Id state_cd msis_id           ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global diag_pfx diag_cd_min diag_cd_max ;
%global proc_pfx proc_cd_min proc_cd_max ;
%global plc_of_srvc_cd                   ;

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_mip_;  /*** prefix to identify temp data
                                          leave the trailing underscore ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/
%global ds_all_prefix                    ;
%let  ds_all_prefix      = ;
%let  ds_all_ip          = &shlib..&proj_ds_pfx.cd_ip_2010_15;

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 9                 ;
%let  proc_pfx           = prcdr_cd_         ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 6                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;

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
%let  clm_admsn_dt		 = 	admsn_dt ;
%let  clm_pymt_dt        = pymt_dt       ;
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = el_dob        ;
%let  sex_cd			 = el_sex_cd			;
%let  race_eth_cd		 = el_race_ethncy_cd ;
%let eth_cd				 = ethnicity_cd;

/*** end of section   - global vars ***/

%global year_1 year_2 year_3 year_4 year_5 year_6;
%let year_1 =2010;
%let year_2 =2011;
%let year_3 =2012;
%let year_4 =2013;
%let year_5 =2014;
%let year_6 =2015;

%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = max;


/*** this section is related to IP - inpatient claims ***/
/*   get inpatient cd diagnoses                         */

%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );

     data        &view_lib..&prefix.data_&ctype._&year.    /
          view = &view_lib..&prefix.data_&ctype._&year.    ;
          set &src_lib_prefix.&year..&prefix.data_&ctype._&year  
				(keep= &pat_idb  &clm_dob 
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
                substr(&diag_pfx.9,1,3) in ( &main_diag_criteria );
                &flag_cd=0;
                &flag_uc=0;
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




%macro cdyear(serveryear=, cdyear=);

data &lwork..&temp_ds_pfx.temp_ip_clm_ds;
set
&serveryear ;
age=(&clm_beg_dt - el_dob)/365.25;
if substr(&diag_pfx.1,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.2,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.3,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.4,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.5,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.6,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.7,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.8,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.9,1,3) in ( &cd_diag_criteria )
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
   substr(&diag_pfx.9,1,3) in ( &uc_diag_criteria )
   then do;
   &flag_uc=1;
   end;
   if &flag_uc=1 or &flag_cd=1;
run;

proc sort data= &lwork..&temp_ds_pfx.temp_ip_clm_ds  nodupkey
           out= &cdyear;
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;

proc datasets lib = &lwork  noprint;
delete &temp_ds_pfx.temp_ip_clm_ds;
quit;
run;

%mend;

%cdyear(serveryear=sviews.maxdata_ip_&year_1, cdyear= &lwork..&temp_ds_pfx.cd_ip_&year_1);
%cdyear(serveryear=sviews.maxdata_ip_&year_2, cdyear= &lwork..&temp_ds_pfx.cd_ip_&year_2);
%cdyear(serveryear=sviews.maxdata_ip_&year_3, cdyear= &lwork..&temp_ds_pfx.cd_ip_&year_3);
%cdyear(serveryear=sviews.maxdata_ip_&year_4, cdyear= &lwork..&temp_ds_pfx.cd_ip_&year_4);
%cdyear(serveryear=sviews.maxdata_ip_&year_5, cdyear= &lwork..&temp_ds_pfx.cd_ip_&year_5);
%cdyear(serveryear=sviews.maxdata_ip_&year_6, cdyear= &lwork..&temp_ds_pfx.cd_ip_&year_6);


data  &ds_all_ip;
    merge
     &lwork..&temp_ds_pfx.cd_ip_&year_1
     &lwork..&temp_ds_pfx.cd_ip_&year_2
     &lwork..&temp_ds_pfx.cd_ip_&year_3
     &lwork..&temp_ds_pfx.cd_ip_&year_4
     &lwork..&temp_ds_pfx.cd_ip_&year_5
	 &lwork..&temp_ds_pfx.cd_ip_&year_6
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
*shu172sl.max_cd_ip_2010_15;

/** extended audits and build of count fields for crohns study **

%field_freq(inds=&ds_all_ip, vartochk= yr_num &flag_cd &flag_uc &flag_ibd &plc_of_srvc_cd);
%field_freqdt(inds=&ds_all_ip, vartochk= &clm_beg_dt );
%field_numbers(inds=&ds_all_ip, vartochk= &clm_beg_dt);

/*** clean up of data - temp - created in lwork space ***/
/*** using the temp prefix ***
proc datasets lib=&lwork. noprint ;
delete &temp_ds_pfx.:;
quit;
run;
