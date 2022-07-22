/********************************************************************
* Job Name: 2_mdcd_max_OP_substance.sas
* Job Desc: Identify substance use in Inpatient (not IBD specific)
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab
********************************************************************/

/** alert - the job and settings in 0_setup_facts.sas must be set first **/

/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;
%global pat_idb clm_id                       ;
%global pat_id                               ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;


    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_sop_;  /*** prefix to identify temp data
                                          leave the trailing underscore ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/
%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.substance_op_2010_2015;

%let  pat_idb            = bene_id msis_id state_cd          ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global diag_pfx diag_cd_min diag_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;
%let  ds_all_prefix      = ;

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 2                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;


/** these are vars to hold diag criteria for substance **/
%global main_diag_criteria    ;
%global co_diag_criteria      ;
%global op_diag_criteria      ;
%global etoh_diag_criteria    ;
%global etohor_diag_criteria  ;
%global mdma_diag_criteria    ;
%global cannabis_diag_criteria;
%global tobacco_diag_criteria ;

/** substance grouping specific to project
    defined codes.
    note that these abbreviations are just
    for syntax - clinician defined names
    are used further below **/

/** substance - cocaine **/
%let  co_diag_criteria   = '30420' '30421' '30423' 
							'30560' '30561' '30562' '30563'
                             '97081' 'R782';
%let  co_diag3_criteria   = 'F14';
%let  co_diag4_criteria   = '3042' '3056' 'T405'; 

/** substance - opioids **/
%let  op_diag_criteria   = '30400' '30401' '30402' '30403' '30470'
                           '30471' '30472' '30473' '30550' '30551'
                           '30552' '30553' '96500' '96501' '96502' '96509'
                           'E8500' 'E8501' 'E8502' 'E9350' 'E9351' 'E9352' ;
%let  op_diag3_criteria   = 'F11' ;
%let  op_diag4_criteria   = '3040' '3047' '3055' '9650' 'T400' 'T401' 'T402' 'T403'  'T404' 'T406' ;

/* substance - alcohol **/
%let  etoh_diag_criteria   = '2910' '2911' '2912' '2913' '2914'
                             '2915' '29181' '29182' '29189' '2919'
                             '30300' '30301' '30302' '30303' '30390'
                             '30391' '30392' '30393' '30500' '30501' '30502' '30503'
                             '7903' '9800' '9801' '9802' '9803' '9808' '9809' 'E8600'
                             'E8601' 'E8602' 'E8603' 'V113' '5710' '5711' '5712' '5713' '4255' '53530'
                             '53531' '3575' 'I426'  ;
%let  etoh_diag3_criteria   = '291' '303' '980' 'F10' 'K70' 'T51' ;
%let  etoh_diag4_criteria   = '3050' '5353' '3575' 'G621' 'K292' 'K852' 'K860' 'R780' ;

/** substance - alcohol organ **/
%let  etohor_diag_criteria   = '5710' '5711' '5712' '5713' '4255' '53530' '53531' '3575' ;
%let  etohor_diag3_criteria   = 'K70' ;
%let  etohor_diag4_criteria   = 'I426' 'K292' 'K852' 'K860' 'G621' ;

/** substance - mdma **/
%let  mdma_diag_criteria   = '30440' '30441' '30442' '30443' '30570' '30571'
                             '30572' '30573' '96972' 'E8542' 'T436' ;
%let  mdma_diag3_criteria   = 'F15' ;
%let  mdma_diag4_criteria   = '3044' '3057';

/** substance - cannibis **/
%let  cannabis_diag_criteria   = '30430' '30431' '30432' '30433'
                                 '30520' '30521' '30522' '30523';
%let  cannabis_diag3_criteria   = 'F12';
%let  cannabis_diag4_criteria   = '3043' '3052' 'T407';

/** substance - tobacco **/
%let  tobacco_diag_criteria   = '3051' 'V1582' 'Z87891';
%let  tobacco_diag3_criteria   = 'F17';
%let  tobacco_diag4_criteria   = 'T652' 'Z716' 'Z720';  


/** pull all substances at once **/
%let  main_diag_criteria =
&co_diag_criteria 		&op_diag_criteria 		&etoh_diag_criteria		&etohor_diag_criteria 	
&mdma_diag_criteria		&cannabis_diag_criteria	&tobacco_diag_criteria;

