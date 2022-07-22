*try making ip ibdsurg to outpatient;
/********************************************************************
* Job Name: 2_mdcd_max_OP_IBDSurg.sas
* Job Desc: Identify all IBD-related surgical procedures in OUTpatient setting
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab
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
    %let    temp_ds_pfx = tmp_isr_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										  isr stands for ibd surgery  ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.ibdsurg_ot_2010_2015;

%let  pat_idb            = bene_id state_cd msis_id            ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global proc_pfx proc_cd_min proc_cd_max ;
%global plc_of_srvc_cd                   ;

%let  proc_pfx           = prcdr_cd         ;*note that I dropped underscore for medicaid;
%let  proc_cd_min        =                  ;*there is only 1 prcdr code in Medicaid OT*;
%let  proc_cd_max        =                  ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;


%global ibd_sur_09_criteria_2 ibd_sur_09_criteria_3 ibd_sur_09_criteria_4 
		ibd_sur_10_criteria_2 ibd_sur_cpt_criteria     ;

/*need to use substrings for 9 and 10 here!*/
%let  ibd_sur_09_criteria_2   = '46'													;
%let  ibd_sur_09_criteria_3   = '173' '456' '457' '458' '459' '484' '485' '486' '491'	;
%let  ibd_sur_09_criteria_4   = '4973' '5783' '7072' '7073' '7074'						;

%let  ibd_sur_10_criteria_2   = '0D';

%let  ibd_sur_cpt_criteria =    '44120' '44121' '44122' '44123' '44124' '44125' 
								'44126' '44127' '44128' '44129'
								'44130' '44131' '44132' '44133' '44134' '44135' 
								'44136' '44137' '44138' '44139'
								'44140' '44141' '44142' '44143' '44144' '44145' 
								'44146' '44147' '44148' '44149'
								'44150' '44151' '44152' '44153' '44154' '44155' 
								'44156' '44157' '44158' '44159' '44160'
								'44202' '44203' '44204' '44205' '44206' '44207'
								'44208' '44209' '44210' '44211' '44212' '44213'
								'44227' '44625' '44626' 
								'45100' '45101' '45102' '45103' '45104' '45105'
								'45106' '45107' '45108' '45109'
								'45110' '45111' '45112' '45113' '45114' '45115'
								'45116' '45117' '45118' '45119'
								'45120' '45121' '45122' '45123' '45124' '45125'
								'45126' '45127' '45128' '45129'
								'45130' '45131' '45132' '45133' '45134' '45135'
								'45136' '45137' '45138' '45139'
								'45140' '45141' '45142' '45143' '45144' '45145'
								'45146' '45147' '45148' '45149'
								'45150' '45151' '45152' '45153' '45154' '45155'
								'45156' '45157' '45158' '45159'
								'45160' '45161' '45162' '45163' '45164' '45165'
								'45166' '45167' '45168' '45169'
								'45170' '45171' '45172' 
								'45395' '45397'
								'46020' '46030' '46040' '46045' '46050' '46060'
								'46258' '46270' '46275' '46280' '46285' '46288' 
								'46706' '46707' '46715'
								'57300' '57305' '57307' '57308'
								;
/***************************************************
ICD-10 PROCEDURE - need this additional info to look at specific procedures!
if (substr(icd9_pr,1,2)) in ('0D') and
   (substr(icd9_pr,3,1)) in ('B' 'P' 'Q' 'T') and
   (substr(icd9_pr,4,1)) in ('8' '9' 'A' 'B'
                             'C' 'D' 'E' 'F'
                             'G' 'H' 'K' 'L'
                             'M' 'N' 'P')
***************************************************/

/**flag for ibd surgery  **/
%global flag_ibd_surg  ;
%let    flag_ibd_surg          = ibd_op_surg  ;

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
					(keep= &pat_id &proc_pfx &plc_of_srvc_cd &clm_beg_dt &clm_end_dt) ;
           where substr(&proc_pfx,1,2) in ( &ibd_sur_09_criteria_2 &ibd_sur_10_criteria_2 ) or
				substr(&proc_pfx,1,3) in ( &ibd_sur_09_criteria_3 ) or
				substr(&proc_pfx,1,4) in ( &ibd_sur_09_criteria_4 ) or
				&proc_pfx in ( &ibd_sur_cpt_criteria ) ;
			*more nuance to icd10 surgeries;
					if substr(&proc_pfx,1,2) in(&ibd_sur_09_criteria_2) then do; surg=1; end;
					if substr(&proc_pfx,1,3) in(&ibd_sur_09_criteria_3) then do; surg=1; end;
					if substr(&proc_pfx,1,4) in(&ibd_sur_09_criteria_4) then do; surg=1; end;
					if &proc_pfx in(&ibd_sur_cpt_criteria) then do; surg=1; end;
					if substr(&proc_pfx,1,2) in(&ibd_sur_10_criteria_2) 
					then do;
						if 	(substr(&proc_pfx,3,1)) in ('B' 'P' 'Q' 'T') and
   							(substr(&proc_pfx,4,1)) in ('8' '9' 'A' 'B'
					                             'C' 'D' 'E' 'F'
					                             'G' 'H' 'K' 'L'
					                             'M' 'N' 'P') then surg=1;
					end;
				if surg ne 1 then delete;
				drop surg;
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

&flag_ibd_surg=1;
rename &clm_beg_dt = &flag_ibd_surg._dt;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_ot_   );


/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data final_sub_ds;
    set sviews.maxds_ot_ch
        ;
   where &flag_ibd_surg=1;
run;


proc sort data= final_sub_ds nodupkey
           out= &final_sub_ds ;					/*& important here!*/
by &pat_idb &flag_ibd_surg &flag_ibd_surg._dt;
run;

/*count number of IBD surg from outpatient*

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
%counts(in=&shlib..&proj_ds_pfx.ibdsurg_ot_2010_2014,
		out=ibd_op_surg_cnt , 
		date= ibd_op_surg_dt, 
		date_first=ibd_op_surg_dt_first,
		date_last=ibd_op_surg_dt_last,
		flagin=ibd_op_surg , count=ibd_op_surg_count );

		/*** clean up of data - temp - created in lwork space ***/
/*** using the temp prefix ***
proc datasets lib=&lwork. noprint ;
delete &temp_ds_pfx.:;
quit;
run;
