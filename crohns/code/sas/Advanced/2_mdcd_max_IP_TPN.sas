/********************************************************************
* Job Name: 2_mdcd_max_IP_paren_nutrition.sas
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
										  tpn stands for total parenteral nutrition  ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.tpn_ip_2010_2015;

%let  pat_idb            = bene_Id state_cd msis_id           ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global proc_pfx proc_cd_min proc_cd_max ;
%global plc_of_srvc_cd                   ;

%let  proc_pfx           = prcdr_cd_         ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 6                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;

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

%let vars_to_keep_ip_op = 
                          bene_id:
						  &proc_pfx.:
                          &clm_beg_dt
						  &clm_end_dt
                          ;

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
/*   get inpatient procedures                   */

%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );

     data        &view_lib..&prefix.data_tpn_&ctype._&year.    /
          view = &view_lib..&prefix.data_tpn_&ctype._&year.    ;
          set &src_lib_prefix.&year..&prefix.data_&ctype._&year  
					(keep= &pat_id
						  &proc_pfx.:
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


data &proj_ds_pfx.cd_tpn_ip_2010;
    set sviews.maxdata_tpn_ip_2010;
run;

data &proj_ds_pfx.cd_tpn_ip_2011;
    set sviews.maxdata_tpn_ip_2011;
run;

data &proj_ds_pfx.cd_tpn_ip_2012;
    set sviews.maxdata_tpn_ip_2012;
run;

data &proj_ds_pfx.cd_tpn_ip_2013;
    set sviews.maxdata_tpn_ip_2013;
run;

data &proj_ds_pfx.cd_tpn_ip_2014;
    set sviews.maxdata_tpn_ip_2014;
run;

data &proj_ds_pfx.cd_tpn_ip_2015;
    set sviews.maxdata_tpn_ip_2015;
run;

data &shlib..&temp_ds_pfx.temp_tpn_ipop (keep= &pat_id &flag_tpn.:);
set
&proj_ds_pfx.cd_tpn_ip_2010    (in=a)
&proj_ds_pfx.cd_tpn_ip_2011    (in=b)
&proj_ds_pfx.cd_tpn_ip_2012    (in=c)
&proj_ds_pfx.cd_tpn_ip_2013    (in=d)
&proj_ds_pfx.cd_tpn_ip_2014    (in=e)
&proj_ds_pfx.cd_tpn_ip_2015    (in=f)
;
&flag_tpn=1;
rename &clm_beg_dt = &flag_tpn._dt;
run;

proc sort data= &shlib..&temp_ds_pfx.temp_tpn_ipop nodupkey
out=&shlib..&proj_ds_pfx.tpn_ip_2010_2015;
by &pat_id &flag_tpn._dt;
run;


/*count number of times used tpn from inpatient--for checks only--need study specific date
		for study specific count*

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
%mend;

%counts(in=&shlib..&proj_ds_pfx.tpn_ip_2010_2014,
		out=tpn_cnt , 
		date= tpn_dt, 
		date_first=tpn_dt_first,
		date_last=tpn_dt_last,
		flagin=tpn , count=tpn_count );
