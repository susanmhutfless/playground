/********************************************************************
* Job Name: 2_mdcd_max_OP_TPN.sas
* Job Desc: Identify all total parenteral nutrition in OUTpatient setting
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
%let    final_sub_ds = &shlib..&proj_ds_pfx.tpn_ot_2010_2015;

%let  pat_idb            = bene_id state_cd msis_id            ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global proc_pfx proc_cd_min proc_cd_max ;
%global plc_of_srvc_cd                   ;

%let  proc_pfx           = prcdr_cd         ;
%let  proc_cd_min        =                  ;*there is only 1 prcdr code in Medicaid OT*;
%let  proc_cd_max        =                  ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;


%global proc_pfx proc_cd_min proc_cd_max ;
%global plc_of_srvc_cd                   ;

%let  proc_pfx           = prcdr_cd         ;
%let  proc_cd_min        =                  ;*there is only 1 prcdr code in Medicaid OT*;
%let  proc_cd_max        =                  ;
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
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_drg            = clm_drg_cd    ;


%global year_1 year_2 year_3 year_4 year_5 year_6;
%let year_1 =2010;
%let year_2 =2011;
%let year_3 =2012;
%let year_4 =2013;
%let year_5 =2014;
%let year_6 =2015;

%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = max;

/*** this section is related to OP - outpatient claims ***/

/*** end result view creation by state, year ***/
%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  state          = ,
                  ctype          = );

     data        &view_lib..&prefix.data_&ctype.&state._&year.    /
          view = &view_lib..&prefix.data_&ctype.&state._&year.    ;
          set &src_lib_prefix.&year..&prefix.data&state._&ctype._&year  
			(keep= &pat_id &plc_of_srvc_cd &proc_pfx &clm_beg_dt &clm_end_dt) ;
           where &proc_pfx in (  &tpn_10_criteria ) or
		   substr(&proc_pfx,1,4) in ( &tpn_09_criteria_4 ) or
		   &proc_pfx in ( &tpn_cpt_criteria );
     run;
%mend;

/*** macro that calls views - runs by year and state loops ***/
%macro make_views_dsk(y_list     =,
                      m_list     =,
                      ctype      = );
     %let year_idx=1;
     %let year_to_do= %scan(&y_list        ,  &year_idx);
     %do %while (&year_to_do   ne);

         %let st_idx=1;
         %let st_to_do=%scan( &m_list  , &st_idx);
             %do %while ( &st_to_do   ne);

                     %create_dsk(view_lib      = &view_lib                ,
                                 src_lib_prefix= &def_proj_src_ds_prefix  ,
                                 year          = &year_to_do              ,
                                 prefix        = &def_proj_src_ds_prefix  ,
                                 state         = &st_to_do                ,
                                 ctype         = &ctype         );

                 %let st_idx   = %eval( &st_idx + 1);
                 %let st_to_do = %scan( &m_list , &st_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;


/*** overall driver macro that allows us to configure which year and state to spin thru ***/
/*** this macro also does a clean up first by removing and deleting pre existing views  ***/
/*** its important to NEVER mix up project views in view folders to ensure safety       ***/
/*** its also important to never mix real sas data with sas views in this type of method***/

%macro build_views(file_name_prefix = ,
                   file_type_code   = ,
                   out_ds_combo     = );
     proc datasets lib= &view_lib noprint ;
         delete  &file_name_prefix.&file_type_code._:   (memtype = view);
         delete  &out_ds_combo.&file_type_code          (memtype = view);
     quit;
     run;

      /*** here we custom configure which year, state we want to spin thru   ***/
      /*** note for each state the _ prefix - this is due to how macro       ***/
      /*** interprets the state of oregon 'o r' as actual syntax and falters ***/
      /*** the underscore prefix quickly solves that but i'll find a better  ***/
      /*** solution later ***/
      %make_views_dsk(y_list= 2010      2012 2013 2014 2015 , m_list= _id                  , ctype= ot );
	  	%make_views_dsk(y_list=      2011 2012 2013           , m_list= _ak _al _co _dc _de _fl _il 
																		_ks _md _me _mt
																		_nc _nd _ny _ne _nh _nm _nv 
																		_ri _wi, ctype= ot );  

        %make_views_dsk(y_list= 2010 2011 2012 2013 2014      , m_list=  _az _ct _hi _ky _in _ma																		
																	     _oh _ok _or _sc _tx _va _wa , ctype= ot );
		%make_views_dsk(y_list= 2010 2011 2012 2013 2014 2015 , m_list=  _ar  
																 _ca  _ct   
																  _ga  _ia    
																      _la       _mi
                                                                 _mn _mo _ms   _nj  _ny   _or _pa
                                                                   _sd _tn  _ut  _vt
																   _wv _wy      , ctype= ot );
    /*** here we combine all the individual "views" into a single bigger "view" ***/
     data        &view_lib..&out_ds_combo.&file_type_code   /
          view = &view_lib..&out_ds_combo.&file_type_code   ;
          set sviews.maxdata_ot: ;

&flag_tpn=1;
rename &clm_beg_dt = &flag_tpn._dt;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_ot_   );


/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data final_sub_ds;
    set sviews.maxds_ot_ch
        ;
   where &flag_tpn=1;
run;


proc sort data= final_sub_ds nodupkey
           out= &final_sub_ds ;					/*& important here!*/
by &pat_idb &flag_tpn &flag_tpn._dt;
run;



		/*** clean up of data - temp - created in lwork space ***/
/*** using the temp prefix ***
proc datasets lib=&lwork. noprint ;
delete &temp_ds_pfx.:;
quit;
run;
