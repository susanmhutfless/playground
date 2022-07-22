/********************************************************************
* Job Name: 2_mdcd_max_IP_IBDHosp.sas
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
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.ibdhosp_ip_2010_2015;

%let  pat_idb            = bene_id  state_cd msis_id         ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

/*this variable relies on diag codes only*/
%global diag_pfx diag_cd_min diag_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 9                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;


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
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = el_dob        ;

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
/*   get inpatient IBD hospitalizations                   */

%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );

     data        &view_lib..&prefix.data_ibdhosp_&ctype._&year.    /
          view = &view_lib..&prefix.data_ibdhosp_&ctype._&year.    ;
          set &src_lib_prefix.&year..&prefix.data_&ctype._&year  
			(keep= &pat_idb  &clm_dob 
								 &clm_beg_dt &clm_end_dt
								&diag_pfx.:   );
          where substr(&diag_pfx.1,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.2,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.3,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.4,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.5,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.6,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.7,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.8,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.9,1,3) in ( &main_diag_criteria );
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

data &cdyear ;
set
&serveryear ;
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
   substr(&diag_pfx.9,1,3) in ( &uc_diag_criteria )
   then do;
   &flag_uc=1;
   &flag_uc._dt = &clm_beg_dt;
   end;
   if &flag_uc=1 or &flag_cd=1;
run;

proc sort data= &cdyear  nodupkey
           out= &cdyear;
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;

%mend;

%cdyear(serveryear=sviews.maxdata_ibdhosp_ip_&year_1, cdyear= &lwork..&temp_ds_pfx.ibdhosp_ip_&year_1);
%cdyear(serveryear=sviews.maxdata_ibdhosp_ip_&year_2, cdyear= &lwork..&temp_ds_pfx.ibdhosp_ip_&year_2);
%cdyear(serveryear=sviews.maxdata_ibdhosp_ip_&year_3, cdyear= &lwork..&temp_ds_pfx.ibdhosp_ip_&year_3);
%cdyear(serveryear=sviews.maxdata_ibdhosp_ip_&year_4, cdyear= &lwork..&temp_ds_pfx.ibdhosp_ip_&year_4);
%cdyear(serveryear=sviews.maxdata_ibdhosp_ip_&year_5, cdyear= &lwork..&temp_ds_pfx.ibdhosp_ip_&year_5);
%cdyear(serveryear=sviews.maxdata_ibdhosp_ip_&year_6, cdyear= &lwork..&temp_ds_pfx.ibdhosp_ip_&year_6);



data  &lwork..&temp_ds_pfx.tmp_all_grps
    (keep=  &pat_idb &clm_beg_dt
            &flag_cd:
            &flag_uc:
            &flag_ibd: );

    merge
     &lwork..&temp_ds_pfx.ibdhosp_ip_&year_1
     &lwork..&temp_ds_pfx.ibdhosp_ip_&year_2
     &lwork..&temp_ds_pfx.ibdhosp_ip_&year_3
     &lwork..&temp_ds_pfx.ibdhosp_ip_&year_4
     &lwork..&temp_ds_pfx.ibdhosp_ip_&year_5
	 &lwork..&temp_ds_pfx.ibdhosp_ip_&year_6
    ;

    by &pat_idb &clm_beg_dt &flag_cd &flag_uc;

    &flag_ibd =0;

    if &flag_cd=1 or &flag_uc=1 then do;
    &flag_ibd = 1; 
	&flag_ibd._dt = &clm_beg_dt;
    end;
run;

proc sort data= &lwork..&temp_ds_pfx.tmp_all_grps nodupkey
out=&shlib..&proj_ds_pfx.ibdhosp_ip_2010_2015;			/*final dataset*/
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;



/*%macro SKIP ;
/*count number of IBD hospitalizations from inpatient--this is for a check
	for final need to take into accunt study-specific 1st date*
*need to make bene_msis_st_id to run this check;
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

%counts(in=&shlib..&proj_ds_pfx.ibdhosp_ip_2010_2015,
		out=ibd_hosp_ip_cnt , 
		date= ibd_ip_hosp_dt, 
		date_first=ibd_ip_hosp_dt_first,
		date_last=ibd_ip_hosp_dt_last,
		flagin=ibd_ip_hosp , count=ibd_ip_hosp_count );