%let  main_diag3_criteria = &co_diag3_criteria	&op_diag3_criteria &mdma_diag3_criteria
							&etoh_diag3_criteria &etohor_diag3_criteria
							&tobacco_diag3_criteria &cannabis_diag3_criteria;
%let  main_diag4_criteria = &co_diag4_criteria	&op_diag4_criteria  &mdma_diag4_criteria
							&etoh_diag4_criteria &etohor_diag4_criteria
							&tobacco_diag4_criteria &cannabis_diag4_criteria;


/** substance - assign project clinician specific names **/
%global flag_co     ;%let flag_co          = cocaine   ;
%global flag_op     ;%let flag_op          = opioids   ;
%global flag_etoh   ;%let flag_etoh        = etoh      ;
%global flag_etohorg;%let flag_etohorg     = etoh_organ;
%global flag_mdma   ;%let flag_mdma        = mdma      ;
%global flag_can    ;%let flag_can         = cannabis  ;
%global flag_tob    ;%let flag_tob         = tobacco   ;

%global age;
%global clm_beg_dt clm_end_dt clm_dob clm_pymt_dt;
%global clm_drg ;
%let  age                = age           ;
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = el_dob        ;

/*** end of section   - global vars ***/

%global vars_to_keep_ip_op;
%global vars_to_keep_ip   ;

%global vars_to_drop_op   ;
%global vars_to_drop_op   ;


/*** this section is related to OP - outpatient claims ***/

/*** end result view creation by state, year ***/
%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  state          = ,
                  ctype          = );

     data        &view_lib..&prefix.data_sub_&ctype.&state._&year.    /
          view = &view_lib..&prefix.data_sub_&ctype.&state._&year.    ;
          set &src_lib_prefix.&year..&prefix.data&state._&ctype._&year  
						(keep= &pat_id
                          &clm_beg_dt
                          &diag_pfx.: 
						  &plc_of_srvc_cd	) ;
         where &diag_pfx.1 in : ( &main_diag_criteria )
            or &diag_pfx.2 in : ( &main_diag_criteria )
			or substr(&diag_pfx.1,1,3) in ( &main_diag3_criteria ) 
            or substr(&diag_pfx.2,1,3) in ( &main_diag3_criteria ) 
			or substr(&diag_pfx.1,1,4) in ( &main_diag4_criteria ) 
            or substr(&diag_pfx.2,1,4) in ( &main_diag4_criteria ) 
;

