/********************************************************************
* Job Name: 2_mdcd_max_OP_fistula.sas
* Job Desc: Identify fistula use in Inpatient (not IBD specific)
* COPYRIGHT (c) 2019 2020 2021 Johns Hopkins University - HutflessLab
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
    %let    temp_ds_pfx = tmp_fop_;  /*** prefix to identify temp data (fop stands for fistula outpatient)
                                          leave the trailing underscore ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/
%global final_fist_ds;
%let    final_fist_ds = &shlib..&proj_ds_pfx.fistula_op_2010_2015;

%let  pat_idb            = bene_id   msis_id state_cd        ;
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

%let vars_to_keep_ip_op = &pat_id
                          &clm_beg_dt
                          &diag_pfx.: 
						  &plc_of_srvc_cd
                          ;



/*** this section is related to OP - outpatient claims ***/

/*** end result view creation by state, year ***/
%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  state          = ,
                  ctype          = );

     data        &view_lib..&prefix.data_fist_&ctype.&state._&year.    /
          view = &view_lib..&prefix.data_fist_&ctype.&state._&year.    ;
          set &src_lib_prefix.&year..&prefix.data&state._&ctype._&year  (keep= &vars_to_keep_ip_op	) ;
         where substr(&diag_pfx.1,1,4) in : ( &main_diag4_criteria )
            or substr(&diag_pfx.2,1,4) in : ( &main_diag4_criteria );

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
         delete  &file_name_prefix.fist_&file_type_code._:   (memtype = view);
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
          set sviews.maxdata_fist_ot: ;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_fist_ot_   );


/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data &final_fist_ds;
    set sviews.maxds_fist_ot_ch
        ;
run;


