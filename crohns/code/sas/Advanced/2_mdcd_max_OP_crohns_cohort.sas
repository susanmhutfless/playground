/********************************************************************
* Job Name: 2_mdcd_max_OP_crohns_cohort.sas
* Job Desc: Using outpatient Medicaid claims identify crohns cohort
final file is to make an IBD cohort only--not for research
* COPYRIGHT (c) 2019 2020 2021 Johns Hopkins University - HutflessLab
********************************************************************/

/** alert - read the 0_ instructions first
    alert - the job and settings in 0_.sas must be set first **/


/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;
%global pat_idb clm_id                       ;
%global pat_id                               ;


/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

%let  pat_idb            = bene_id state_cd msis_id          ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global diag_pfx diag_cd_min diag_cd_max ;
%global proc_pfx proc_cd_min proc_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_mop_;  /*** prefix to identify temp data
                                          leave the trailing underscore ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%let  ds_all_prefix      = ;
%let  ds_all_op          = &shlib..&proj_ds_pfx.cd_ot_2010_15;

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 2                 ;
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

%global age;	/*using generic age here -- will make CD specific age in 3_*/
%global clm_beg_dt clm_end_dt clm_dob clm_pymt_dt;
%global clm_drg ;
%let  age                = age           ;
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_pymt_dt        = pymt_dt       ;
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = el_dob        ;
%let  sex_cd			 = el_sex_cd			;


/*** end of section   - global vars ***/

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
				(keep= &pat_idb  &clm_dob /*&sex_cd*/
								 &clm_beg_dt &clm_end_dt
								&diag_pfx.: &proc_pfx.: 
                                &plc_of_srvc_cd ) ;
         where substr(&diag_pfx.1,1,3) in : ( &main_diag_criteria )
            or substr(&diag_pfx.2,1,3) in : ( &main_diag_criteria );
         &age=( &clm_beg_dt - &clm_dob )/365.25;
         &flag_cd=0;
         &flag_uc=0;

         if substr(&diag_pfx.1,1,3) in(&cd_diag_criteria) or substr(&diag_pfx.2,1,3) in(&cd_diag_criteria) then do;
             &flag_cd=1;
         end;
         if substr(&diag_pfx.1,1,3) in(&uc_diag_criteria) or substr(&diag_pfx.2,1,3) in(&uc_diag_criteria) then do;
             &flag_uc=1;
         end;
         if &flag_cd=1 or &flag_uc=1;
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
             where &flag_uc =1 or &flag_cd =1;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_ot_   );


/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data &ds_all_op;
    set sviews.maxds_ot_ch
        ;
   where &flag_uc =1 or &flag_cd =1;
/* 2 have negative fup dates--both hospitalizated
   and say discharge date before admit date--change
   discharge date to admit date **/

    if &clm_end_dt < &clm_beg_dt then do;
       &clm_end_dt = &clm_beg_dt;
    end;

    &flag_ibd =0;
    if &flag_cd=1 or &flag_uc=1 then do;
    &flag_ibd = 1;
    end;
    /*** after this step due to sort - fields diag and proc **/
    /*** are no longer significant for this immediate proj  **/
    drop &diag_pfx.: &proc_pfx.: ;

run;


proc sort data= &ds_all_op nodupkey
           out= &ds_all_op ;
by &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;

*%field_freq(inds=&ds_all_op, vartochk= yr_num &flag_cd &flag_uc &flag_ibd);
*%field_freqdt(inds=&ds_all_op, vartochk= &clm_beg_dt );
*%field_numbers(inds=&ds_all_op, vartochk= &clm_beg_dt);

/*** clean up of data - temp - created in lwork space ***/
/*** using the temp prefix ***
proc datasets lib=&lwork. noprint ;
delete &temp_ds_pfx.:;
quit;
run;