array dx(&diag_cd_max.) &diag_pfx.1 - &diag_pfx.&diag_cd_max.;
  do i=1 to &diag_cd_max.;
    if dx(i) in (&co_diag_criteria)
    then do;
        &flag_co           =1;
        &flag_co._dt       =srvc_bgn_dt;
        &flag_co._plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
		if substr(dx(i),1,3) in (&co_diag3_criteria)
	    then do;
	        &flag_co           =1;
	        &flag_co._dt       =srvc_bgn_dt;
	        &flag_co._plc_of_srvc_cd     =&plc_of_srvc_cd;
	    end;
		if substr(dx(i),1,4) in (&co_diag4_criteria)
	    then do;
	        &flag_co           =1;
	        &flag_co._dt       =srvc_bgn_dt;
	        &flag_co._plc_of_srvc_cd     =&plc_of_srvc_cd;
	    end;

    if dx(i) in (&op_diag_criteria)
    then do;
        &flag_op           =1;
        &flag_op._dt       =srvc_bgn_dt;
        &flag_op._plc_of_srvc_cd     =&plc_of_srvc_cd;
    end;
		if substr(dx(i),1,3) in (&op_diag3_criteria)
		    then do;
		        &flag_op           =1;
		        &flag_op._dt       =srvc_bgn_dt;
		        &flag_op._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;
			if substr(dx(i),1,4) in (&op_diag4_criteria)
		    then do;
		        &flag_op           =1;
		        &flag_op._dt       =srvc_bgn_dt;
		        &flag_op._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;
    if dx(i) in (&etoh_diag_criteria &etohor_diag_criteria)
    then do;
        &flag_etoh         =1;
        &flag_etoh._dt     =srvc_bgn_dt;
        &flag_etoh._plc_of_srvc_cd   =&plc_of_srvc_cd;
    end;
			if substr(dx(i),1,3) in (&etoh_diag3_criteria &etohor_diag3_criteria)
		    then do;
		        &flag_etoh           =1;
		        &flag_etoh._dt       =srvc_bgn_dt;
		        &flag_etoh._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;
			if substr(dx(i),1,4) in (&etoh_diag4_criteria &etohor_diag4_criteria)
		    then do;
		        &flag_etoh           =1;
		        &flag_etoh._dt       =srvc_bgn_dt;
		        &flag_etoh._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;

    if dx(i) in (&etohor_diag_criteria)
    then do;
        &flag_etohorg      =1;
        &flag_etohorg._dt  =srvc_bgn_dt;
        &flag_etohorg._plc_of_srvc_cd=&plc_of_srvc_cd;
    end;
			if substr(dx(i),1,3) in (&etohor_diag3_criteria)
		    then do;
		        &flag_etohorg           =1;
		        &flag_etohorg._dt       =srvc_bgn_dt;
		        &flag_etohorg._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;
			if substr(dx(i),1,4) in (&etohor_diag4_criteria)
		    then do;
		        &flag_etohorg           =1;
		        &flag_etohorg._dt       =srvc_bgn_dt;
		        &flag_etohorg._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;

    if dx(i) in (&mdma_diag_criteria)
    then do;
        &flag_mdma         =1;
        &flag_mdma._dt     =srvc_bgn_dt;
        &flag_mdma._plc_of_srvc_cd   =&plc_of_srvc_cd;
    end;
		if substr(dx(i),1,3) in (&mdma_diag3_criteria)
		    then do;
		        &flag_mdma           =1;
		        &flag_mdma._dt       =srvc_bgn_dt;
		        &flag_mdma._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;
			if substr(dx(i),1,4) in (&mdma_diag4_criteria)
		    then do;
		        &flag_mdma           =1;
		        &flag_mdma._dt       =srvc_bgn_dt;
		        &flag_mdma._plc_of_srvc_cd     =&plc_of_srvc_cd;
		    end;
    if dx(i) in (&cannabis_diag_criteria)
    then do;
        &flag_can          =1;
        &flag_can._dt      =srvc_bgn_dt;
        &flag_can._plc_of_srvc_cd    =&plc_of_srvc_cd;
    end;
		if substr(dx(i),1,3) in (&cannabis_diag3_criteria)
	    then do;
	        &flag_can           =1;
	        &flag_can._dt       =srvc_bgn_dt;
	        &flag_can._plc_of_srvc_cd     =&plc_of_srvc_cd;
	    end;
		if substr(dx(i),1,4) in (&cannabis_diag4_criteria)
	    then do;
	        &flag_can           =1;
	        &flag_can._dt       =srvc_bgn_dt;
	        &flag_can._plc_of_srvc_cd     =&plc_of_srvc_cd;
	    end;
    if dx(i) in (&tobacco_diag_criteria)
    then do;
        &flag_tob          =1;
        &flag_tob._dt      =srvc_bgn_dt;
        &flag_tob._plc_of_srvc_cd    =&plc_of_srvc_cd;
    end;
		if substr(dx(i),1,3) in (&tobacco_diag3_criteria)
	    then do;
	        &flag_tob           =1;
	        &flag_tob._dt       =srvc_bgn_dt;
	        &flag_tob._plc_of_srvc_cd     =&plc_of_srvc_cd;
	    end;
		if substr(dx(i),1,4) in (&tobacco_diag4_criteria)
	    then do;
	        &flag_tob           =1;
	        &flag_tob._dt       =srvc_bgn_dt;
	        &flag_tob._plc_of_srvc_cd     =&plc_of_srvc_cd;
	    end;
end;

drop &diag_pfx.: i;
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
         delete  &file_name_prefix.sub_&file_type_code._:   (memtype = view);
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
          set sviews.maxdata_sub_ot: ;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_sub_ot_   );


/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data &final_sub_ds;
    set sviews.maxds_sub_ot_ch
        ;
run;


